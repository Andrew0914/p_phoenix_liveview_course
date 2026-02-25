# default value 21 -> http://localhost:4000/blackjack
# specific value -> http://localhost:4000/blackjack?winning_value=number

defmodule PPhoenixLiveviewCourseWeb.BlackjackLive do
  use PPhoenixLiveviewCourseWeb, :live_view

  @cards [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:game_title, "Blackjack ♥️♣️♠️♦️")
     |> assign(:winning_value, 21)
     |> init_game(), layout: {PPhoenixLiveviewCourseWeb.Layouts, :game}}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    winning_value =
      case Map.get(params, "winning_value") do
        nil ->
          21

        value ->
          case Integer.parse(value) do
            {num, _} when num > 0 -> num
            _ -> 21
          end
      end

    {:noreply, assign(socket, :winning_value, winning_value)}
  end

  @impl true
  def handle_event("draw", %{"count" => count}, socket) do
    {:noreply,
     socket
     |> draw_card(String.to_integer(count))
     |> cpu_draw_card(1)
     |> handle_winner_on_draw()}
  end

  @impl true
  def handle_event("stand", _params, socket) do
    {:noreply,
     socket
     |> cpu_draw_card(1)
     |> handle_winner_on_stand()}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply, init_game(socket)}
  end

  # =====================
  # PRIVATE
  # =====================

  defp init_game(socket) do
    [c1, c2, c3, c4] = Enum.take_random(@cards, 4)

    assign(socket,
      player: [c1, c2],
      cpu: [c3, c4],
      winner: nil
    )
  end

  defp points(cards), do: Enum.sum(cards)

  # -------- PLAYER --------

  defp draw_card(socket, count) do
    winning_value = socket.assigns.winning_value

    if points(socket.assigns.player) < winning_value do
      [card | _] = Enum.take_random(@cards, count)
      assign(socket, player: [card | socket.assigns.player])
    else
      put_flash(socket, :error, "Cannot take another card")
    end
  end

  # -------- CPU --------

  defp cpu_draw_card(socket, count) do
    winning_value = socket.assigns.winning_value

    if points(socket.assigns.cpu) < winning_value do
      [card | _] = Enum.take_random(@cards, count)
      assign(socket, cpu: [card | socket.assigns.cpu])
    else
      socket
    end
  end

  # -------- WINNER LOGIC --------

  defp handle_winner_on_draw(socket) do
    player_points = points(socket.assigns.player)
    cpu_points = points(socket.assigns.cpu)
    winning_value = socket.assigns.winning_value

    winner =
      cond do
        player_points > winning_value and cpu_points > winning_value -> :tie
        player_points > winning_value -> :cpu
        cpu_points > winning_value -> :player
        player_points == winning_value -> :player
        cpu_points == winning_value -> :cpu
        true -> nil
      end

    assign(socket, winner: winner)
  end

  defp handle_winner_on_stand(socket) do
    player_points = points(socket.assigns.player)
    cpu_points = points(socket.assigns.cpu)
    winning_value = socket.assigns.winning_value

    winner =
      cond do
        player_points > winning_value and cpu_points > winning_value -> :tie
        player_points > winning_value -> :cpu
        cpu_points > winning_value -> :player
        player_points > cpu_points -> :player
        player_points < cpu_points -> :cpu
        true -> :tie
      end

    assign(socket, winner: winner)
  end
end
