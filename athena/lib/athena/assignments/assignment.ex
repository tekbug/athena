defmodule Athena.Assignments.Assignment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assignments" do
    field(:title, :string)
    field(:description, :string)
    field(:due_date, :utc_datetime)
    field(:points, :float)
    field(:assignment_type, :string)
    field(:submission_type, :string)

    belongs_to(:course, Athena.Courses.Course)
    has_many(:submissions, Athena.Assignments.AssignmentSubmission)
    has_many(:grades, Athena.Assessments.StudentGrade)

    timestamps()
  end

  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, [:title, :description, :due_date, :points, :assignment_type, :submission_type])
    |> validate_required([:title, :due_date])
  end
end
