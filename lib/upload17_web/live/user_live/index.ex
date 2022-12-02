defmodule Upload17Web.UserLive.Index do
  use Upload17Web, :live_view

  alias Upload17.People
  alias Upload17.People.User

  @static_path "priv/static"
  @max_entries 4
  @max_file_size 10_000_000 #in bytes
  @accept_files ~w/.jpeg .jpg .png/

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:people, list_people())
      |> assign(:uploaded_files, [])
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(:uploaded_files, [])
     |> apply_action(socket.assigns.live_action, params)
     |> apply_max_uploads()}
  end

  defp apply_max_uploads(socket) do
    user = socket.assigns.user

    max_uploads =
      if user do
        max_uploads(@max_entries - length(user.photo_urls), user)
      else
        @max_entries
      end

    socket
    |> allow_upload(:photo, accept: @accept_files, max_entries: max_uploads, max_file_size: @max_file_size)
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

    file_remove(user.photo_urls)

    People.delete_user(user)
    {:noreply, assign(socket, :people, list_people())}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  defp list_people do
    People.list_people()
  end

  defp max_uploads(entries, _user) when entries == @max_entries, do: @max_entries
  defp max_uploads(entries, user) when entries >= 1, do: @max_entries - length(user.photo_urls)

  # 1993 is a random number to symbolize that the upload limit is reached, because allow_upload.max_entries requires a positive integer
  # Usage in FormComponent.render right before .live_file_input
  defp max_uploads(entries, _user) when entries < 1, do: 1993

  def file_remove(photo_urls) when is_list(photo_urls) do
    for photos <- photo_urls do
      File.rm!(Path.expand(@static_path) <> photos)
    end
  end

  def file_remove(_), do: nil
end
