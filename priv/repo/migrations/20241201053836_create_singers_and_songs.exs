defmodule Spotify.Repo.Migrations.CreateSingersAndSongs do
  use Ecto.Migration

  def change do
    create table(:singers) do
      add :name, :string
      add :genre, :string

      timestamps()
    end

    create table(:songs) do
      add :title, :string
      add :image, :string
      add :duration, :string
      add :genre, :string
      add :filepath, :string
      add :singer_id, references(:singers)

      timestamps()
    end
  end
end
