defmodule Athena.Accounts.Guardian do
  use Guardian, otp_app: :athena

  alias Athena.Accounts
  alias Athena.Accounts.User
  alias Athena.Repo

  @token_types %{
    access: "access_token",
    refresh: "refresh_token",
    reset_password: "reset_password_token",
    email_verification: "email_verification_token"
  }

  @doc """
  Generate subject claim for JWT tokens
  """
  @spec subject_for_token(User.t(), map()) :: {:ok, String.t()} | {:error, :invalid_resource}
  def subject_for_token(%User{} = user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def subject_for_token(_, _), do: {:error, :invalid_resource}

  @doc """
  Builds the resource from the token claims
  """
  @spec resource_from_claims(map()) :: {:ok, User.t()} | {:error, term()}
  def resource_from_claims(%{"sub" => user_id, "typ" => token_type}) do
    case get_user_for_token(user_id, token_type) do
      {:ok, user} -> {:ok, user}
      {:error, reason} -> {:error, reason}
    end
  end

  def resource_from_claims(_), do: {:error, :invalid_claims}

  @doc """
  Creates access token for a user
  """
  @spec create_access_token(User.t(), map()) :: {:ok, String.t(), map()} | {:error, term()}
  def create_access_token(user, claims \\ %{}) do
    {:ok, token, claims} =
      encode_and_sign(user, Map.merge(claims, %{typ: @token_types.access}), ttl: {1, :hour})

    {:ok, token, claims}
  end

  @doc """
  Creates a refresh token for a user
  """
  @spec create_refresh_token(User.t(), map()) :: {:ok, String.t(), map()} | {:error, term()}
  def create_refresh_token(user, claims \\ %{}) do
    {:ok, token, claims} =
      encode_and_sign(user, Map.merge(claims, %{typ: @token_types.refresh}), ttl: {1, :hour})

    {:ok, token, claims}
  end

  @doc """
  Creates a password reset token
  """
  @spec create_reset_token(User.t()) :: {:ok, String.t(), map()} | {:error, term()}
  def create_reset_token(user) do
    {:ok, token, claims} =
      encode_and_sign(user, %{typ: @token_types.reset_password}, ttl: {1, :hour})

    {:ok, token, claims}
  end

  @doc """
  Creates an email verification token
  """
  @spec create_verification_token(User.t()) :: {:ok, String.t(), map()} | {:error, term()}
  def create_verification_token(user) do
    {:ok, token, claims} =
      encode_and_sign(user, %{typ: @token_types.email_verification}, ttl: {1, :hour})

    {:ok, token, claims}
  end

  @doc """
  Exchanges a refresh token for a new access token
  """
  @spec exchange_refresh_token(String.t()) :: {:ok, String.t(), User.t()} | {:error, term()}
  def exchange_refresh_token(refresh_token) do
    with {:ok, claims} <- decode_and_verify(refresh_token, %{"typ" => @token_types.refresh}),
         {:ok, user} <- resource_from_claims(claims),
         {:ok, access_token, _claims} <- create_access_token(user) do
      {:ok, access_token, user}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Blacklists a token
  """
  @spec blacklist_token(String.t()) :: :ok | {:error, term()}
  def blacklist_token(token) do
    with {:ok, claims} <- decode_and_verify(token),
         {:ok, _} <- Guardian.DB.after_revoke(claims, token) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_user_for_token(user_id, token_type) do
    access_type = @token_types.access
    refresh_type = @token_types.refresh

    cond do
      token_type == access_type ->
        get_user_with_roles(user_id)

      token_type == refresh_type ->
        get_user_basic(user_id)

      true ->
        get_user_basic(user_id)
    end
  end

  defp get_user_with_roles(user_id) do
    case Repo.get(User, user_id) |> Repo.preload([:user_roles, :user_profile]) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  defp get_user_basic(user_id) do
    case Repo.get(User, user_id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end
end
