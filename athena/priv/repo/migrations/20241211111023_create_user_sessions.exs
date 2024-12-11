defmodule Athena.Repo.Migrations.CreateUserSessions do
  use Ecto.Migration

  def change do
    create table(:user_sessions) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:token, :string, null: false)
      add(:expires_at, :utc_datetime, null: false)
      add(:last_activity_at, :utc_datetime)
      add(:ip_address, :string)
      add(:user_agent, :string)
      add(:device_info, :map)
      add(:location_info, :map)
      add(:is_revoked, :boolean, default: false)
      add(:revoked_at, :utc_datetime)
      add(:revocation_reason, :string)

      timestamps()
    end

    create(unique_index(:user_sessions, [:token]))
    create(index(:user_sessions, [:user_id]))
  end
end
