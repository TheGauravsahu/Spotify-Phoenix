defmodule Spotify.Search do
  alias Spotify.Repo
  alias Spotify.Songs.Song
  import Ecto.Query

  def search(query) do
    query
    |> String.trim()
    |> search_songs()
  end

  defp search_songs(query) do
    Repo.all(
      from s in Song,
        where: fragment("lower(?) LIKE lower(?)", s.title, ^"%#{query}%"),
        preload: [:singer]
    )
  end
end
