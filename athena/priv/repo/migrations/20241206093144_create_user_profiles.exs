defmodule Athena.Repo.Migrations.CreateUserProfiles do
  use Ecto.Migration

  def change do
    create table(:user_profiles) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:profile_picture_url, :string)
      add(:bio, :text)
      add(:interests, {:array, :string})
      add(:socials, :map)
      add(:preferences, :map)

      timestamps()
    end

    create(unique_index(:user_profiles, [:user_id]))
  end
end
