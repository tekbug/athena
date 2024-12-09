defmodule Athena.Classrooms.ClassroomSession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classroom_sessions" do
    field(:start_time, :utc_datetime)
    field(:end_time, :utc_datetime)

    field(:session_type, Ecto.Enum,
      values: [:lecture, :discussion, :workshop, :lab, :group_work, :office_hours],
      default: :lecture
    )

    field(:recording_url, :string)

    field(:session_status, Ecto.Enum,
      values: [:scheduled, :in_progress, :completed, :cancelled],
      default: :scheduled
    )

    field(:way_of_access, Ecto.Enum,
      values: [:invite_only, :password_protected, :open],
      defualt: :invite_only
    )

    field(:recording_enabled, :boolean, default: false)
    field(:chat_enabled, :boolean, default: false)

    belongs_to(:virtual_classroom, Athena.Classrooms.VirtualClassroom)
    has_many(:session_attendance, Athena.Classrooms.SessionAttendance)

    timestamps()
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [
      :start_time,
      :end_time,
      :session_type,
      :recording_url,
      :session_status,
      :way_of_access,
      :recording_enabled,
      :chat_enabled
    ])
    |> validate_required([:start_time, :end_time])
  end
end
