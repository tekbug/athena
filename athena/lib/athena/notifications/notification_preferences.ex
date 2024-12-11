defmodule Athena.Notifications.NotificationPreferences do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notification_preferences" do
    field(:notification_type, Ecto.Enum,
      values: [:assignment, :announcement, :grade],
      default: :announcement
    )

    field(:email_enabled, :boolean, default: true)
    field(:push_enabled, :boolean, default: true)

    belongs_to(:user, Athena.Accounts.User)

    timestamps()
  end

  def changeset(prefs, attrs) do
    prefs
    |> cast(attrs, [:notification_type, :email_enabled, :push_enabled, :user_id])
  end
end
