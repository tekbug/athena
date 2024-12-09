defmodule Athena.Assessments.QuizQuestion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quiz_questions" do
    field(:question_text, :string)
    field(:question_type, Ecto.Enum, values: [:choice, :writing], default: :choice)
    field(:points, :float)
    field(:order_index, :integer)

    belongs_to(:quiz, Athena.Assessments.Quiz)

    timestamps()
  end

  def changeset(questions, attrs) do
    questions
    |> cast(attrs, [:question_text, :question_type, :points, :order_index])
    |> validate_required([:question_text])
  end
end
