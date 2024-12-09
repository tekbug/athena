defmodule Athena.Repo.Migrations.CreateInstitutions do
  use Ecto.Migration

  def change do
    create table(:institutions) do
      add(:name, :string, null: false)
      add(:domain, :string)
      add(:address, :text)
      add(:contact_email, :string)
      add(:contact_phone, :string)
      add(:subscription_type, :string)

      timestamps()
    end

    create(unique_index(:institutions, [:domain]))
  end
end
