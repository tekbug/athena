defmodule Athena.Assessments.Quiz do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quizs" do
    field(:title, :string)
    field(:description, :string)
    field(:duration, :integer, default: 60)
    field(:start_time, :utc_datetime)
    field(:end_time, :utc_datetime)
    field(:quiz_status, Ecto.Enum, values: [:completed, :draft], default: :draft)

    belongs_to(:virtual_classroom, Athena.Classrooms.VirtualClassroom)
    has_many(:questions, Athena.Assessment.QuizQuestion)
    has_many(:grades, Athena.Assessments.StudentGrade)

    timestamps()
  end

  def changeset(quiz, attrs) do
    quiz
    |> cast(attrs, [:title, :description, :duration, :start_time, :end_time, :quiz_status])
    |> validate_required([:title])
  end
end
