defmodule Athena.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset

  alias Athena.Institutions.Department, as: Deps
  alias Athena.Classrooms.VirtualClassroom, as: VirtualClassrooms
  alias Athena.Courses.CourseMaterial, as: CourseMaterials
  alias Athena.Assignments.Assignment, as: Assignments
  alias Athena.Assessments.StudentGrade, as: StudentGrades

  schema "courses" do
    field(:course_code, :string)
    field(:name, :string)
    field(:description, :string)
    field(:credits, :integer)
    field(:year, :integer)
    field(:semester, :string)
    field(:course_status, Ecto.Enum, values: [:active, :suspended], default: :active)

    belongs_to(:department, Deps)
    has_many(:virtual_classrooms, VirtualClassrooms)
    has_many(:course_material, CourseMaterials)
    has_many(:assignments, Assignments)
    has_many(:student_grade, StudentGrades)

    timestamps()
  end

  def changeset(courses, attrs) do
    courses
    |> cast(attrs, [:course_code, :name, :description, :credits, :year, :semester, :course_status])
    |> validate_required([:course_code, :name, :course_status])
    |> unique_constraint([:course_code])
  end
end
