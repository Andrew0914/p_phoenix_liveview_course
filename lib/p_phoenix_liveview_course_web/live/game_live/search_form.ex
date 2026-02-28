defmodule PPhoenixLiveviewCourseWeb.GameLive.SearchForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :query, :string, default: ""
  end

  def changeset(search_form, attrs \\ %{}) do
    search_form
    |> cast(attrs, [:query])
    |> validate_search_query()
  end

  defp validate_search_query(changeset) do
    query = get_field(changeset, :query)

    if query && String.trim(query) != "" do
      validate_length(changeset, :query, min: 3, message: "must be at least 3 characters")
    else
      changeset
    end
  end
end
