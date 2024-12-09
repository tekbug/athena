defmodule Athena.Classrooms.SessionAttendance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "session_attendance" do
    field(:join_time, :utc_datetime)
    field(:leave_time, :utc_datetime)
    field(:attendance_status, Ecto.Enum, values: [:present, :absent, :pass], default: :present)

    belongs_to(:classroom_session, Athena.Classrooms.ClassroomSession)
    belongs_to(:user, Athena.Accounts.User)

    timestamps()
  end

  def changeset(attendance, attrs) do
    attendance
    |> cast(attrs, [:join_time, :leave_time, :attendance_status, :session_id, :user_id])
    |> validate_required([:session_id, :user_id])
  end
end
