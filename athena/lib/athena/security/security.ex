defmodule Athena.Security.Security do
  require Logger
  alias Athena.Security.Encryption

  @min_password_length 12
  @max_password_length 72
  @password_regex ~r/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{12,}$/
  @token_length 32
  @reset_token_validity_hours 1
  @verificaion_token_validity_hours 1
  @max_password_reset_attempts 5
  @reset_attempt_windows_hours 24

  @type password_error ::
          :too_short
          | :too_long
          | :missing_uppercase
          | :missing_lowercase
          | :missing_special
          | :common_password
          | :previously_used

  @doc """
  Validates password strength and checks against common password lists
  """
  @spec validate_password_strength(String.t(), map()) :: :ok | {:error, [password_error()]}
  def validate_password_strength(password, opts \\ %{}) do
    with :ok <- check_password_length(password),
         :ok <- check_password_complexity(password),
         :ok <- check_common_passwords(password),
         :ok <- check_password_history(password, opts) do
      :ok
    else
      {:error, reasons} when is_list(reasons) -> {:error, reasons}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Securely hash passwords
  """
  @spec hash_password(String.t()) :: String.t()
  def hash_password(password) do
    Argon2.hash_pwd_salt(password,
      t_cost: 4,
      m_cost: 18,
      parallelism: 2
    )
  end

  @doc """
  Verifies a password against its hash
  """
  @spec verify_password(String.t(), String.t()) :: boolean()
  def verify_password(password, hash) do
    Argon2.verify_pass(password, hash)
  end

  @doc """
  Generates various types of secure tokens
  """
  @spec generate_token(:session | :reset | :verification) ::
          {:ok, String.t(), DateTime.t() | {:error, term()}}
  def generate_token(type) do
    try do
      token =
        :crypto.strong_rand_bytes(@token_length)
        |> Base.url_encode64(padding: false)

      expires_at =
        case type do
          :session ->
            nil

          :reset ->
            DateTime.add(DateTime.utc_now(), @reset_token_validity_hours, :hour)

          :verification ->
            DateTime.add(
              DateTime.utc_now(),
              @verificaion_token_validity_hours,
              :hour
            )
        end

      {:ok, token, expires_at}
    rescue
      e -> {:error, e}
    end
  end

  @doc """
  Encrypts sensitive data using AES-256-GCM standard
  """
  @spec encrypt_sensitive_data(String.t() | map()) :: {:ok, String.t()} | {:error, term()}
  def encrypt_sensitive_data(data) do
    Encryption.encrypt(data)
  end

  @doc """
  Decrypt data
  """
  @spec decrypt_sensitive_data(String.t()) :: {:ok, String.t() | map()} | {:error, term()}
  def decrypt_sensitive_data(encrypted_data) do
    Encryption.decrypt(encrypted_data)
  end

  @doc """
  Generates random string for different purposes
  """
  @spec generate_secure_string(integer()) :: String.t()
  def generate_secure_string(length \\ 32) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end

  @doc """
  Compare two strings in constant time
  """
  @spec secure_compare(String.t(), String.t()) :: boolean()
  def secure_compare(a, b) do
    if byte_size(a) == byte_size(b) do
      :crypto.hash_equals(a, b)
    else
      false
    end
  end

  defp check_password_length(password) do
    cond do
      String.length(password) < @min_password_length ->
        {:error, :too_short}

      String.length(password) > @max_password_length ->
        {:error, :too_long}

      true ->
        :ok
    end
  end

  defp check_password_complexity(password) do
    errors =
      []
      |> check_regex(password, ~r/[A-Z]/, :missing_uppercase)
      |> check_regex(password, ~r/[a-z]/, :missing_lowercase)
      |> check_regex(password, ~r/[0-9]/, :missing_number)
      |> check_regex(password, ~r/[@$!%*?&]/, :missing_special)

    case errors do
      [] -> :ok
      errors -> {:error, errors}
    end
  end

  defp check_regex(errors, password, regex, error) do
    if Regex.match?(regex, password) do
      errors
    else
      [error | errors]
    end
  end

  defp check_common_passwords(password) do
    normalized_password = String.downcase(password)

    if CommonPasswords.contains?(normalized_password) do
      {:error, :common_password}
    else
      :ok
    end
  end

  defp check_password_history(password, %{user: user}) do
    case check_previous_passwords(password, user) do
      true -> {:error, :previously_used}
      false -> :ok
    end
  end

  defp check_password_history(_, _), do: :ok

  defp check_previous_passwords(password, user) do
    user.previous_passwords
    |> Enum.any?(fn prev_hash -> verify_password(password, prev_hash) end)
  end
end
