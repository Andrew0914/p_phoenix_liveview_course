defmodule PPhoenixLiveviewCourseWeb.BlackjackLiveTest do
  use PPhoenixLiveviewCourseWeb.ConnCase
  alias PPhoenixLiveviewCourseWeb.GameLive.Tomatometer
  alias PPhoenixLiveviewCourse.CatalogFixtures
  alias PPhoenixLiveviewCourse.RatingFixtures

  describe "Tomatometer - unit tests" do
    # static test
    test "renders tomatometer" do
      tomatometer_html = render_component(Tomatometer, game: %{id: 1}, id: "tomatometer-1")

      assert tomatometer_html =~ "🍎"
      assert tomatometer_html =~ "🍏"
    end
  end

  describe "Tomatometer - integration tests" do
    setup %{conn: conn} do
      game = CatalogFixtures.game_fixture(%{name: "Fornite", description: "Luxury game"})
      RatingFixtures.tomatoes_fixture(%{game_id: game.id, bad: 0, good: 0})
      {:ok, conn: conn, game: game}
    end

    # integration test
    test "renders tomatometer with dynamic data", %{conn: conn, game: game} do
      conn = get(conn, "/games/#{game.id}")
      {:ok, liveview, _html} = live(conn)

      liveview |> element("[data-testid='tomatoe-button']:first-child") |> render_click()
      html = liveview |> element("[data-testid='tomatoe-button']:first-child") |> render_click()

      {:ok, document} = Floki.parse_document(html)

      good_button =
        document |> Floki.find("[data-testid='tomatoe-button']:first-child") |> Floki.raw_html()

      assert good_button =~ "2"
    end
  end
end
