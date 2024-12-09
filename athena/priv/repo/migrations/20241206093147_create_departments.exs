defmodule Athena.Repo.Migrations.CreateDepartments do
  use Ecto.Migration

  def change do
    create table(:departments) do
      add(:institution_id, references(:institutions, on_delete: :delete_all), null: false)
      add(:name, :string, null: false)
      add(:description, :text)

      timestamps()
    end

    create(unique_index(:departments, [:name, :institution_id]))
  end
end
