defmodule Upload17.People.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "people" do
    field :name, :string
    field :photo_urls, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end