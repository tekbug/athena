defmodule Athena.Assignments.AssignmentSubmission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assignment_submissions" do
    field(:content, :string)
    field(:submission_url, :string)
    field(:submitted_at, :naive_datetime)

    field(:submission_status, Ecto.Enum,
      values: [:submitted, :pending, :rejected],
      default: :pending
    )

    belongs_to(:assignment, Athena.Assignments.Assignment)
    belongs_to(:user, Athena.Accounts.User)

    timestamps()
  end

  def changeset(submit, attrs) do
    submit
    |> cast(attrs, [:content, :submission_url, :submitted_at, :submission_status])
    |> validate_required([:submitted_at])
  end
end
