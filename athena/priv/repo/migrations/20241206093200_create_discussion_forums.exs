defmodule Athena.Repo.Migrations.CreateDiscussionForums do
  use Ecto.Migration

  def change do
    create table(:discussion_forums) do
      add(:classroom_id, references(:virtual_classrooms, on_delete: :delete_all), null: false)
      add(:title, :string, null: false)
      add(:description, :text)

      timestamps()
    end

    create(index(:discussion_forums, [:classroom_id, :title]))
  end
end
