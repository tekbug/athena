defmodule Athena.Repo.Migrations.CreateAssignments do
  use Ecto.Migration

  def change do
    create table(:assignments) do
      add(:course_id, references(:courses, on_delete: :delete_all), null: false)
      add(:title, :string, null: false)
      add(:description, :text)
      add(:due_date, :utc_datetime, null: false)
      add(:points, :integer)
      add(:assignment_type, :string)
      add(:submission_type, :string)

      timestamps()
    end

    create(index(:assignments, [:course_id]))
  end
end
