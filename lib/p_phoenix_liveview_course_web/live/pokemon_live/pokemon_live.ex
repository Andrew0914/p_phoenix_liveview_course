defmodule PPhoenixLiveviewCourseWeb.PokemonLive.Pokemon do
  @derive Jason.Encoder
  defstruct id: nil, name: "", type: nil, image_url: ""
end

defmodule PPhoenixLiveviewCourseWeb.PokemonLive.Player do
  @derive Jason.Encoder
  defstruct id: nil, name: "", pokemon: nil
end

defmodule PPhoenixLiveviewCourseWeb.PokemonLive do
  use PPhoenixLiveviewCourseWeb, :live_view
  alias PPhoenixLiveviewCourseWeb.PokemonLive.Pokemon
  alias PPhoenixLiveviewCourseWeb.PokemonLive.Player
  alias PPhoenixLiveviewCourseWeb.PokemonLive.PokemonComponents

  @battle_topic "pokemon_battle"

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe to synchronization topic
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PPhoenixLiveviewCourse.PubSub, @battle_topic)
    end

    {:ok, init_game_state(socket)}
  end

  @impl true
  def handle_event("choose_pokemon", %{"id" => pokemon_id}, socket) do
    # Prevent changing pokemon if battle result exists or countdown is running
    if is_nil(socket.assigns.battle_result) and is_nil(socket.assigns.countdown) do
      pokemon = socket.assigns.pokemons |> Enum.find(&(&1.id == String.to_integer(pokemon_id)))

      Phoenix.PubSub.broadcast(
        PPhoenixLiveviewCourse.PubSub,
        @battle_topic,
        {:pokemon_chosen, socket.id, pokemon}
      )
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("reset_game", _params, socket) do
    # Global broadcast to reset all players
    Phoenix.PubSub.broadcast(PPhoenixLiveviewCourse.PubSub, @battle_topic, :reset_game)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:pokemon_chosen, sender_id, pokemon}, socket) do
    socket = assign_player(socket, sender_id, pokemon)

    # Start countdown only when both players are set
    if socket.assigns.p1 && socket.assigns.p2 && is_nil(socket.assigns.countdown) do
      Process.send_after(self(), :tick_countdown, 1000)
      {:noreply, assign(socket, countdown: 3, show_results: false)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:tick_countdown, socket) do
    case socket.assigns.countdown do
      n when n > 1 ->
        Process.send_after(self(), :tick_countdown, 1000)
        {:noreply, assign(socket, countdown: n - 1)}

      _ ->
        # Battle calculation at the end of countdown
        socket = battle(socket)

        # Trigger JS event and reveal pokemons
        {:noreply,
         socket
         |> assign(countdown: 0, show_results: true)
         |> push_event("battle:start", socket.assigns.battle_result)}
    end
  end

  @impl true
  def handle_info(:reset_game, socket) do
    {:noreply, init_game_state(socket)}
  end

  # --- PRIVATE FUNCTIONS ---

  defp init_game_state(socket) do
    # Using full module names or aliases consistently to avoid expansion errors
    charmander = %Pokemon{id: 1, name: "Charmander", type: :fire, image_url: ~p"/images/charmander.png"}
    squirtle = %Pokemon{id: 2, name: "Squirtle", type: :water, image_url: ~p"/images/squirtle.png"}
    bulbasaur = %Pokemon{id: 3, name: "Bulbasaur", type: :grass, image_url: ~p"/images/bulbasaur.png"}

    socket
    |> assign(
      pokemons: [charmander, squirtle, bulbasaur],
      p1: nil,
      p2: nil,
      battle_result: nil,
      role: nil,
      countdown: nil,
      show_results: false
    )
  end

  defp battle(socket) do
    p1 = socket.assigns.p1
    p2 = socket.assigns.p2
    beats = %{fire: :grass, water: :fire, grass: :water}

    battle_result =
      cond do
        p1.pokemon.type == p2.pokemon.type ->
          %{status: :draw, winner: nil, loser: nil}

        Map.get(beats, p1.pokemon.type) == p2.pokemon.type ->
          %{status: :p1, winner: p1, loser: p2}

        true ->
          %{status: :p2, winner: p2, loser: p1}
      end

    socket |> assign(battle_result: battle_result)
  end

  defp maybe_assign_role(socket, sender_id, role) do
    if socket.id == sender_id, do: assign(socket, :role, role), else: socket
  end

  defp assign_player(socket, sender_id, pokemon) do
    cond do
      is_nil(socket.assigns.p1) ->
        socket
        |> assign(:p1, %Player{id: "p1", name: "Player 1", pokemon: pokemon})
        |> maybe_assign_role(sender_id, :p1)

      is_nil(socket.assigns.p2) ->
        socket
        |> assign(:p2, %Player{id: "p2", name: "Player 2", pokemon: pokemon})
        |> maybe_assign_role(sender_id, :p2)

      true -> socket
    end
  end
end
