defmodule PPhoenixLiveviewCourseWeb.GameLive.ViewsComponent do
  use PPhoenixLiveviewCourseWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="views-scoreboard">
      <span class="views-icon">👁️</span>
      <div class="views-count">
        <span><%= @game.views %></span>
        <span class="views-label">views</span>
      </div>
    </div>
    """
  end
end
