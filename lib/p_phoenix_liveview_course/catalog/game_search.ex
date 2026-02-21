defmodule PPhoenixLiveviewCourse.Catalog.GameSearch do
  @moduledoc """
  Embedded schema for managing and validating game search form data.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :search_text, :string, default: ""
  end

  @doc """
  Create a changeset to validate that the search text has at least 3 characters.
  """
  def changeset(search_query, attrs \\ %{}) do
    search_query
    |> cast(attrs, [:search_text])
    |> validate_length(:search_text, min: 3, message: "Write at least 3 letters")
  end
end
