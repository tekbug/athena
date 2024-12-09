defmodule Athena.Repo.Migrations.CreateVirtualClassrooms do
  use Ecto.Migration

  def change do
    create table(:virtual_classrooms) do
      add(:course_id, references(:courses, on_delete: :delete_all), null: false)
      add(:name, :string, null: false)
      add(:description, :text)
      add(:class_link, :string, null: false)

      timestamps()
    end

    create(unique_index(:virtual_classrooms, [:name, :course_id]))
  end
end
