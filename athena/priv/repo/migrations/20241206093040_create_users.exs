defmodule Athena.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:first_name, :string, null: false)
      add(:last_name, :string, null: false)
      add(:date_of_birth, :string)
      add(:gender, :string)
      add(:phone_number, :string, null: false)
      add(:address, :text)

      timestamps()
    end

    create(unique_index(:users, [:phone_number]))
  end
end
