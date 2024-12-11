defmodule Athena.Accounts.RateLimiter do
  use GenServer
  require Logger

  @max_attempts_per_interval 5
  @interval_seconds 300
  @cleanup_interval 3600
  @max_entries 10_000

  @type attempt :: %{
          timestamp: integer(),
          ip_address: String.t(),
          user_agent: String.t()
        }

  @type limiter_entry :: %{
          attempts: [attempt()],
          blocked_until: integer() | nil
        }

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec check_rate_limit(String.t(), map()) :: :ok | {:error, :rate_limited}
  def check_rate_limit(key, metadata \\ %{}) do
    GenServer.call(__MODULE__, {:check_rate_limit, key, metadata})
  end

  @spec reset_limit(String.t()) :: :ok
  def reset_limit(key) do
    GenServer.cast(__MODULE__, {:reset_limit, key})
  end

  @spec get_remaining_attempts(String.t()) :: {:ok, integer()} | {:error, :blocked}
  def get_remaining_attempts(key) do
    GenServer.call(__MODULE__, {:get_remaining_attempts, key})
  end

  # callbacks to the server
  @impl true
  def init(opts) do
    schedule_cleanup()

    {:ok,
     %{
       limits: %{},
       options: process_options(opts)
     }}
  end

  @impl true
  def handle_call({:check_rate_limit, key, metadata}, _from, state) do
    now = System.system_time(:second)
    entry = Map.get(state.limits, key, %{attempts: [], blocked_until: nil})

    case check_limit(entry, now, state.options) do
      {:ok, new_entry} ->
        updated_entry = record_attempt(new_entry, now, metadata)
        new_state = put_in(state.limits[key], updated_entry)
        {:reply, :ok, new_state}

      {:error, :rate_limited, blocked_until} ->
        log_rate_limit_exceeded(key, metadata)
        updated_entry = %{entry | blocked_until: blocked_until}
        new_state = put_in(state.limits[key], updated_entry)
        {:reply, {:error, :rate_limited}, new_state}
    end
  end

  @impl true
  def handle_call({:get_remaining_attempts, key}, _from, state) do
    now = System.system_time(:second)
    entry = Map.get(state.limits, key, %{attempts: [], blocked_until: nil})

    case get_remaining(entry, now, state.options) do
      {:ok, remaining} -> {:reply, {:ok, remaining}, state}
      {:error, :blocked} -> {:reply, {:error, :blocked}, state}
    end
  end

  @impl true
  def handle_cast({:reset_limit, key}, state) do
    {:noreply, %{state | limits: Map.delete(state.limits, key)}}
  end

  @impl true
  def handle_info(:cleanup, state) do
    schedule_cleanup()
    new_state = cleanup_old_entries(state)
    {:noreply, new_state}
  end

  defp process_options(opts) do
    %{
      max_attempts: Keyword.get(opts, :max_attempts, @max_attempts_per_interval),
      interval_seconds: Keyword.get(opts, :interval_seconds, @interval_seconds),
      block_duration: Keyword.get(opts, :block_duration, @interval_seconds * 2)
    }
  end

  defp check_limit(entry, now, options) do
    cond do
      is_blocked?(entry, now) ->
        {:error, :rate_limited, entry.blocked_until}

      count_recent_attempts(entry, now, options) >= options.max_attempts ->
        blocked_until = now + options.block_duration
        {:error, :rate_limited, blocked_until}

      true ->
        {:ok, entry}
    end
  end

  defp is_blocked?(entry, now) do
    entry.blocked_until && entry.blocked_until > now
  end

  defp count_recent_attempts(entry, now, options) do
    cutoff = now - options.interval_seconds
    Enum.count(entry.attempts, fn attempt -> attempt.timestamp >= cutoff end)
  end

  defp record_attempt(entry, now, metadata) do
    attempt = %{
      timestamp: now,
      ip_address: metadata[:ip_address],
      user_agent: metadata[:user_agent]
    }

    %{entry | attempts: [attempt | entry.attempts]}
  end

  defp get_remaining(entry, now, options) do
    if is_blocked?(entry, now) do
      {:error, :blocked}
    else
      recent_attempts = count_recent_attempts(entry, now, options)
      {:ok, options.max_attempts - recent_attempts}
    end
  end

  defp cleanup_old_entries(state) do
    now = System.system_time(:second)
    cutoff = now - state.options.interval_seconds

    cleaned_limits =
      Enum.reduce(state.limits, %{}, fn {key, entry}, acc ->
        case cleanup_entry(entry, cutoff) do
          nil -> acc
          cleaned_entry -> Map.put(acc, key, cleaned_entry)
        end
      end)

    %{state | limits: cleaned_limits}
  end

  defp cleanup_entry(entry, cutoff) do
    cleaned_attempts =
      Enum.filter(entry.attempts, fn attempt ->
        attempt.timestamp > cutoff
      end)

    cond do
      entry.blocked_until && entry.blocked_until > cutoff ->
        %{entry | attempts: cleaned_attempts}

      length(cleaned_attempts) > 0 ->
        %{entry | attempts: cleaned_attempts, blocked_until: nil}

      true ->
        nil
    end
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @cleanup_interval * 1000)
  end

  defp log_rate_limit_exceeded(key, metadata) do
    Logger.warn("Rate limit exceeded",
      key: key,
      ip_address: metadata[:ip_address],
      user_agent: metadata[:user_agent]
    )
  end
end
