defmodule Athena.Classrooms.VirtualClassroom do
  use Ecto.Schema
  import Ecto.Changeset

  alias Athena.Courses.Course, as: Courses
  alias Athena.Classrooms.ClassroomSession, as: Sessions
  alias Athena.Classrooms.ClassroomResource, as: Resources
  alias Athena.Discussions.DiscussionForum, as: Forums
  alias Athena.Assessments.Quiz, as: Quizzes

  schema "virtual_classrooms" do
    field(:name, :string)
    field(:description, :string)
    field(:class_link, :string)

    belongs_to(:course, Courses)
    has_many(:classroom_sessions, Sessions)
    has_many(:classroom_resources, Resources)
    has_one(:discussion_forum, Forums)
    has_many(:quizzes, Quizzes)

    timestamps()
  end

  def changeset(virtual_classrooms, attrs) do
    virtual_classrooms
    |> cast(attrs, [
      :name,
      :description,
      :class_link
    ])
    |> validate_required([:name])
  end
end
