defmodule Athena.Contents.MediaLibrary do
  use Ecto.Schema
  import Ecto.Changeset

  schema "media_libraries" do
    field(:name, :string)
    field(:description, :string)

    field(:library_type, Ecto.Enum,
      values: [:course_files, :shared_resources],
      default: :course_files
    )

    field(:storage_usage, :decimal, default: 0.0)
    field(:storage_limit, :decimal, default: 30.0)

    belongs_to(:institution, Athena.Institutions.Institution)
    belongs_to(:department, Athena.Departments.Deparment)

    timestamps()
  end

  def changeset(media, attrs) do
    media
    |> cast(attrs, [
      :name,
      :description,
      :library_type,
      :storage_usage,
      :storage_limit,
      :institution_id,
      :department_id
    ])
  end
end
