defmodule PPhoenixLiveviewCourseWeb.GameLive.Show do
  use PPhoenixLiveviewCourseWeb, :live_view

  alias PPhoenixLiveviewCourse.Catalog
  alias PPhoenixLiveviewCourseWeb.GameLive.Tomatometer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    game = Catalog.get_game!(id)

    # Increment views only when the user is viewing the game details
    if socket.assigns.live_action == :show do
      {:ok, updated_game} = Catalog.update_game(game, %{views: game.views + 1})

      {:noreply,
       socket
       |> assign(:page_title, page_title(socket.assigns.live_action))
       |> assign(:game, updated_game)}
    else
      {:noreply,
       socket
       |> assign(:page_title, page_title(socket.assigns.live_action))
       |> assign(:game, game)}
    end
  end

  @impl true
  def handle_info({PPhoenixLiveviewCourseWeb.GameLive.FormComponent, {:saved, game}}, socket) do
    {:noreply,
    socket
    |> put_flash(:info, "Game updated successfully")
    |> assign(:game, game)}
  end

  defp page_title(:show), do: "Show Game"
  defp page_title(:edit), do: "Edit Game"
end
