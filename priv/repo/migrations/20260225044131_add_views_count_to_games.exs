defmodule PPhoenixLiveviewCourse.Repo.Migrations.AddViewsCountToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :views_count, :integer, default: 0, null: false
    end
  end
end
