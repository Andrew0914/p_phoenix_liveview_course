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

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> init_pokemons()}
  end

  @impl true
  def handle_event("choose_pokemon", %{"id" => pokemon_id}, socket) do
    # YOU
    p1_pokemon =
      Enum.find(socket.assigns.pokemons, &(&1.id == String.to_integer(pokemon_id)))

    # CPU
    p2_pokemon = random_pokemon(socket)

    battle_socket =
      socket
      |> assign_player_1(p1_pokemon)
      |> assign_player_2(p2_pokemon)
      |> battle()

    {:noreply,
     battle_socket
     |> push_event("battle:start", battle_socket.assigns.battle_result)}
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
    socket |> assign(pokemons: available_pokemons, p1: nil, p2: nil, battle_result: nil)
  end

  defp random_pokemon(socket) do
    Enum.random(socket.assigns.pokemons)
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

  defp assign_player_1(socket, pokemon) do
    socket
    |> assign(p1: %Player{id: :p1, name: "Player 1", pokemon: pokemon})
  end

  defp assign_player_2(socket, pokemon) do
    socket
    |> assign(p2: %Player{id: :p2, name: "Player 2", pokemon: pokemon})
  end
end
