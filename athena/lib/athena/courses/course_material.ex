defmodule Athena.Courses.CourseMaterial do
  use Ecto.Schema
  import Ecto.Changeset

  schema "course_materials" do
    field(:title, :string)
    field(:description, :string)
    field(:material_type, Ecto.Enum, values: [:book, :video, :article], default: :book)
    field(:resource_url, :string)
    field(:order_index, :integer)
    field(:visibility, Ecto.Enum, values: [:visible, :hidden, :protected], default: :visible)

    belongs_to(:course, Athena.Courses.Course)
  end

  def changeset(course_material, attrs) do
    course_material
    |> cast(attrs, [
      :title,
      :description,
      :material_type,
      :resource_url,
      :order_index,
      :visibility
    ])
    |> validate_required([:title])
  end
end
