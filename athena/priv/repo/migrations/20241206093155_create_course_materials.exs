defmodule Athena.Repo.Migrations.CreateCourseMaterials do
  use Ecto.Migration

  def change do
    create table(:course_materials) do
      add(:course_id, references(:courses, on_delete: :delete_all), null: false)
      add(:title, :string, null: false)
      add(:description, :text)
      add(:material_type, :string, default: "book")
      add(:resource_url, :string, null: false)
      add(:order_index, :integer)
      add(:visibility, :string, default: "visible")

      timestamps()
    end

    create(index(:course_materials, [:title, :course_id]))

    create(
      constraint(:course_materials, :visiblity_check,
        check: "visibility IN ('visible', 'hidden', 'protected')"
      )
    )

    create(
      constraint(:course_materials, :resource_type_check,
        check: "resource_type IN ('book', 'video', 'article')"
      )
    )
  end
end
