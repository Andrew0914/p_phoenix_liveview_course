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
     # valor por defecto
     |> assign(:winning_value, 21)
     |> init_deck()
     |> first_deal(), layout: {PPhoenixLiveviewCourseWeb.Layouts, :game}}
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
    {:noreply,
     socket
     |> init_deck()
     |> first_deal()
     |> assign(:winner, nil)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    winning_value =
      case Map.get(params, "winning_value") do
        nil ->
          21

        value ->
          case Integer.parse(value) do
            {num, _} -> num
            :error -> 21
          end
      end

    {:noreply, assign(socket, :winning_value, winning_value)}
  end

  # PRIVATE

  defp init_deck(socket) do
    assign(socket, cards: @cards, player: [], cpu: [], winner: nil)
  end

  defp first_deal(socket) do
    [card1, card2, card3, card4] = Enum.take_random(@cards, 4)

    assign(socket,
      player: [card1, card2],
      cpu: [card3, card4],
      cards: @cards -- [card1, card2, card3, card4]
    )
  end

  defp points(cards) do
    Enum.reduce(cards, 0, fn card, acc -> acc + card end)
  end

  defp draw_card(socket, count) do
    if points(socket.assigns.player) < socket.assigns.winning_value do
      case Enum.take_random(socket.assigns.cards, count) do
        [card | _] ->
          new_player_cards = [card | socket.assigns.player]
          new_deck = socket.assigns.cards -- [card]
          assign(socket, player: new_player_cards, cards: new_deck)

        [] ->
          put_flash(socket, :error, "No more cards in the deck")
      end
    else
      put_flash(socket, :error, "Cannot take another card")
    end
  end

  defp cpu_draw_card(socket, count) do
    if points(socket.assigns.cpu) < 17 do
      case Enum.take_random(socket.assigns.cards, count) do
        [card | _] ->
          new_cpu_cards = [card | socket.assigns.cpu]
          new_deck = socket.assigns.cards -- [card]
          assign(socket, cpu: new_cpu_cards, cards: new_deck)

        [] ->
          socket
      end
    else
      socket
    end
  end

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
