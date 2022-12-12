defmodule Upload17Web.UserLive.Edit do
  use Upload17Web, :live_component

  alias Upload17.People
  alias Upload17Web.UserLive.FileManager

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = People.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> People.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    FileManager.save_user(socket, socket.assigns.action, user_params)
  end

  @impl true
  def handle_event("cancel-button", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  @impl true
  def handle_event("delete-button", %{"ref" => ref}, socket) do
    FileManager.remove_file(socket, ref)
    {:noreply, socket}
  end
end
