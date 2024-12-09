defmodule Athena.Institutions.Department do
  use Ecto.Schema
  import Ecto.Changeset

  alias Athena.Institutions.Institution, as: Institutions
  alias Athena.Courses.Course, as: Courses

  schema "departments" do
    field(:name, :string)
    field(:description, :string)

    belongs_to(:institution, Institutions)
    has_many(:courses, Courses)

    timestamps()
  end

  def changeset(departments, attrs) do
    departments
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
