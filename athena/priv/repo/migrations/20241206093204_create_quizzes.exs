defmodule Athena.Repo.Migrations.CreateQuizzes do
  use Ecto.Migration

  def change do
    create table(:quizzes) do
      add(:classroom_id, references(:virtual_classrooms, on_delete: :delete_all), null: false)
      add(:title, :string, null: false)
      add(:description, :text, null: false)
      add(:duration, :integer, default: 30)
      add(:start_time, :utc_datetime)
      add(:end_time, :utc_datetime)
      add(:quiz_status, :string, default: "draft")

      timestamps()
    end

    create(unique_index(:quizzes, [:classroom_id, :title]))

    create(
      constraint(:quizzes, :quiz_status_check, check: "quiz_status IN ('completed', 'draft')")
    )
  end
end
