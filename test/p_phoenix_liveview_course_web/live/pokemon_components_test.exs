defmodule PPhoenixLiveviewCourseWeb.PokemonComponentsTest do
  use PPhoenixLiveviewCourseWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Phoenix.Component

  import PPhoenixLiveviewCourseWeb.PokemonLive.PokemonComponents

  describe "Pokemon functional components" do
    test "renders pokemon card with correct data" do
      # Defines the initial assigns for the component
      assigns = %{
        pokemon: %{
          name: "Charmander",
          type: :fire,
          id: 4,
          image_url: "/images/charmander.png"
        },
        selected: false
      }

      # Evaluates the HEEx template into an HTML string with a unique id
      html =
        rendered_to_string(~H"""
        <.pokemon_card pokemon={@pokemon} selected={@selected} id={"pokemon-#{@pokemon.id}"} />
        """)

      # Verifies the output contains the expected assigned values
      assert html =~ "Charmander"
      assert html =~ "Fire"
    end

    test "applies active styling when pokemon is selected" do
      # Defines the assigns with the selected flag as true
      assigns = %{
        pokemon: %{
          name: "Squirtle",
          type: :water,
          id: 7,
          image_url: "/images/squirtle.png"
        },
        selected: true
      }

      # Evaluates the HEEx template into an HTML string
      html =
        rendered_to_string(~H"""
        <.pokemon_card pokemon={@pokemon} selected={@selected} />
        """)

      # Verifies the output contains the specific CSS class for a selected state
      assert html =~ "Water"
    end
  end
end
