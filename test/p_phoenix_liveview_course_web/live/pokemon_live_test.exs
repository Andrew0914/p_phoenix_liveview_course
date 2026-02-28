defmodule PPhoenixLiveviewCourseWeb.PokemonLiveTest do
  use PPhoenixLiveviewCourseWeb.ConnCase

  describe "PokemonLive" do
    test "displays initial state with 3 available pokemon", %{conn: conn} do
      {:ok, view, html} = live(conn, "/pokemon")

      assert html =~ "Pokemon battle!"
      assert html =~ "Choose your Pokemon"
      assert html =~ "Charmander"
      assert html =~ "Squirtle"
      assert html =~ "Bulbasaur"

      # Battle area should be empty initially
      refute has_element?(view, ".countdown-overlay")
      refute has_element?(view, "button.reset-button")
    end

    test "two players choose pokemon and countdown triggers", %{conn: conn} do
      {:ok, view1, _html} = live(conn, "/pokemon")
      {:ok, view2, _html} = live(conn, "/pokemon")

      # Player 1 chooses Charmander (fire)
      choose_pokemon(view1, "1")

      # Player 1 should see "You" (not "Player 1") because they have role :p1
      assert render(view1) =~ "You"
      refute has_element?(view1, ".countdown-overlay")

      # Player 2 chooses Squirtle (water)
      choose_pokemon(view2, "2")

      # Both players should now see each other's pokemon
      # View1 sees: "You" (p1) and "Player 2" (p2)
      # View2 sees: "Player 1" (p1) and "You" (p2)
      assert render(view1) =~ "You"
      assert render(view1) =~ "Player 2"
      assert render(view2) =~ "Player 1"
      assert render(view2) =~ "You"

      # Countdown should be active
      assert has_element?(view1, ".countdown-overlay")
      assert has_element?(view2, ".countdown-overlay")
    end

    test "battle resolves after countdown and reset works", %{conn: conn} do
      {:ok, view1, _html} = live(conn, "/pokemon")
      {:ok, view2, _html} = live(conn, "/pokemon")

      # Setup: both players choose
      choose_pokemon(view1, "1")  # Charmander (fire)
      choose_pokemon(view2, "2")  # Squirtle (water)

      # Simulate countdown finishing (5 ticks) for both views
      simulate_countdown(view1, 5)
      simulate_countdown(view2, 5)

      # Battle should be resolved, countdown gone
      refute has_element?(view1, ".countdown-overlay")
      refute has_element?(view2, ".countdown-overlay")

      # Reset button should be visible
      assert has_element?(view1, "button.reset-button")
      assert has_element?(view2, "button.reset-button")

      # Trigger reset from player 1
      view1 |> element("button.reset-button") |> render_click()

      # Both should be back to initial state
      assert render(view1) =~ "Choose your Pokemon"
      assert render(view2) =~ "Choose your Pokemon"
      refute has_element?(view1, "button.reset-button")
      refute has_element?(view2, "button.reset-button")
    end
  end

  # Test helpers
  defp choose_pokemon(view, pokemon_id) do
    view |> element("[phx-value-id='#{pokemon_id}']") |> render_click()
  end

  defp simulate_countdown(view, seconds) do
    # Manually trigger countdown ticks without waiting real time
    Enum.each(1..seconds, fn _ ->
      send(view.pid, :countdown_tick)
      render(view)
    end)
  end
end
