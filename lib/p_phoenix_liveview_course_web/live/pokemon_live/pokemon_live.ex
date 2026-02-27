defmodule PPhoenixLiveviewCourseWeb.PokemonLive.Pokemon do
  @derive Jason.Encoder
  defstruct name: "", type: nil, image_url: "", id: nil
end

defmodule PPhoenixLiveviewCourseWeb.PokemonLive do
  use PPhoenixLiveviewCourseWeb, :live_view
  alias PPhoenixLiveviewCourseWeb.PokemonLive.Pokemon
  alias PPhoenixLiveviewCourseWeb.PokemonLive.PokemonComponent

  @battle_topic "pokemon_battle"

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe listener
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PPhoenixLiveviewCourse.PubSub, "pokemon_battle")
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
  def handle_event("reset_game", _params, socket) do
    Phoenix.PubSub.broadcast(
      PPhoenixLiveviewCourse.PubSub,
      @battle_topic,
      :reset_game
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("start_battle", _params, socket) do
    if socket.assigns.p1_pokemon && socket.assigns.p2_pokemon do
      # Process.send_after(self(), :countdown_tick, 1000)
      Phoenix.PubSub.broadcast(
        PPhoenixLiveviewCourse.PubSub,
        @battle_topic,
        :start_battle
      )

      {:noreply, socket}

      {:noreply,
       socket
       |> assign(:countdown, 3)
       |> assign(:result, nil)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:pokemon_chosen, sender_id, pokemon}, socket) do
    socket =
      cond do
        socket.assigns.p1_pokemon == nil ->
          socket
          |> assign(:p1_pokemon, pokemon)
          |> maybe_assign_player(sender_id, :p1)

        socket.assigns.p2_pokemon == nil ->
          socket
          |> assign(:p2_pokemon, pokemon)
          |> maybe_assign_player(sender_id, :p2)

        true ->
          socket
      end

    if socket.assigns.p1_pokemon && socket.assigns.p2_pokemon do
      result =
        battle(socket.assigns.p1_pokemon, socket.assigns.p2_pokemon)

      {:noreply,
       socket
       |> assign(:pending_result, result)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:reset_game, socket) do
    {:noreply,
     socket
     |> assign(p1_pokemon: nil)
     |> assign(p2_pokemon: nil)
     |> assign(result: nil)
     |> assign(:countdown, nil)}
  end

  @impl true
  def handle_info(:countdown_tick, socket) do
    cond do
      socket.assigns.countdown > 1 ->
        Process.send_after(self(), :countdown_tick, 1000)

        {:noreply, assign(socket, :countdown, socket.assigns.countdown - 1)}

      socket.assigns.countdown == 1 ->
        result = socket.assigns.pending_result

        payload =
          build_battle_payload(
            socket.assigns.p1_pokemon,
            socket.assigns.p2_pokemon,
            result
          )

        {:noreply,
         socket
         |> assign(:countdown, 0)
         |> assign(:result, result)
         |> assign(:pending_result, nil)
         |> push_event("battle:start", payload)}

      true ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:start_battle, socket) do
    Process.send_after(self(), :countdown_tick, 1000)

    {:noreply,
     socket
     |> assign(:countdown, 3)
     |> assign(:result, nil)}
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
    |> assign(
      pokemons: available_pokemons,
      p1_pokemon: nil,
      p2_pokemon: nil,
      result: nil,
      countdown: nil,
      player: nil,
      pending_result: nil
    )
  end

  defp random_pokemon(socket) do
    Enum.random(socket.assigns.pokemons)
  end

  defp battle(p1_pokemon, p2_pokemon) do
    cond do
      p1_pokemon.type == :fire && p2_pokemon.type == :grass -> {:p1, :p2}
      p1_pokemon.type == :water && p2_pokemon.type == :fire -> {:p1, :p2}
      p1_pokemon.type == :grass && p2_pokemon.type == :water -> {:p1, :p2}
      p1_pokemon.type == p2_pokemon.type -> :draw
      true -> {:p2, :p1}
    end
  end

  defp maybe_assign_player(socket, sender_id, role) do
    if socket.id == sender_id do
      assign(socket, :player, role)
    else
      socket
    end
  end

  defp build_battle_payload(p1_pokemon, p2_pokemon, result) do
    case result do
      :draw ->
        %{status: :draw, winner: nil, loser: nil}

      {:p1, :p2} ->
        %{
          status: :p1,
          winner: %{player: :p1, pokemon: p1_pokemon},
          loser: %{player: :p2, pokemon: p2_pokemon}
        }

      {:p2, :p1} ->
        %{
          status: :p2,
          winner: %{player: :p2, pokemon: p2_pokemon},
          loser: %{player: :p1, pokemon: p1_pokemon}
        }
    end
  end
end
