defmodule Athena.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add(:department_id, references(:departments, on_delete: :delete_all), null: false)
      add(:course_code, :string, null: false)
      add(:name, :string, null: false)
      add(:description, :text)
      add(:credits, :integer, default: 0)
      add(:year, :integer, default: 0)
      add(:semester, :string, null: false)
      add(:course_status, :string, default: "active")

      timestamps()
    end

    create(index(:courses, [:department_id]))
    create(unique_index(:courses, [:course_code]))

    create(
      constraint(:courses, :course_status_check,
        check: "course_status IN ('active', 'suspended')"
      )
    )
  end
end
