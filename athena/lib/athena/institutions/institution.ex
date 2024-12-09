defmodule Athena.Institutions.Institution do
  use Ecto.Schema
  import Ecto.Changeset

  alias Athena.Institutions.Department, as: Departments
  alias Athena.Accounts.UserAccount, as: UserAccounts

  schema "institutions" do
    field(:name, :string)
    field(:domain, :string)
    field(:address, :string)
    field(:contact_email, :string)
    field(:contact_phone, :string)
    field(:subscription_type, :string)

    has_many(:departments, Departments)
    has_many(:user_accounts, UserAccounts)

    timestamps()
  end

  def changeset(institution, attrs) do
    institution
    |> cast(attrs, [:name, :domain, :address, :contact_email, :contact_phone, :subscription_type])
    |> validate_required([:name, :domain, :contact_email])
    |> validate_format(:contact_email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint([:contact_email, :domain])
  end
end
