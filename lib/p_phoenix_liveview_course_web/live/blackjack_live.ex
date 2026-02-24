defmodule PPhoenixLiveviewCourseWeb.BlackjackLive do
  use PPhoenixLiveviewCourseWeb, :live_view

  @cards [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]
  @default_winning_value 21

  @impl true
  def mount(_params, _session, socket) do
    winning_value = get_winning_value(_params)

    {:ok, socket
    |> assign(game_title: "Blackjack ♥️♣️♠️♦️")
    |> assign(winning_value: winning_value)
    |> init_deck()
    |> first_deal(),
    layout: {PPhoenixLiveviewCourseWeb.Layouts, :game}}
  end

  @impl true
  def handle_params(params, _url, socket) do
    winning_value = get_winning_value(params)
    case socket.assigns do
      %{winning_value: ^winning_value} ->
        # Mismo valor, no hacemos nada
        {:noreply, socket}

      %{} ->
        {:noreply, socket
        |> assign(winning_value: winning_value)
        |> init_deck()
        |> first_deal()
        |> put_flash(:info, "Winning value changed to #{winning_value}")}
    end
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply,
    socket
    |> init_deck()
    |> first_deal()
    |> put_flash(:info, "Game reset! New game started.")}
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

  # Privates
  defp get_winning_value(params) do
    case params do
      %{"winning_value" => value} ->
        case Integer.parse(value) do
          {num, ""} when num > 0 -> num
          _ -> @default_winning_value
        end
      _ ->
        @default_winning_value
    end
  end

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
    winning_value = socket.assigns.winning_value

    if points(socket.assigns.player) < winning_value do
      [card1] = Enum.take_random(@cards, count)
      new_player_cards = [card1 | socket.assigns.player]

      socket |> assign(player: new_player_cards)
    else
      socket |> put_flash(:error, "Cannot take another card (you have #{winning_value} or more)")  # <--- MODIFICAR mensaje
    end
  end

  defp cpu_draw_card(socket, count) do
    if points(socket.assigns.cpu) < 17 do
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
    winning_value = socket.assigns.winning_value

    winner =
      cond do
        player_points > winning_value -> :cpu
        cpu_points > winning_value -> :player
        true -> nil
      end

    socket |> assign(winner: winner)
  end

  defp handle_winner_on_stand(socket) do
    player_points = points(socket.assigns.player)
    cpu_points = points(socket.assigns.cpu)
    winning_value = socket.assigns.winning_value  # <--- AGREGAR ESTA LÍNEA

    winner =
      cond do
        player_points > winning_value -> :cpu  # <--- MODIFICAR: 21 -> winning_value
        cpu_points > winning_value -> :player  # <--- MODIFICAR: 21 -> winning_value
        player_points > cpu_points -> :player
        player_points < cpu_points -> :cpu
        true -> :tie
      end

    socket |> assign(winner: winner)
  end
end
