defmodule Upload17.PeopleFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Upload17.People` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "some name",
        photo_url: "some photo_url"
      })
      |> Upload17.People.create_user()

    user
  end
end
