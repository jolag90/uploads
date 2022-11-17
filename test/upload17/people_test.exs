defmodule Upload17.PeopleTest do
  use Upload17.DataCase

  alias Upload17.People

  describe "people" do
    alias Upload17.People.User

    import Upload17.PeopleFixtures

    @invalid_attrs %{name: nil, photo_url: nil}

    test "list_people/0 returns all people" do
      user = user_fixture()
      assert People.list_people() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert People.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{name: "some name", photo_url: "some photo_url"}

      assert {:ok, %User{} = user} = People.create_user(valid_attrs)
      assert user.name == "some name"
      assert user.photo_url == "some photo_url"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = People.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{name: "some updated name", photo_url: "some updated photo_url"}

      assert {:ok, %User{} = user} = People.update_user(user, update_attrs)
      assert user.name == "some updated name"
      assert user.photo_url == "some updated photo_url"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = People.update_user(user, @invalid_attrs)
      assert user == People.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = People.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> People.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = People.change_user(user)
    end
  end
end
