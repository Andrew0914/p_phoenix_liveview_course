defmodule PPhoenixLiveviewCourseWeb.GameLive.Show do
  use PPhoenixLiveviewCourseWeb, :live_view

  alias PPhoenixLiveviewCourse.Catalog
  alias PPhoenixLiveviewCourseWeb.GameLive.Tomatometer
  alias PPhoenixLiveviewCourseWeb.GameLive.ViewCounterComponent

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PPhoenixLiveviewCourse.PubSub, "game_views")
    end
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    game =
      if connected?(socket) do
        {:ok, updated_game} = Catalog.increment_game_views(id)
        updated_game
      else
        Catalog.get_game!(id)
      end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:game, Catalog.get_game!(id))}
  end

  @impl true
  def handle_info({:game_updated, updated_game}, socket) do
    if updated_game.id == socket.assigns.game.id do
      {:noreply, assign(socket, :game, updated_game)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:flash, type, message}, socket) do
    {:noreply, socket |> put_flash(type, message)}
  end

  defp page_title(:show), do: "Show Game"
  defp page_title(:edit), do: "Edit Game"
end
