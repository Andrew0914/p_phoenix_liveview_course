defmodule PPhoenixLiveviewCourse.CatalogTest do
  use PPhoenixLiveviewCourse.DataCase

  alias PPhoenixLiveviewCourse.Catalog

  describe "games" do
    alias PPhoenixLiveviewCourse.Catalog.Game
    import PPhoenixLiveviewCourse.CatalogFixtures

    @invalid_attrs %{name: nil, description: nil, unit_price: nil, sku: nil}

    # -------------------------
    # CRUD EXISTENTES
    # -------------------------

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Catalog.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Catalog.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      valid_attrs = %{
        name: "some name",
        description: "some description",
        unit_price: 120.5,
        sku: 42
      }

      assert {:ok, %Game{} = game} = Catalog.create_game(valid_attrs)
      assert game.name == "some name"
      assert game.description == "some description"
      assert game.unit_price == 120.5
      assert game.sku == 42
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        unit_price: 456.7,
        sku: 43
      }

      assert {:ok, %Game{} = game} = Catalog.update_game(game, update_attrs)
      assert game.name == "some updated name"
      assert game.description == "some updated description"
      assert game.unit_price == 456.7
      assert game.sku == 43
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_game(game, @invalid_attrs)
      assert game == Catalog.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Catalog.delete_game(game)

      assert_raise Ecto.NoResultsError, fn ->
        Catalog.get_game!(game.id)
      end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Catalog.change_game(game)
    end

    # -------------------------
    # TESTS ADICIONALES
    # -------------------------

    test "list_games/0 returns empty list when no games exist" do
      assert Catalog.list_games() == []
    end

    test "create_game/1 sets default views to 0" do
      valid_attrs = %{
        name: "Game with views",
        description: "desc",
        unit_price: 50.0,
        sku: 99
      }

      assert {:ok, game} = Catalog.create_game(valid_attrs)
      assert game.views == 0
    end

    test "updating one field does not change others" do
      game = game_fixture()

      assert {:ok, updated_game} =
               Catalog.update_game(game, %{name: "Only name changed"})

      assert updated_game.name == "Only name changed"
      assert updated_game.description == game.description
      assert updated_game.unit_price == game.unit_price
      assert updated_game.sku == game.sku
    end

    test "delete_game actually removes from list" do
      game = game_fixture()
      {:ok, _} = Catalog.delete_game(game)

      assert Catalog.list_games() == []
    end
  end
end
