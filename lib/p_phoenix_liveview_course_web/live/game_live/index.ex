defmodule PPhoenixLiveviewCourseWeb.GameLive.Index do
  use PPhoenixLiveviewCourseWeb, :live_view

  alias PPhoenixLiveviewCourse.Catalog
  alias PPhoenixLiveviewCourse.Catalog.Game
  alias PPhoenixLiveviewCourseWeb.GameLive.Tomatometer
  alias PPhoenixLiveviewCourseWeb.GameLive.SearchForm

  @impl true
  def mount(_params, _session, socket) do
    changeset = SearchForm.changeset(%SearchForm{}, %{})
    {:ok, socket
          |> assign(:form, to_form(changeset))
          |> stream(:games, Catalog.list_games())}
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
       query = Ecto.Changeset.get_field(changeset, :query)
        games = Catalog.search_games(query)

        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> stream(:games, games, reset: true)}
      else
        changeset = Map.put(changeset, :action, :validate)

        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> stream(:games, Catalog.list_games(), reset: true)}
      end
    end
end
