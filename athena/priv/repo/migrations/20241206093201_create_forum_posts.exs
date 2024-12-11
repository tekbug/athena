defmodule Athena.Repo.Migrations.CreateForumPosts do
  use Ecto.Migration

  def change do
    create table(:forum_posts) do
      add(:forum_id, references(:discussion_forums, on_delete: :delete_all), null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:parent_post_id, references(:forum_posts, on_delete: :nilify_all), null: false)
      add(:content, :text, null: false)

      timestamps()
    end

    create(index(:forum_posts, [:forum_id, :user_id, :parent_post_id]))
  end
end
