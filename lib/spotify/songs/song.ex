defmodule Spotify.Songs.Song do
  use Ecto.Schema
  import Ecto.Changeset

  schema "songs" do
    field :title, :string
    field :image, :string
    field :duration, :string
    field :genre, :string
    field :filepath, :string
    belongs_to :singer, Spotify.Songs.Singer

    timestamps()
  end

  def changeset(song, attrs \\ %{}) do
    song
    |> cast(attrs, [:title, :image, :duration, :genre, :singer_id, :filepath])
    |> validate_required([:title, :image, :duration, :singer_id, :filepath])
    |> validate_length(:filepath, min: 1, message: "Filepath cannot be empty.")
    |> foreign_key_constraint(:singer_id)
  end
end
