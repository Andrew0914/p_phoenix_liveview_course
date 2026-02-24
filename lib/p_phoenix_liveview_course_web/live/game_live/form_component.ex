defmodule PPhoenixLiveviewCourseWeb.GameLive.FormComponent do
  use PPhoenixLiveviewCourseWeb, :live_component

  alias PPhoenixLiveviewCourse.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <style>
        form.phx-submit-loading  *:not(button) {
          background-color: lightgray !important;
          opacity: 0.75 !important;
          border-radius: 4px;
        }
      </style>
      <.header>
        {@title}
        <:subtitle>Use this form to manage game records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="game-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:unit_price]} type="number" label="Unit price" step="any" />
        <.input field={@form[:sku]} type="number" label="Sku" />

        <div phx-drop-target={@uploads.image.ref}>
          <.label>Image</.label>
          <.live_file_input upload={@uploads.image} />
        </div>

        <%= for image <- @uploads.image.entries do %>
          <progress value={image.progress} max="100">{image.progress}%</progress>
          <div class="mt-4">
            <.live_img_preview entry={image} width="250" />
          </div>

          <%= for err <- upload_errors(@uploads.image, image) do %>
            <.error>{err}</.error>
          <% end %>
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Game</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{game: game} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Catalog.change_game(game))
     end)
     |> allow_upload(:image,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       max_file_size: 9_000_000,
       auto_upload: true
     )}
  end

  @impl true
  def handle_event("validate", %{"game" => game_params}, socket) do
    changeset = Catalog.change_game(socket.assigns.game, game_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"game" => game_params}, socket) do
    save_game(socket, socket.assigns.action, game_params)
  end

  defp save_game(socket, :edit, params) do
    game_params = params_with_image(socket, params)

    case Catalog.update_game(socket.assigns.game, game_params) do
      {:ok, game} ->
        notify_parent({:saved, game})

        {:noreply,
         socket
         |> put_flash(:info, "Game updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_game(socket, :new, params) do
    game_params = params_with_image(socket, params)

    case Catalog.create_game(game_params) do
      {:ok, game} ->
        notify_parent({:saved, game})

        {:noreply,
         socket
         |> put_flash(:info, "Game created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  def params_with_image(socket, params) do
    path =
      socket
      |> consume_uploaded_entries(:image, &upload_static_file/2)
      |> List.first()

    Map.put(params, "image_upload", path)
  end

  defp upload_static_file(%{path: path}, _entry) do
    # Plug in your production image file persistence implementation here!
    filename = Path.basename(path)
    dest = Path.join("priv/static/images", filename)
    File.cp!(path, dest)
    {:ok, ~p"/images/#{filename}"}
  end
end
