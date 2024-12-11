defmodule Athena.Accounts.Auth do
  import Ecto.Query
  alias Athena.Repo
  alias Athena.Accounts.{User, UserAccount, UserRole, UserSession}
  alias Athena.Security
  require Logger

  @session_validity_days 30
  @max_session_per_user 5

  # kinda like enum definition - well, it's not kinda, but exactly enum
  @type auth_error ::
          :invalid_credentials
          | :account_locked
          | :account_deactivated
          | :account_not_verified
          | :too_many_attempts
          | :expired_token
          | :invalid_token
          | :session_limit_reached

  @doc """
    Authenticates a user with username/email and password.
    Handles rate limiting and account locks.
  """

  # generally, it's interface without explicit and forced implementation.
  # it's a way to tell the reader what the function is intended to do.
  @spec authenticate(String.t(), String.t(), map()) ::
          {:ok, User.t(), String.t()}
          | {:error, auth_error()}

  def authenticate(username_or_email, password, metadata \\ %{}) do
    # this is a try catch block but written in simple forms
    with {:ok, :rate_limit_ok} <- check_rate_limit(username_or_email),
         {:ok, user_account} <- get_user_account(username_or_email),
         {:ok, :account_active} <- verify_account_status(user_account),
         {:ok, :password_valid} <- verify_password(user_account, password),
         {:ok, user} <- get_user_with_roles(user_account.user_id),
         {:ok, session} <- create_session(user, metadata) do
      reset_failed_attempts(user_account)
      log_successful_auth(user, metadata)
      {:ok, user, session.token}
    else
      {:error, reason} = error ->
        log_failed_auth(username_or_email, reason, metadata)
        error
    end
  end

  @doc """
    session creation for a user with metadata.
  """
  @spec create_session(User.t(), map()) :: {:ok, UserSession.t()} | {:error, auth_error()}
  def create_session(user, metadata) do
    with {:ok, :limit_ok} <- verify_session_limit(user.id),
         {:ok, token} <- Security.generate_session_token(),
         session_attrs <- build_session_attributes(user, token, metadata) do
      clean_old_sessions(user.id)
      create_session_record(session_attrs)
    end
  end

  @doc """
    Validates a session token and returns the associated user
  """
  @spec validate_session(String.t()) :: {:ok, User.t()} | {:error, auth_error()}
  def validate_session(token) do
    case get_session(token) do
      {:ok, session} ->
        update_session_activity(session)

        with :ok <- verify_session_validity(token),
             {:ok, user} <- get_user_with_roles(session.user_id) do
          {:ok, user}
        end

      error ->
        error
    end
  end

  @doc """
    invalidate all sessions for a given user
  """
  @spec invalidate_all_sessions(integer()) :: {:ok, integer()} | {:error, term()}
  def invalidate_all_sessions(user_id) do
    with query <- from(s in UserSession, where: s.user_id == ^user_id),
         {:ok, {count, _}} <- safe_delete_all(query) do
      {:ok, count}
    else
      {:error, %Ecto.QueryError{} = e} -> {:error, e}
      {:error, some_error} -> {:error, some_error}
    end
  end

  # helper functions
  defp safe_delete_all(query) do
    try do
      {:ok, Repo.delete_all(query)}
    rescue
      e in Ecto.QueryError -> {:error, e}
    end
  end

  defp check_rate_limit(username_or_email) do
    case Athena.Accounts.RateLimiter.check_rate_limit(username_or_email) do
      :ok -> {:ok, :rate_limit_ok}
      {:error, :rate_limited} -> {:error, :too_many_attempts}
    end
  end

  defp get_user_account(username_or_email) do
    case Repo.get_by(UserAccount, username_or_email: String.downcase(username_or_email)) do
      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}

      user_account ->
        {:ok, user_account}
    end
  end

  defp verify_account_status(user_account) do
    case user_account.account_status do
      "active" ->
        {:ok, :account_active}

      "dormant" ->
        {:ok, :account_locked}

      "suspended" ->
        {:ok, :account_locked}

      "deactivated" ->
        {:ok, :account_deactivated}

      _ ->
        {:error, :invalid_credentials}
    end
  end

  defp verify_password(user_account, password) do
    if Argon2.verify_pass(password, user_account.password_hash) do
      {:ok, :password_valid}
    else
      increase_failed_attempts(user_account)
      {:error, :invalid_credentials}
    end
  end

  defp get_user_with_roles(user_id) do
    case Repo.get(User, user_id) |> Repo.preload([:user_roles, :user_profile]) do
      nil -> {:error, :invalid_credentials}
      user -> {:ok, user}
    end
  end

  defp verify_session_limit(user_id) do
    count = Repo.aggregate(from(s in UserSession, where: s.user_id == ^user_id), :count)

    if count < @max_session_per_user do
      {:ok, :limit_ok}
    else
      {:error, :session_limit_reached}
    end
  end

  defp build_session_attributes(user, token, metadata) do
    %{
      user_id: user.id,
      token: token,
      expires_at: DateTime.utc_now() |> DateTime.add(@session_validity_days, :day),
      ip_address: metadata[:ip_address],
      user_agent: metadata[:user_agent],
      device_info: metadata[:device_info],
      location_info: metadata[:location_info]
    }
  end

  defp create_session_record(attrs) do
    %UserSession{}
    |> UserSession.changeset(attrs)
    |> Repo.insert()
  end

  defp clean_old_sessions(user_id) do
    query =
      from(s in UserSession, where: s.user_id == ^user_id and s.expires_at < ^DateTime.utc_now())

    Repo.delete_all(query)
  end

  defp get_session(token) do
    case Repo.get_by(UserSession, token: token) do
      nil -> {:error, :invalid_token}
      session -> {:ok, session}
    end
  end

  defp verify_session_validity(session) do
    if DateTime.compare(session.expires_at, DateTime.utc_now()) == :gt do
      :ok
    else
      {:error, :expired_token}
    end
  end

  defp update_session_activity(session) do
    session
    |> UserSession.changeset(%{last_activity_at: DateTime.now("Europe/Moscow")})
    |> Repo.update()
  end

  defp increase_failed_attempts(user_account) do
    new_count = (user_account.failed_attempts || 0) + 1

    base_updates = %{
      failed_attempts: new_count,
      last_failed_attempt_at: DateTime.utc_now()
    }

    updates =
      if new_count >= 5 do
        Map.merge(base_updates, %{account_status: "suspended"})
      else
        base_updates
      end

    user_account
    |> UserAccount.changeset(updates)
    |> Repo.update()
  end

  defp reset_failed_attempts(user_account) do
    user_account
    |> UserAccount.changeset(%{failed_login_attempts: 0, last_failed_attempt_at: nil})
    |> Repo.update()
  end

  defp log_successful_auth(user, metadata) do
    Logger.info(
      "Successful authentication for user #{user.id}",
      user_id: user.id,
      ip_address: metadata[:ip_address],
      user_agent: metadata[:user_agent]
    )
  end

  defp log_failed_auth(username_or_email, reason, metadata) do
    Logger.error("Failed authentication attempt",
      username_or_email: username_or_email,
      reason: reason,
      ip_address: metadata[:ip_address],
      user_agent: metadata[:user_agent]
    )
  end
end
