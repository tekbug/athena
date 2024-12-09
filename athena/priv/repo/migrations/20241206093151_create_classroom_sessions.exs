defmodule Athena.Repo.Migrations.CreateClassroomSessions do
  use Ecto.Migration

  def change do
    create table(:classroom_sessions) do
      add(:classroom_id, references(:virtual_classrooms, on_delete: :delete_all), null: false)
      add(:start_time, :utc_datetime)
      add(:end_time, :utc_datetime)
      add(:session_type, :string, default: "lecture")
      add(:recording_url, :string)
      add(:session_status, :string, default: "scheduled")
      add(:way_of_access, :string, default: "invite_only")
      add(:chat_enabled, :boolean, default: false)

      timestamps()
    end

    create(unique_index(:classroom_session, [:classroom_id]))
  end
end
