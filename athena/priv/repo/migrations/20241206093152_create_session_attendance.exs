defmodule Athena.Repo.Migrations.CreateSessionAttendance do
  use Ecto.Migration

  def change do
    create table(:session_attendance) do
      add(:session_id, references(:classroom_sessions, on_delete: :delete_all), null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:join_time, :utc_datetime)
      add(:leave_time, :utc_datetime)
      add(:attendance_status, :string, default: "present")

      timestamps()
    end

    create(unique_index(:session_attendance, [:session_id, :user_id]))

    create(
      constraint(:session_attendance, :attendance_status_check,
        check: "attendance_status IN ('present', 'absent', 'pass')"
      )
    )
  end
end
