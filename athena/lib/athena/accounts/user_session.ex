defmodule Athena.Accounts.UserSession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_sessions" do
    field(:token, :string)
    field(:expires_at, :utc_datetime)
    field(:last_activity_at, :utc_datetime)
    field(:ip_address, :string)
    field(:user_agent, :string)
    field(:device_info, :map)
    field(:location_info, :map)
    field(:is_revoked, :boolean, default: false)
    field(:revoked_at, :utc_datetime)
    field(:revocation_reason, :string)

    belongs_to(:user, Athena.Accounts.User)

    timestamps()
  end

  # constant declarations for filling fields
  @required_fields ~w(token expires_at user_id)a
  @optional_fields ~w(last_activity_at ip_address user_agent device_info location_info is_revoked revoked_at revocation_reason)a

  def changeset(session, attrs) do
    session
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:token)
    |> foreign_key_constraint(:user_id)
    |> validate_future_date(:expires_at)
    |> validate_revocation()
  end

  defp validate_future_date(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      case DateTime.compare(value, DateTime.utc_now()) do
        :gt -> []
        _ -> [{field, "must be in the future"}]
      end
    end)
  end

  defp validate_revocation(changeset) do
    if get_change(changeset, :is_revoked) do
      changeset
      |> put_change(:revoked_at, DateTime.utc_now())
      |> validate_required(:revocation_reason)
    else
      changeset
    end
  end
end
