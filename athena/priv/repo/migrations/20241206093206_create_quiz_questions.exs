defmodule Athena.Repo.Migrations.CreateQuizQuestions do
  use Ecto.Migration

  def change do
    create table(:quiz_questions) do
      add(:quiz_id, references(:quizzes, on_delete: :delete_all), null: false)
      add(:question_text, :string, null: false)
      add(:question_type, :string, default: "choice", null: false)
      add(:points, :decimal, default: 0.0)
      add(:order_index, :integer)

      timestamps()
    end

    create(unique_index(:quiz_questions, [:quiz_id]))
  end
end
