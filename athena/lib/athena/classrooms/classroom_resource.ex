defmodule Athena.Classrooms.ClassroomResource do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classroom_resources" do
    field(:title, :string)
    field(:resource_type, Ecto.Enum, values: [:book, :article, :video, :lecture], default: :book)
    field(:content_url, :string)

    belongs_to(:virtual_classroom, Athena.Classrooms.VirtualClassroom)

    timestamps()
  end

  def changeset(resources, attrs) do
    resources
    |> cast(attrs, [:title, :resource_type, :content_url])
    |> validate_required([:title])
  end
end
