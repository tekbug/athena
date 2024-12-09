defmodule Athena.Accounts.UserProfile do
  alias Athena.Accounts.User, as: Users
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_profiles" do
    field(:profile_picture_url, :string)
    field(:bio, :string)
    field(:interests, {:array, :string})
    field(:socials, :map)
    field(:preferences, :map)

    belongs_to(:user, Users)

    timestamps()
  end

  def changeset(user_profile, attrs) do
    user_profile
    |> cast(attrs, [
      :profile_picture_url,
      :bio,
      :interests,
      :socials,
      :preferences,
      :user_id
    ])
  end
end
