defmodule PPhoenixLiveviewCourse.Repo.Migrations.AddViewsToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :views, :integer, default: 0
    end
  end
end
