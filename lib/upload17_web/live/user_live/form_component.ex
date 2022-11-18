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

      <%= for entry <- @uploads.photo.entries do %>
        <article class="upload-entry">
          <figure>
            <.live_img_preview entry={entry} />
            <figcaption><%= entry.client_name %></figcaption>
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

          <%= for err <- upload_errors(@uploads.photo, entry) do %>
            <p class="alert alert-danger"><%= error_to_string(err) %></p>
          <% end %>
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
        <.live_file_input upload={@uploads.photo} />
        <:actions>
          <.button phx-disable-with="Saving...">Save User</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  # <.input field={{f, :name}} type="text" label="name" />
  # <.input field={{f, :photo_url}} type="text" label="photo_url" />
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

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  def handle_event("cancel-button", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  def error_to_string(:too_large), do: "Too Large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  def error_to_string(:too_many_files), do: "You have selected too many files"

  defp save_user(socket, :edit, user_params) do
    case People.update_user(socket.assigns.user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_user(socket, :new, user_params) do
    case People.create_user(user_params) do
      {:ok, user} ->
        uploaded_files =
          consume_uploaded_entries(socket, :photo, fn %{path: path}, entry ->
            dest =
              Path.join([:code.priv_dir(:upload17), "static", "uploads", Path.basename(path)]) <>
                Path.extname(entry.client_name)

            File.cp!(path, dest)
            {:ok, ~p"/uploads/#{Path.basename(dest)}"}
          end)
            |> IO.inspect

        People.update_user(user, %{photo_urls: uploaded_files})

        {:noreply,
         socket
         |> update(:uploaded_files, &(&1 ++ uploaded_files))
         |> put_flash(:info, "User created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
