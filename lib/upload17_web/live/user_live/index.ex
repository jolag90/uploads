defmodule Upload17Web.UserLive.Index do
  use Upload17Web, :live_view

  alias Upload17.People
  alias Upload17.People.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:people, list_people())
     |> assign(:uploaded_files, [])
     |> allow_upload(:photo, accept: ~w(.jpeg .jpg .png), max_entries: 2)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    # IO.inspect(url, label: "HANDLE PARAMS URL")
    # IO.inspect(params, label: "\n\n###PARAMS###")
    # IO.inspect(socket.assigns, label: "\n\n###SOCKET.ASSIGNS###")

    {:noreply,
     socket
     |> assign(:uploaded_files, [])
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, People.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing People")
    |> assign(:user, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = People.get_user!(id)
    {:ok, _} = People.delete_user(user)

    {:noreply, assign(socket, :people, list_people())}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  defp list_people do
    People.list_people()
  end
end
