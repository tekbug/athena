defmodule Athena.Discussions.DiscussionForum do
  use Ecto.Schema
  import Ecto.Changeset

  schema "discussion_forums" do
    field(:title, :string)
    field(:description, :string)

    belongs_to(:virtual_classrooms, Athena.Classrooms.VirtualClassrooms)
    has_many(:forum_posts, Athena.Discussions.ForumPost)

    timestamps()
  end

  def changeset(discussion, attrs) do
    discussion
    |> cast(attrs, [:title, :description])
    |> validate_required([:title])
  end
end
