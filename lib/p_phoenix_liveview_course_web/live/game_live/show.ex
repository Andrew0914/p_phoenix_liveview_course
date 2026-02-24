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
    {:ok, game} = Catalog.increment_views(game)

    {:noreply,
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:game, game)}
  end


  @impl true
  def handle_info({:flash, type, message}, socket) do
    {:noreply, socket |> put_flash(type, message)}
  end

  defp page_title(:show), do: "Show Game"
  defp page_title(:edit), do: "Edit Game"
end
