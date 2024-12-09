defmodule Athena.Repo.Migrations.CreateUserAccounts do
  use Ecto.Migration

  def change do
    create table(:user_accounts) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:institution_id, references(:institutions, on_delete: :nulify_all), null: false)
      add(:email, :string, null: false)
      add(:password_hash, :string, null: false)
      add(:username, :string, null: false)
      add(:password_reset_token, :string)
      add(:password_reset_token_sent_at, :naive_datetime)
      add(:last_login_at, :naive_datetime)
      add(:last_activity_at, :naive_datetime)
      add(:login_count, :integer, default: 0)
      add(:two_factor_enabled, :boolean)
      add(:two_factor_secret, :string)
      add(:timezone, :string)
      add(:account_status, :string, default: "active")

      timestamps()
    end

    create(unique_index(:user_accounts, [:email, :username, :user_id, :institution_id]))

    create(
      constraint(:user_accounts, :user_account_status_check,
        check: "account_status IN ('active', 'suspended', 'dormant', 'deactivated')"
      )
    )
  end
end
