defmodule Athena.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field(:title, :string)
    field(:content, :string)

    field(:notification_type, Ecto.Enum,
      values: [:assignment, :announcement, :grade],
      default: :announcement
    )

    field(:priority, Ecto.Enum, values: [:high, :medium, :low], default: :high)
    field(:read_at, :naive_datetime)
    field(:delivered_at, :naive_datetime)
    field(:delivery_method, Ecto.Enum, values: [:email, :push], default: :push)

    belongs_to(:user, Athena.Accounts.User)
    belongs_to(:course, Athena.Courses.Course)

    timestamps()
  end

  def changeset(notifications, attrs) do
    notifications
    |> cast(attrs, [
      :title,
      :content,
      :notification_type,
      :priority,
      :read_at,
      :delivered_at,
      :delivery_method,
      :user_id,
      :course_id
    ])
  end
end
