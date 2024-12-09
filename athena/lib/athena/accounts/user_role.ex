defmodule Athena.Accounts.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_roles" do
    field(:role_types, Ecto.Enum,
      values: [:student, :teacher, :admin, :institution_admin],
      default: :student
    )

    belongs_to(:user, Athena.Accounts.User)

    timestamps()
  end

  def changeset(user_roles, attrs) do
    user_roles
    |> cast(attrs, [:role_types])
  end
end
