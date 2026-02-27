defmodule PPhoenixLiveviewCourseWeb.PokemonLiveTest do
  use PPhoenixLiveviewCourseWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "Pokemon Battle Integration" do
    test "loads the initial selection screen", %{conn: conn} do
      # Mounts the LiveView process on the given route
      {:ok, _view, html} = live(conn, "/pokemon")

      # Verifies the initial render state displays the main prompt
      assert html =~ "Choose your Pokemon"
      assert html =~ "Bulbasaur"
    end

    test "selects a pokemon and updates the interface", %{conn: conn} do
      # Mounts the LiveView process
      {:ok, view, _html} = live(conn, "/pokemon")

      # Triggers a click event on the specific pokemon container
      updated_html =
        view
        |> element("div[phx-value-id='1']")
        |> render_click()

      # Verifies the state reflects the user's selection
      assert updated_html =~ "Charmander"
    end

    test "executes a battle sequence", %{conn: conn} do
      # Mounts the LiveView process
      {:ok, view, _html} = live(conn, "/pokemon")

      # Simulates the user selecting a pokemon before battling
      view
      |> element("div[phx-value-id='2']")
      |> render_click()

      # Validates the battle area exists
      assert has_element?(view, "#battle-area")
    end
  end
end
