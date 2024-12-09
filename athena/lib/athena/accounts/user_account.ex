defmodule Athena.Accounts.UserAccount do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_accounts" do
    field(:email, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:username, :string)

    field(:account_status, Ecto.Enum,
      values: [:active, :suspended, :dormant, :deactivated],
      default: :active
    )

    field(:password_reset_token, :string)
    field(:password_reset_token_sent_at, :naive_datetime)
    field(:last_login_at, :naive_datetime)
    field(:last_activity_at, :naive_datetime)
    field(:login_count, :integer)
    field(:two_factor_enabled, :boolean, default: false)
    field(:two_factor_secret, :string)
    field(:timezone, :string)

    belongs_to(:user, Athena.Accounts.User)
    belongs_to(:institution, Athena.Institutions.Institution)

    timestamps()
  end

  def changeset(user_account, attrs) do
    user_account
    |> cast(attrs, [
      :email,
      :password,
      :username,
      :account_status,
      :last_login_at,
      :password_reset_token,
      :password_reset_token_sent_at,
      :login_count,
      :two_factor_enabled,
      :two_factor_secret,
      :timezone,
      :user_id,
      :institution_id
    ])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint([:email, :username, :password])
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
