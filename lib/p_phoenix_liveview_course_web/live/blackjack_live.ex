defmodule PPhoenixLiveviewCourseWeb.BlackjackLive do
  use PPhoenixLiveviewCourseWeb, :live_view

  @cards [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(game_title: "Blackjack ♥️♣️♠️♦️") |> init_deck(),
     layout: {PPhoenixLiveviewCourseWeb.Layouts, :game}}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    win_limit =
      case params["limit"] do
        nil -> 21
        limit_str ->
          case Integer.parse(limit_str) do
            {limit, ""} when limit > 0 -> limit
            _ -> 21
          end
      end

    {:noreply, socket |> assign(win_limit: win_limit) |> first_deal()}
  end

  @impl true
  def handle_event("draw", %{"count" => count}, socket) do
    {:noreply,
     socket
     |> draw_card(String.to_integer(count))
     |> cpu_draw_card(String.to_integer(count))
     |> handle_winner_on_draw()}
  end

  @impl true
  def handle_event("stand", _params, socket) do
    {:noreply, socket |> cpu_draw_card(1) |> handle_winner_on_stand()}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply, socket |> init_deck() |> first_deal()}
  end

  # Privates
  defp init_deck(socket) do
    socket |> assign(cards: @cards, player: [], cpu: [], winner: nil)
  end

  defp first_deal(socket) do
    [card1, card2, card3, card4] = Enum.take_random(@cards, 4)
    socket |> assign(player: [card1, card2], cpu: [card3, card4])
  end

  defp points(cards) do
    Enum.reduce(cards, 0, fn card, acc -> acc + card end)
  end

  defp draw_card(socket, count) do
    if points(socket.assigns.player) < socket.assigns.win_limit do
      [card1] = Enum.take_random(@cards, count)
      new_player_cards = [card1 | socket.assigns.player]

      socket |> assign(player: new_player_cards)
    else
      socket |> put_flash(:error, "Cannot take another card")
    end
  end

  defp cpu_draw_card(socket, count) do
    cpu_target = socket.assigns.win_limit - 4

    if points(socket.assigns.cpu) < cpu_target do
      [card1] = Enum.take_random(@cards, count)
      new_cpu_cards = [card1 | socket.assigns.cpu]

      socket |> assign(cpu: new_cpu_cards)
    else
      socket
    end
  end

  defp handle_winner_on_draw(socket) do
    player_points = points(socket.assigns.player)
    cpu_points = points(socket.assigns.cpu)
    win_limit = socket.assigns.win_limit

    winner =
      cond do
        player_points > win_limit and cpu_points > win_limit -> :tie
        player_points > win_limit -> :cpu
        cpu_points > win_limit -> :player
        true -> nil
      end

    socket |> assign(winner: winner)
  end

  defp handle_winner_on_stand(socket) do
    player_points = points(socket.assigns.player)
    cpu_points = points(socket.assigns.cpu)
    win_limit = socket.assigns.win_limit

    winner =
      cond do
        player_points > win_limit and cpu_points > win_limit -> :tie
        player_points > win_limit -> :cpu
        cpu_points > win_limit -> :player
        player_points > cpu_points -> :player
        player_points < cpu_points -> :cpu
        true -> :tie
      end

    socket |> assign(winner: winner)
  end
end
