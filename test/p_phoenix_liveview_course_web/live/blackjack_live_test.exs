defmodule PPhoenixLiveviewCourseWeb.BlackjackLiveTest do
  use PPhoenixLiveviewCourseWeb.ConnCase

  describe "BlackjackLive" do
    test "should render first deal with", %{conn: conn} do
      conn = get(conn, "/blackjack")
      assert html_response(conn, 200) =~ "Blackjack ♥️♣️♠️♦️"

      {:ok, liveview, _html} = live(conn)

      content = render(liveview)
      {:ok, document} = Floki.parse_document(content)
      player_cards = document |> Floki.find("[data-testid='player-cards'] span")
      cpu_cards = document |> Floki.find("[data-testid='cpu-cards'] span")

      assert length(player_cards) == 2
      assert length(cpu_cards) == 2
    end
  end
end
