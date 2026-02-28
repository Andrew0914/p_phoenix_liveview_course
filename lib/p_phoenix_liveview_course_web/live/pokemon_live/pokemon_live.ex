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
    # Subscribe listener on connected mount
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PPhoenixLiveviewCourse.PubSub, @battle_topic)
    end

    {:ok, socket |> init_pokemons()}
  end

  @impl true
  def handle_event("choose_pokemon", %{"id" => pokemon_id}, socket) do
    pokemon = socket.assigns.pokemons |> Enum.find(&(&1.id == String.to_integer(pokemon_id)))

    Phoenix.PubSub.broadcast(
      PPhoenixLiveviewCourse.PubSub,
      @battle_topic,
      {:pokemon_chosen, socket.id, pokemon}
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("restart-game", _params, socket) do
    Phoenix.PubSub.broadcast(
      PPhoenixLiveviewCourse.PubSub,
      @battle_topic,
      {:game_restarted}
    )

    {:noreply, socket}
  end

  @impl true
  def handle_info({:pokemon_chosen, sender_id, pokemon}, socket) do
    socket = socket |> assign_player(sender_id, pokemon)

    if socket.assigns.p1 && socket.assigns.p2 do
      socket = socket |> battle()

      {:noreply,
       socket
       |> push_event("battle:start", socket.assigns.battle_result)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:game_restarted}, socket) do
    {:noreply,
      socket
      |> assign(p1: nil, p2: nil, battle_result: nil, role: nil )}
  end

  #  PRIVATES
  defp init_pokemons(socket) do
    charmander = %Pokemon{
      id: 1,
      name: "Charmander",
      type: :fire,
      image_url: ~p"/images/charmander.png"
    }

    squirtle = %Pokemon{
      id: 2,
      name: "Squirtle",
      type: :water,
      image_url: ~p"/images/squirtle.png"
    }

    bulbasaur = %Pokemon{
      id: 3,
      name: "Bulbasaur",
      type: :grass,
      image_url: ~p"/images/bulbasaur.png"
    }

    available_pokemons = [charmander, squirtle, bulbasaur]

    socket
    |> assign(pokemons: available_pokemons, p1: nil, p2: nil, battle_result: nil, role: nil)
  end

  defp battle(socket) do
    p1_pokemon = socket.assigns.p1.pokemon
    p2_pokemon = socket.assigns.p2.pokemon

    beats = %{
      fire: :grass,
      water: :fire,
      grass: :water
    }

    battle_result =
      cond do
        p1_pokemon.type == p2_pokemon.type ->
          %{status: :draw, winner: nil, loser: nil}

        Map.get(beats, p1_pokemon.type) == p2_pokemon.type ->
          %{status: :p1, winner: socket.assigns.p1, loser: socket.assigns.p2}

        true ->
          %{status: :p2, winner: socket.assigns.p2, loser: socket.assigns.p1}
      end

    socket |> assign(battle_result: battle_result)
  end

  defp maybe_assign_role(socket, sender_id, role) do
    if socket.id == sender_id do
      socket |> assign(:role, role)
    else
      socket
    end
  end

  defp assign_player(socket, sender_id, pokemon) do
    cond do
      socket.assigns.p1 == nil ->
        socket
        |> assign(:p1, %Player{id: :p1, name: "Player 1", pokemon: pokemon})
        |> maybe_assign_role(sender_id, :p1)

      socket.assigns.p2 == nil ->
        socket
        |> assign(:p2, %Player{id: :p2, name: "Player 2", pokemon: pokemon})
        |> maybe_assign_role(sender_id, :p2)

      true ->
        socket
    end
  end
end
