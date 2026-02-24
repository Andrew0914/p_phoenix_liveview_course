defmodule PPhoenixLiveviewCourseWeb.GameLive.Tomatometer do
  use PPhoenixLiveviewCourseWeb, :live_component
  alias PPhoenixLiveviewCourseWeb.GameLive.GameComponent
  alias PPhoenixLiveviewCourse.Rating
  alias PPhoenixLiveviewCourse.Rating.Tomatoes

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_tomatoes_rating(assigns.game.id)}
  end

  @impl true
  def handle_event("on_tomatoe", %{"count" => count, "type" => type}, socket) do
    new_count = String.to_integer(count) + 1
    type = String.to_atom(type)

    case Rating.get_tomatoes_by_game(socket.assigns.game.id) do
      %Tomatoes{} = tomatoes ->
        {:noreply, update_tomatoes(socket, tomatoes, type, new_count)}

      nil ->
        {:noreply, assign_new_tomatoes(socket, type, new_count)}

      _error ->
        send(self(), {:flash, :error, "Cannot get tomatoes info"})

        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center gap-4">
      <GameComponent.tomatoe_button
        type={:good}
        count={@tomatoes.good}
        game_id={@game.id}
        on_tomatoe={{"on_tomatoe", @myself}}
      />
      <GameComponent.tomatoe_button
        type={:bad}
        count={@tomatoes.bad}
        game_id={@game.id}
        on_tomatoe={{"on_tomatoe", @myself}}
      />
      <GameComponent.tomatoes_score good={@tomatoes.good} bad={@tomatoes.bad} />
    </div>
    """
  end

  ## PRIVATES
  defp assign_tomatoes_rating(socket, game_id) do
    case Rating.get_tomatoes_by_game(game_id) do
      %Tomatoes{} = tomatoes ->
        socket |> assign(:tomatoes, tomatoes)

      _error ->
        send(self(), {:flash, :error, "Cannot get tomatoes info"})

        socket
        |> assign(:tomatoes, %{bad: 0, good: 0})
    end
  end

  defp assign_new_tomatoes(socket, type, count) do
    attrs = %{game_id: socket.assigns.game.id} |> Map.put(type, count)
    # since bad and good fields are required for change set
    attrs =
      if type == :good do
        Map.put(attrs, :bad, 0)
      else
        Map.put(attrs, :good, 0)
      end

    case Rating.create_tomatoes(attrs) do
      {:ok, tomatoes} ->
        socket |> assign(:tomatoes, tomatoes)

      _error ->
        send(self(), {:flash, :error, "Cannot create tomatoes info"})
        socket
    end
  end

  defp update_tomatoes(socket, tomatoes, type, count) do
    case Rating.update_tomatoes(tomatoes, Map.put(%{}, type, count)) do
      {:ok, updated_tomatoes} ->
        socket |> assign(:tomatoes, updated_tomatoes)

      _error ->
        send(self(), {:flash, :error, "Cannot update tomatoes info"})
        socket
    end
  end
end
