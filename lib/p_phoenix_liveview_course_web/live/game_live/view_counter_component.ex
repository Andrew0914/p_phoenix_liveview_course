defmodule PPhoenixLiveviewCourseWeb.GameLive.ViewCounterComponent do
  use Phoenix.Component

  attr :views, :integer, required: true
  attr :class, :string, default: ""
  attr :animate, :boolean, default: true


  def render(assigns) do
    ~H"""
    <div class={"view-counter-container #{@class}"}>

      <div class="view-number-wrapper">
        <span
          id={if @animate, do: "view-animate-#{@views}", else: "static-view"}
          class={["view-number-text", !@animate && "no-animate"]}
        >
          {format_views(@views)}
        </span>
      </div>

      <span class="view-label">Views</span>
    </div>
    """
  end

  defp format_views(n) when n >= 1_000_000, do: "#{Float.round(n / 1_000_000, 1)}M"
  defp format_views(n) when n >= 1_000, do: "#{Float.round(n / 1_000, 1)}K"
  defp format_views(n), do: "#{n}"
end
