defmodule Athena.Analytics.UserActivity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_activity" do
    field(:activity_type, :string)
    field(:entity_type, :string)
    field(:entity_id, :integer)
    field(:action, :string)
    field(:details, :map)
    field(:metadata, :map)
    field(:ip_address, :string)
    field(:user_agent, :string)
    field(:device_info, :map)
    field(:location_info, :map)
    field(:session_id, :string)
    field(:status, :string)
    field(:error_details, :map)

    belongs_to(:user, Athena.Accounts.User)
    belongs_to(:course, Athena.Courses.Course)
    belongs_to(:virtual_classroom, Athena.Classrooms.VirtualClassroom)
    belongs_to(:institution, Athena.Institutions.Institution)

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(user_activity, attrs) do
    user_activity
    |> cast(attrs, [
      :activity_type,
      :entity_type,
      :entity_id,
      :action,
      :details,
      :metadata,
      :ip_address,
      :user_agent,
      :device_info,
      :location_info,
      :session_id,
      :status,
      :error_details
    ])
    |> validate_required([:activity_type, :action])
  end
end
