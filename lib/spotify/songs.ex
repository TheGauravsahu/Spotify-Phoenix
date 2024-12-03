defmodule Spotify.Songs do
  alias Spotify.Repo
  alias Spotify.Songs.Song

  def list_songs do
    Repo.all(Song)
    |> Repo.preload(:singer)
  end

  def get_song(id) do
    Repo.get!(Song, id)
    |> Repo.preload(:singer)
  end
end
