defmodule Athena.Assessments.StudentGrade do
  use Ecto.Schema
  import Ecto.Changeset

  schema "student_grades" do
    field(:score, :decimal)
    field(:feedback, :string)
    field(:graded_at, :naive_datetime)

    belongs_to(:user, Athena.Accounts.User)
    belongs_to(:course, Athena.Courses.Course)
    belongs_to(:assignment, Athena.Assignments.Assignment)
    belongs_to(:quiz, Athena.Assessments.Quiz)
    belongs_to(:graded_by, Athena.Accounts.User)

    timestamps()
  end

  def changeset(grades, attrs) do
    grades
    |> cast(attrs, [:score, :feedback, :graded_at])
    |> validate_required([:score])
  end
end
