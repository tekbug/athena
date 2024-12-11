defmodule Athena.Contents.FileUpload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "file_uploads" do
    field(:filename, :string)
    field(:original_filename, :string)
    field(:content_type, :string)
    field(:file_size, :integer)
    field(:storage_path, :string)
    field(:public_url, :string)
    field(:file_type, Ecto.Enum, values: [:document, :image, :video], default: :document)
    field(:metadata, :map)

    belongs_to(:uploaded_by, Athena.Accounts.User)
    belongs_to(:course, Athena.Courses.Course)

    timestamps()
  end

  def changeset(uploads, attrs) do
    uploads
    |> cast(attrs, [
      :filename,
      :original_filename,
      :content_type,
      :file_size,
      :storage_path,
      :public_url,
      :file_type,
      :metadata,
      :uploaded_by_id,
      :course_id
    ])
  end
end
