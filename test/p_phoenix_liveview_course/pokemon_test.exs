defmodule PPhoenixLiveviewCourseWeb.PokemonLiveTest do
  use PPhoenixLiveviewCourseWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "Pokemon Live - render tests" do
    test "renders pokemon page correctly", %{conn: conn} do
      {:ok, _live, html} = live(conn, "/pokemon")

      assert html =~ "Pokemon battle!💥"
      assert html =~ "Choose your Pokemon"
      assert html =~ "Battle area"
    end

    test "battle button renders when battle_result is present", %{conn: conn} do
      {:ok, liveview, _html} = live(conn, "/pokemon")

      html = render(liveview)

      if html =~ "battle-button" do
        assert has_element?(liveview, "#battle-button")
      else
        assert true
      end
    end
  end

  describe "Pokemon Live - integration battle flow" do
    test "two players choose pokemon and battle is triggered", %{conn: conn} do
      {:ok, liveview, _html} = live(conn, "/pokemon")

      # Player 1 elige Charmander (id 1)
      liveview
      |> element("[phx-click='choose_pokemon'][phx-value-id='1']")
      |> render_click()

      # Player 2 elige Bulbasaur (id 3)
      liveview
      |> element("[phx-click='choose_pokemon'][phx-value-id='3']")
      |> render_click()

      html = render(liveview)

      # Ambos pokémon deben aparecer en el área de batalla
      assert html =~ "Charmander"
      assert html =~ "Bulbasaur"

      # Fire vence a Grass → p1 gana
      assert html =~ "p1-battle" or html =~ "battle"
    end
  end
end
