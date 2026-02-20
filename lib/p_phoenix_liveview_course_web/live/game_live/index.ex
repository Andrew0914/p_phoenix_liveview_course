defmodule PPhoenixLiveviewCourseWeb.GameLive.Index do
  use PPhoenixLiveviewCourseWeb, :live_view

  alias PPhoenixLiveviewCourse.Catalog
  alias PPhoenixLiveviewCourse.Catalog.Game
  alias PPhoenixLiveviewCourseWeb.GameLive.Tomatometer

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:results, Catalog.list_games())}
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
  def handle_event("search", %{"search_form" => %{"query" => query}}, socket) do
    results = Catalog.search_games(query)
    {:noreply, assign(socket, :results, results)}
  end
end
