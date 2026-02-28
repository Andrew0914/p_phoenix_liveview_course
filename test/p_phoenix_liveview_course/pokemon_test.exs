defmodule PPhoenixLiveviewCourseWeb.PokemonLiveTest do
  use PPhoenixLiveviewCourseWeb.ConnCase
  import Phoenix.LiveViewTest

  # Test 1: Verification of Privacy (Fog of War)
  # Ensures that the opponent sees a mystery card and not the specific pokemon name chosen by the other player
  test "opponent cannot see chosen pokemon during countdown", %{conn: conn} do
    {:ok, view1, _html} = live(conn, "/pokemon")
    {:ok, view2, _html} = live(conn, "/pokemon")

    render_click(view1, "choose_pokemon", %{"id" => "1"})

    battle_area_html =
      view2
      |> element("#battle-area")
      |> render()

    assert battle_area_html =~ "mystery-card"
    refute battle_area_html =~ "Charmander"
  end

  # Test 2: Countdown and Battle Logic
  # Verifies that manual ticks advance the counter and trigger the battle result when reaching zero
  test "countdown starts when both players choose and finishes correctly", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/pokemon")

    render_click(view, "choose_pokemon", %{"id" => "1"})
    render_click(view, "choose_pokemon", %{"id" => "3"})

    assert render(view) =~ "3"

    send(view.pid, :tick_countdown)
    send(view.pid, :tick_countdown)
    send(view.pid, :tick_countdown)

    html = render(view)
    assert html =~ "Play Again"
    assert html =~ "Ganó"
  end

  # Test 3: Synchronized Reset (PubSub)
  # Ensures that when one player resets the game, the state is updated for all connected clients
  test "resetting the game synchronizes all connected players", %{conn: conn} do
    {:ok, view1, _html} = live(conn, "/pokemon")
    {:ok, view2, _html} = live(conn, "/pokemon")

    render_click(view1, "choose_pokemon", %{"id" => "1"})
    render_click(view2, "choose_pokemon", %{"id" => "2"})

    render_click(view1, "reset_game")

    assert render(view1) =~ "Choose your Pokemon"
    assert render(view2) =~ "Choose your Pokemon"

    refute render(view2) =~ "mystery-card"
  end
end
