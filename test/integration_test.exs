defmodule PPhoenixLiveviewCourseWeb.IntegrationTest do
  use PPhoenixLiveviewCourseWeb.ConnCase
  import Phoenix.LiveViewTest

  # -----------------------------
  #  Games Formulario
  # -----------------------------
  describe "Games form integration" do
    test "Crea un nuevo juego a través del formulario.", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/games")

      # Abrir formulario
      assert index_live |> element("a", "New Game") |> render_click() =~ "New Game"

      # Intento inválido
      assert index_live
             |> form("#game-form", game: %{name: "", description: "", unit_price: nil, sku: nil})
             |> render_change() =~ "can&#39;t be blank"

      # Envío válido
      assert index_live
             |> form("#game-form", game: %{name: "Pikachu Battle", description: "Pokemon game", unit_price: 99.9, sku: 123})
             |> render_submit()

      html = render(index_live)
      assert html =~ "Game created successfully"
      assert html =~ "Pikachu Battle"
    end
  end

  # -----------------------------
  #  Pokémon
  # -----------------------------
  describe "Pokemon integration" do
    test "pokemon battle triggers countdown and result", %{conn: conn} do
      {:ok, liveview, _html} = live(conn, "/pokemon")

      # Simular elección de Pokémon
      render_click(element(liveview, "#1-pokemon"))
      render_click(element(liveview, "#2-pokemon"))

      # Enviar evento battle directamente
      render_click(element(liveview, "#battle-button"))

      assert render(liveview) =~ "battle-area"
      assert liveview |> element("#battle-area") |> render() =~ "battle"
    end
  end

  # -----------------------------
  #  Blackjack
  # -----------------------------
  describe "Blackjack integration" do
    test "El jugador roba una carta y la CPU también puede robar", %{conn: conn} do
      {:ok, liveview, _html} = live(conn, "/blackjack")

      render_click(element(liveview, "button[phx-click='draw']"))

      content = render(liveview)
      {:ok, document} = Floki.parse_document(content)
      player_cards = Floki.find(document, "[data-testid='player-cards'] span")

      assert length(player_cards) >= 3
    end

    test "El jugador se queda y se decide el ganador.", %{conn: conn} do
      {:ok, liveview, _html} = live(conn, "/blackjack")

      render_click(element(liveview, "button[phx-click='stand']"))

      content = render(liveview)
      assert content =~ "wins" or content =~ "tie"
    end
  end
end
