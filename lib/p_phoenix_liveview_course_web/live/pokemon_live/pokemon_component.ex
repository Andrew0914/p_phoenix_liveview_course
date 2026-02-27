defmodule PPhoenixLiveviewCourseWeb.PokemonLive.PokemonComponent do
  use Phoenix.Component

  attr :pokemon, :map, required: true
  attr :player, :string, default: ""
  attr :id, :string, default: ""

  def pokemon_card(assigns) do
    assigns =
      assigns
      |> assign(
        label_type:
          case assigns.pokemon.type do
            :fire -> "Fire 🔥"
            :water -> "Water 💧"
            :grass -> "Grass 🌱"
          end
      )

    ~H"""
    <div
      class="pokemon-card"
      role="button"
      phx-click="choose_pokemon"
      phx-value-id={@pokemon.id}
      id={@id}
    >
      <strong>{@player}</strong>
      <img src={@pokemon.image_url} alt={@pokemon.name} />
      <h2>{@pokemon.name}</h2>
      <p>Type: {@label_type}</p>
    </div>
    """
  end
end
