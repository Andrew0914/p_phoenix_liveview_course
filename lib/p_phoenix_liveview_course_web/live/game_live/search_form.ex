defmodule PPhoenixLiveviewCourseWeb.GameLive.SearchForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :query, :string
  end

  def changeset(search_form, attrs \\ %{}) do
    search_form
    |> cast(attrs, [:query])
    |> validate_length(:query, min: 3, message: "enter at least 3 characters")
  end
end
