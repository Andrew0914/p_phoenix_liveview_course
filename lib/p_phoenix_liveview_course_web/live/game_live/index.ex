defmodule PPhoenixLiveviewCourseWeb.GameLive.Index do
  use PPhoenixLiveviewCourseWeb, :live_view

  alias PPhoenixLiveviewCourse.Catalog
  alias PPhoenixLiveviewCourse.Catalog.Game
  alias PPhoenixLiveviewCourseWeb.GameLive.Tomatometer
  alias PPhoenixLiveviewCourseWeb.GameLive.SearchForm

@impl true
def mount(_params, _session, socket) do
  # Crear cambioset vacío para el formulario de búsqueda
  search_changeset = SearchForm.changeset(%SearchForm{})
  games = Catalog.list_games()
  has_results? = length(games) > 0  # <--- AGREGAR ESTA LÍNEA

  {:ok,
   socket
   |> assign(search_changeset: search_changeset)
   |> assign(query: nil)
   |> assign(has_results?: has_results?)  # <--- AGREGAR ESTA LÍNEA
   |> stream(:games, games)}
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

@impl true
def handle_event("search", %{"search_form" => search_params}, socket) do
  changeset = SearchForm.changeset(%SearchForm{}, search_params)

  if changeset.valid? do
    query = search_params["query"]
    # Realizar la búsqueda
    games = Catalog.search_games(query)
    has_results? = length(games) > 0  # <--- AGREGAR ESTA LÍNEA
    {:noreply,
     socket
     |> assign(query: query)
     |> assign(has_results?: has_results?)  # <--- AGREGAR ESTA LÍNEA
     |> assign(search_changeset: changeset)
     |> stream(:games, games, reset: true)}
  else
    # Si no es válido (menos de 3 caracteres), mostrar todos los juegos
    games = Catalog.list_games()
    has_results? = length(games) > 0  # <--- AGREGAR ESTA LÍNEA
    {:noreply,
     socket
     |> assign(query: nil)
     |> assign(has_results?: has_results?)  # <--- AGREGAR ESTA LÍNEA
     |> assign(search_changeset: changeset)
     |> stream(:games, games, reset: true)}
  end
end

@impl true
def handle_event("clear_search", _params, socket) do
  empty_changeset = SearchForm.changeset(%SearchForm{}, %{query: ""})
  games = Catalog.list_games()
  has_results? = length(games) > 0  # <--- AGREGAR ESTA LÍNEA

  {:noreply,
   socket
   |> assign(query: nil)
   |> assign(has_results?: has_results?)  # <--- AGREGAR ESTA LÍNEA
   |> assign(search_changeset: empty_changeset)
   |> stream(:games, games, reset: true)}
end
end
