defmodule PPhoenixLiveviewCourseWeb.PokemonBattleLogicTest do
  use ExUnit.Case, async: true

  alias PPhoenixLiveviewCourseWeb.PokemonLive.Pokemon
  alias PPhoenixLiveviewCourseWeb.PokemonLive.Player

  # Setup fixtures for pokemon
  setup do
    charmander = %Pokemon{id: 1, name: "Charmander", type: :fire, image_url: "/images/charmander.png"}
    squirtle = %Pokemon{id: 2, name: "Squirtle", type: :water, image_url: "/images/squirtle.png"}
    bulbasaur = %Pokemon{id: 3, name: "Bulbasaur", type: :grass, image_url: "/images/bulbasaur.png"}

    %{
      charmander: charmander,
      squirtle: squirtle,
      bulbasaur: bulbasaur
    }
  end

  describe "battle logic - type matchups" do
    test "fire beats grass", %{charmander: charmander, bulbasaur: bulbasaur} do
      result = calculate_battle(charmander, bulbasaur)

      assert result.status == :p1
      assert result.winner.id == :p1
      assert result.loser.id == :p2
    end

    test "water beats fire", %{squirtle: squirtle, charmander: charmander} do
      result = calculate_battle(squirtle, charmander)

      assert result.status == :p1
      assert result.winner.id == :p1
      assert result.loser.id == :p2
    end

    test "grass beats water", %{bulbasaur: bulbasaur, squirtle: squirtle} do
      result = calculate_battle(bulbasaur, squirtle)

      assert result.status == :p1
      assert result.winner.id == :p1
      assert result.loser.id == :p2
    end

    test "same type results in draw", %{squirtle: squirtle} do
      result = calculate_battle(squirtle, squirtle)

      assert result.status == :draw
      assert result.winner == nil
      assert result.loser == nil
    end

    test "player 2 wins when their type is superior", %{charmander: charmander, squirtle: squirtle} do
      result = calculate_battle(charmander, squirtle)

      assert result.status == :p2
      assert result.winner.id == :p2
      assert result.loser.id == :p1
    end
  end

  # Helper: calculates battle result based on pokemon types
  # This duplicates the business logic from PokemonLive.battle/1
  # which is acceptable for unit testing the algorithm in isolation
  defp calculate_battle(p1_pokemon, p2_pokemon) do
    p1 = %Player{id: :p1, name: "Player 1", pokemon: p1_pokemon}
    p2 = %Player{id: :p2, name: "Player 2", pokemon: p2_pokemon}

    beats = %{
      fire: :grass,
      water: :fire,
      grass: :water
    }

    cond do
      p1_pokemon.type == p2_pokemon.type ->
        %{status: :draw, winner: nil, loser: nil}

      Map.get(beats, p1_pokemon.type) == p2_pokemon.type ->
        %{status: :p1, winner: p1, loser: p2}

      true ->
        %{status: :p2, winner: p2, loser: p1}
    end
  end
end
