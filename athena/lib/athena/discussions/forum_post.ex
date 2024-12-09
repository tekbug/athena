defmodule Athena.Discussions.ForumPost do
  use Ecto.Schema
  import Ecto.Changeset

  schema "forum_post" do
    field(:content, :string)

    belongs_to(:forum, Athena.Discussions.DiscussionForum)
    belongs_to(:user, Athena.Accounts.User)
    belongs_to(:parent_post, Athena.Discussions.ForumPost)

    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
