defmodule PPhoenixLiveviewCourseWeb.GameComponentsTest do
  use PPhoenixLiveviewCourseWeb.ConnCase
  alias PPhoenixLiveviewCourseWeb.GameLive.GameComponent

  describe "GameComponent.tomatoe_button" do
    test "should render the right template" do
      assigns = %{type: :bad, count: 0, game_id: 1, on_tomatoe: "on_tomatoe"}

      template = ~H"""
      <GameComponent.tomatoe_button
        type={@type}
        count={@count}
        game_id={@game_id}
        on_tomatoe={@on_tomatoe}
      />
      """

      html = rendered_to_string(template)

      assert html ==
               "<button phx-click=\"on_tomatoe\" phx-value-type=\"bad\" phx-value-count=\"0\" class=\"tomatoe-button\" data-testid=\"tomatoe-button\">\n  <span>0</span>\n  <span>🍎</span>\n</button>"
    end

    test "should render the tomate based on the type" do
      assigns = %{type: :bad, count: 0, game_id: 1, on_tomatoe: "on_tomatoe"}

      template = ~H"""
      <GameComponent.tomatoe_button
        type={@type}
        count={@count}
        game_id={@game_id}
        on_tomatoe={@on_tomatoe}
      />
      """

      html = rendered_to_string(template)

      assert html =~ "🍎"
      refute html =~ "🍏"
    end
  end

  describe "GameComponent.tomatoes_score" do
    test "should calculate and display correct percentages for equal votes" do
      tomatoe_score_component = render_component(&GameComponent.tomatoes_score/1, bad: 5, good: 5)

      {:ok, document} = Floki.parse_document(tomatoe_score_component)
      good = document |> Floki.find("[data-testid='good-score']") |> Floki.text()
      bad = document |> Floki.find("[data-testid='bad-score']") |> Floki.text()

      assert good == "50.0%"
      assert bad == "50.0%"
    end

    test "should calculate 70% good and 30% bad for 7-3 split" do
      tomatoe_score_component = render_component(&GameComponent.tomatoes_score/1, good: 7, bad: 3)

      {:ok, document} = Floki.parse_document(tomatoe_score_component)
      good = document |> Floki.find("[data-testid='good-score']") |> Floki.text()
      bad = document |> Floki.find("[data-testid='bad-score']") |> Floki.text()

      assert good == "70.0%"
      assert bad == "30.0%"
    end

    test "should handle 0% good when all votes are bad" do
      tomatoe_score_component = render_component(&GameComponent.tomatoes_score/1, good: 0, bad: 10)

      {:ok, document} = Floki.parse_document(tomatoe_score_component)
      good = document |> Floki.find("[data-testid='good-score']") |> Floki.text()
      bad = document |> Floki.find("[data-testid='bad-score']") |> Floki.text()

      # When there are votes (total > 0), percentage returns float with 1 decimal
      assert good == "0.0%"
      assert bad == "100.0%"
    end

    test "should handle 100% good when all votes are good" do
      tomatoe_score_component = render_component(&GameComponent.tomatoes_score/1, good: 10, bad: 0)

      {:ok, document} = Floki.parse_document(tomatoe_score_component)
      good = document |> Floki.find("[data-testid='good-score']") |> Floki.text()
      bad = document |> Floki.find("[data-testid='bad-score']") |> Floki.text()

      assert good == "100.0%"
      # When there are votes (total > 0), percentage returns float with 1 decimal
      assert bad == "0.0%"
    end

    test "should handle edge case with no votes (0 good, 0 bad)" do
      tomatoe_score_component = render_component(&GameComponent.tomatoes_score/1, good: 0, bad: 0)

      {:ok, document} = Floki.parse_document(tomatoe_score_component)
      good = document |> Floki.find("[data-testid='good-score']") |> Floki.text()
      bad = document |> Floki.find("[data-testid='bad-score']") |> Floki.text()

      assert good == "0%"
      assert bad == "0%"
    end
  end
end
