defmodule Athena.Repo.Migrations.CreateStudentGrades do
  use Ecto.Migration

  def change do
    create table(:student_grades) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:course_id, references(:courses, on_delete: :delete_all), null: false)
      add(:assignment_id, references(:assignments, on_delete: :delete_all), null: false)
      add(:quiz_id, references(:quizzes, on_delete: :delete_all), null: false)
      add(:graded_by, references(:users, on_delete: :delete_all), null: false)

      add(:score, :decimal, default: 0.0)
      add(:feedback, :text)
      add(:graded_at, :utc_datetime)

      timestamps()
    end

    create(index(:student_grades, [:user_id, :course_id, :assignment_id, :quiz_id]))
  end
end
