defmodule Athena.Repo.Migrations.CreateUserRoles do
  use Ecto.Migration

  def change do
    create table(:user_roles) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:role_types, :string, default: "student", null: false)

      timestamps()
    end

    create(unique_index(:user_roles, [:user_id]))

    create(
      constraint(:user_roles, :user_roles_check,
        check: "role_types IN  ('student', 'teacher', 'admin', 'institution_admin')"
      )
    )
  end
end
