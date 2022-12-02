defmodule Upload17.Repo.Migrations.CreatePeople do
  use Ecto.Migration

  def change do
    create table(:people) do
      add :name, :string
      add :photo_urls, {:array, :string}, default: []

      timestamps()
    end
  end
end
