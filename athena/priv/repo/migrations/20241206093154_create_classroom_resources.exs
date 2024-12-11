defmodule Athena.Repo.Migrations.CreateClassroomResources do
  use Ecto.Migration

  def change do
    create table(:classroom_resources) do
      add(:classroom_id, references(:virtual_classrooms, on_delete: :delete_all), null: false)
      add(:title, :string, null: false)
      add(:resource_type, :string, default: "book")
      add(:content_url, :string)

      timestamps()
    end

    create(unique_index(:classroom_resources, [:classroom_id]))
    create(index(:classroom_resources, [:title]))

    create(
      constraint(:classroom_resources, :resource_type_check,
        check: "resource_type IN ('book', 'article', 'video', 'lecture')"
      )
    )
  end
end
