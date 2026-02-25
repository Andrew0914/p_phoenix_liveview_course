defmodule PPhoenixLiveviewCourseWeb.GameLive.Index do
  use PPhoenixLiveviewCourseWeb, :live_view

  alias PPhoenixLiveviewCourse.Catalog
  alias PPhoenixLiveviewCourse.Catalog.Game
  alias PPhoenixLiveviewCourseWeb.GameLive.Tomatometer

  defmodule SearchForm do
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :query, :string
    end

    def changeset(form, attrs) do
      form
      |> cast(attrs, [:query])
      |> validate_length(:query, min: 3)
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    changeset = SearchForm.changeset(%SearchForm{}, %{})

    {:ok,
     socket
     |> stream(:games, Catalog.list_games())
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Game")
    |> assign(:game, Catalog.get_game!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Game")
    |> assign(:game, %Game{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Games")
    |> assign(:game, nil)
  end

  @impl true
  def handle_info({PPhoenixLiveviewCourseWeb.GameLive.FormComponent, {:saved, game}}, socket) do
    {:noreply, stream_insert(socket, :games, game)}
  end

  @impl true
  def handle_info({:flash, type, message}, socket) do
    {:noreply, socket |> put_flash(type, message)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    game = Catalog.get_game!(id)
    {:ok, _} = Catalog.delete_game(game)
    {:noreply, stream_delete(socket, :games, game)}
  end

  # ---  Búsqueda en tiempo real ---
  @impl true
  def handle_event("search", %{"search_form" => params}, socket) do
    changeset = SearchForm.changeset(%SearchForm{}, params)

    games =
      if changeset.valid? do
        query = Ecto.Changeset.get_field(changeset, :query)
        Catalog.search_games(query)
      else
        Catalog.list_games()
      end

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> stream(:games, games, reset: true)}
  end

  @impl true
  def handle_event("add_view", %{"id" => id}, socket) do
    game = Catalog.get_game!(id)

    updated_game =
      game
      |> Ecto.Changeset.change(views: game.views + 1)
      |> PPhoenixLiveviewCourse.Repo.update!()

    {:noreply, stream_insert(socket, :games, updated_game)}
  end
end
