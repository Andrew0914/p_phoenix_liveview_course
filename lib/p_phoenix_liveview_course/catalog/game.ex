defmodule PPhoenixLiveviewCourse.Catalog.Game do
  use Ecto.Schema
  import Ecto.Changeset
  alias PPhoenixLiveviewCourse.Rating.Tomatoes

  schema "games" do
    field :name, :string
    field :description, :string
    field :unit_price, :float
    field :sku, :integer
    field(:image_upload, :string)
    field :views_count, :integer, default: 0
    has_one :tomatoes, Tomatoes, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:name, :description, :unit_price, :sku, :image_upload])
    |> validate_required([:name, :description, :unit_price, :sku])
    |> unique_constraint(:sku)
    |> validate_length(:name, min: 5, max: 100)
  end
end
