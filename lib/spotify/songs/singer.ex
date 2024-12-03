defmodule Spotify.Songs.Singer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "singers" do
    field :name, :string
    field :genre, :string
    has_many :songs, Spotify.Songs.Song

    timestamps()
  end

  def changeset(singer, attrs \\ %{}) do
    singer
    |> cast(attrs, [:name, :genre])
    |> validate_required([:name, :genre])
  end
end
