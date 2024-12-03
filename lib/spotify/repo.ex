defmodule Spotify.Repo do
  use Ecto.Repo,
    otp_app: :spotify,
    adapter: Ecto.Adapters.SQLite3
end
