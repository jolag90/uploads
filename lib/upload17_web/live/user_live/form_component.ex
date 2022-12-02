defmodule Upload17Web.UserLive.FormComponent do
  use Upload17Web, :live_component

  alias Upload17.People

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage user records in your database.</:subtitle>
      </.header>

      <%= for former_entry <- assigns.user.photo_urls do %>
        <article class="upload-entry w-[40%] inline-block">
          <figure>
            <img src={former_entry} />
          </figure>
        </article>
        <.link
          phx-click={JS.push("delete", value: %{id: assigns.user.id})}
          data-confirm="Do you realy want to delete that file?
            All changes will be dismissed"
        >
          <button
            type="button"
            phx-click="delete-button"
            phx-value-ref={former_entry}
            phx-target={@myself}
            aria-label="cancel"
          >
            &times;
          </button>
        </.link>
      <% end %>

      <%= for entry <- @uploads.photo.entries do %>
        <article class="upload-entry w-[20%] inline-block">
          <figure>
            <%= for  err <- upload_errors(@uploads.photo, entry) do %>
              <div class="alert alert-danger font-semibold text-red-700">
                <%= error_to_string(err) %>
              </div>
            <% end %>

            <.live_img_preview entry={entry} />
            <figcaption>
              <%= entry.client_name %>
            </figcaption>
          </figure>

          <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

          <button
            type="button"
            phx-click="cancel-button"
            phx-value-ref={entry.ref}
            phx-target={@myself}
            aria-label="cancel"
          >
            &times;
          </button>
        </article>
      <% end %>

      <.simple_form
        :let={f}
        for={@changeset}
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="name" />
        <!-- 1993 is a random number to symbolize that the upload limit is reached, because allow_upload.max_entries requires a positive integer 
        Usage in Index.max_uploads -->
        <%= if @uploads.photo.max_entries != 1993 do %>
          <.live_file_input upload={@uploads.photo} />
        <% else %>
          <.header>
            <:subtitle>
              You have already maxed your uploads. Please remove anyone you dont use anymore.
            </:subtitle>
          </.header>
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save User</.button>
        </:actions>
        <%= for err <- upload_errors(@uploads.photo) do %>
          <p class="alert alert-danger font-semibold text-red-700"><%= error_to_string(err) %></p>
        <% end %>
      </.simple_form>
    </div>
    """
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
    save_user(socket, socket.assigns.action, user_params)
  end

  @impl true
  def handle_event("cancel-button", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  @impl true
  def handle_event("delete-button", %{"ref" => ref}, socket) do
    remove_file(socket, ref)
    {:noreply, socket}
  end

  def error_to_string(:too_large), do: "Too Large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:too_many_files), do: "You have selected too many files"

  defp save_user(socket, :edit, user_params) do
    case People.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        updated_user = Map.put(user, :photo_urls, socket.assigns.user.photo_urls)
        upload_files(socket, updated_user)

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_user(socket, :new, user_params) do
    case People.create_user(user_params) do
      {:ok, user} ->
        upload_files(socket, user)

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp upload_files(socket, user) do
    uploaded_files =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, entry ->
        dest =
          Path.join([:code.priv_dir(:upload17), "static", "uploads", Path.basename(path)]) <>
            Path.extname(entry.client_name)

        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

    People.update_user(user, %{photo_urls: uploaded_files ++ socket.assigns.user.photo_urls})

    {:noreply,
     socket
     |> update(:uploaded_files, &(&1 ++ uploaded_files))
     |> push_navigate(to: socket.assigns.navigate)
     |> put_flash(:info, "User uploaded")}
  end

  defp remove_file(socket, ref) do
    changeset =
      socket.assigns.user.photo_urls
      |> List.delete(ref)

    Upload17Web.UserLive.Index.file_remove([ref])
    People.update_user(socket.assigns.user, %{photo_urls: changeset})
  end
end
