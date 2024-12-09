defmodule Athena.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:date_of_birth, :date)
    field(:gender, :string)
    field(:phone_number, :string)
    field(:address, :string)

    has_one(:user_account, Athena.Accounts.UserAccount)
    has_one(:user_profile, Athena.Accounts.UserProfile)
    has_many(:user_roles, Athena.Accounts.UserRole)
    has_many(:session_attendance, Athena.Classrooms.SessionAttendance)
    has_many(:forum_posts, Athena.Discussions.ForumPost)
    has_many(:assignment_submissions, Athena.Assignments.AssignmentSubmission)
    has_many(:grades, Athena.Assessments.StudentGrade)
    has_many(:graded_assignments, Athena.Assessments.StudentGrade, foreign_key: :graded_by)

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :date_of_birth, :gender, :phone_number, :address])
    |> validate_required([
      :first_name,
      :last_name,
      :date_of_birth,
      :gender,
      :phone_number,
      :address
    ])
  end
end
