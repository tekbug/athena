defmodule Athena.Repo.Migrations.CreateAssignmentSubmissions do
  use Ecto.Migration

  def change do
    create table(:assignment_submissions) do
      add(:assignment_id, references(:assignments, on_delete: :delete_all), null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:content, :text)
      add(:submission_url, :string)
      add(:submitted_at, :utc_datetime)
      add(:submission_status, :string, default: "pending")
      add(:status, :string)

      timestamps()
    end

    create(index(:assignment_submissions, [:assignment_id]))
    create(index(:assignment_submissions, [:user_id]))

    create(
      constraint(:assignment_submissions, :submission_status_check,
        check: "submission_status IN ('submitted', 'pending', 'rejected')"
      )
    )
  end
end
