defmodule PPhoenixLiveviewCourseWeb.PokemonLiveTest do
  use PPhoenixLiveviewCourseWeb.ConnCase
  import Phoenix.LiveViewTest

  alias PPhoenixLiveviewCourseWeb.PokemonLive.Pokemon

  @moduletag :pokemon

  describe "pokemon page initialization" do
    test "displays all pokemons on load" do
      {:ok, _view, html} = live(build_conn(), "/pokemon")

      assert html =~ "Charmander"
      assert html =~ "Squirtle"
      assert html =~ "Bulbasaur"
    end

    test "pokemon selection event works" do
      {:ok, view, _html} = live(build_conn(), "/pokemon")

      html = render_click(view, "choose_pokemon", %{"id" => "1"})

      assert is_binary(html)
    end
  end

  describe "complete battle flow" do
    test "battle result is determined after both players choose pokemon" do
      {:ok, view, _html} = live(build_conn(), "/pokemon")

      # Player 1 selecciona Charmander
      send(view.pid, {
        :pokemon_chosen,
        view.id,
        %Pokemon{id: 1, name: "Charmander", type: :fire, image_url: "/images/charmander.png"}
      })

      # Player 2 selecciona Squirtle
      send(view.pid, {
        :pokemon_chosen,
        "other-id",
        %Pokemon{id: 2, name: "Squirtle", type: :water, image_url: "/images/squirtle.png"}
      })

      Process.sleep(20)
      state = :sys.get_state(view.pid).socket.assigns

      assert state.p1 != nil
      assert state.p2 != nil
      assert state.battle_result != nil
      assert state.battle_result.status in [:p1, :p2, :draw]
    end

    test "shows battle button after both pokemons are chosen" do
      {:ok, view, _html} = live(build_conn(), "/pokemon")

      send(view.pid, {
        :pokemon_chosen,
        view.id,
        %Pokemon{id: 1, name: "Charmander", type: :fire, image_url: "/images/charmander.png"}
      })

      send(view.pid, {
        :pokemon_chosen,
        "other-id",
        %Pokemon{id: 2, name: "Squirtle", type: :water, image_url: "/images/squirtle.png"}
      })

      Process.sleep(20)
      page = render(view)

      assert page =~ "battle-button"
    end

    test "assigns players with correct roles" do
      {:ok, view, _html} = live(build_conn(), "/pokemon")

      send(view.pid, {
        :pokemon_chosen,
        view.id,
        %Pokemon{id: 1, name: "Charmander", type: :fire, image_url: "/images/charmander.png"}
      })

      send(view.pid, {
        :pokemon_chosen,
        "other-id",
        %Pokemon{id: 2, name: "Squirtle", type: :water, image_url: "/images/squirtle.png"}
      })

      Process.sleep(20)
      state = :sys.get_state(view.pid).socket.assigns

      assert state.p1.id == :p1
      assert state.p2.id == :p2
    end
  end
end
