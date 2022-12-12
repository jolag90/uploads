defmodule Upload17Web.UserLive.FileManager do
  use Upload17Web, :live_component

  alias Upload17.People

  @static_path "priv/static"
  @picture_extname ~w/.jpeg .jpg .png/
  @video_extname ~w/.mp4/

  def error_to_string(key) do
    case key do
      :too_large -> "Too Large"
      :not_accepted -> "You have selected an unacceptable file type"
      :too_many_files -> "You have selected too many files"
      _ -> "untreated error: #{key}"
    end
  end

  def exttype(photo_url) do
    cond do
      Path.extname(photo_url) in total_extname(@picture_extname) -> {:pic, photo_url}
      Path.extname(photo_url) in total_extname(@video_extname) -> {:vid, photo_url}
      true -> {:error, photo_url}
    end
  end

  def save_user(socket, :edit, user_params) do
    case People.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        updated_user = Map.put(user, :photo_urls, socket.assigns.user.photo_urls)
        upload_files(socket, updated_user)

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def save_user(socket, :new, user_params) do
    case People.create_user(user_params) do
      {:ok, user} ->
        upload_files(socket, user)

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def remove_file(socket, ref) do
    changeset =
      socket.assigns.user.photo_urls
      |> List.delete(ref)

    file_remove([ref])
    People.update_user(socket.assigns.user, %{photo_urls: changeset})
  end

  def file_remove(photo_urls) when is_list(photo_urls) do
    for photos <- photo_urls do
      delete_existing_file(photos)
    end
  end

  def file_remove(_), do: nil

  defp total_extname(extname) do
    upcase_extname =
      for key <- extname do
        String.upcase(key)
      end

    lowcase_extname =
      for key <- extname do
        String.downcase(key)
      end

    upcase_extname ++ lowcase_extname
  end

  defp upload_files(socket, user) do
    uploaded_files = save_at_dest(socket)
    People.update_user(user, %{photo_urls: socket.assigns.user.photo_urls ++ uploaded_files})

    {:noreply,
     socket
     |> update(:uploaded_files, &(&1 ++ uploaded_files))
     |> push_navigate(to: socket.assigns.navigate)
     |> put_flash(:info, "User uploaded")}
  end

  defp save_at_dest(socket) do
    consume_uploaded_entries(socket, :photo, fn %{path: path}, entry ->
      dest =
        Path.join([:code.priv_dir(:upload17), "static", "uploads", Path.basename(path)]) <>
          Path.extname(entry.client_name)

      File.cp!(path, dest)
      {:ok, ~p"/uploads/#{Path.basename(dest)}"}
    end)
  end

  defp delete_existing_file(photos) do
    if File.exists?(@static_path <> photos) do
      File.rm!(Path.expand(@static_path) <> photos)
    end
  end
end
