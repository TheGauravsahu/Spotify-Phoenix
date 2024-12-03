defmodule SpotifyWeb.SpotifyLive.Index do
  use SpotifyWeb, :live_view
  alias Spotify.Songs

  embed_templates "components/*"

  def mount(_params, session, socket) do
    nav_items = [
      %{icon: "hero-home", name: "Home", href: ""},
      %{icon: "hero-magnifying-glass", name: "Search", href: "search"},
      %{icon: "hero-book-open", name: "Your Library", href: "library"},
      %{icon: "hero-plus", name: "Create Playlist", href: "playlist"},
      %{icon: "hero-heart", name: "Liked Songs", href: "liked_songs"},
      %{icon: "hero-bookmark", name: "Your Episodes", href: "episodes"}
    ]

    current_user =
      case session["user_token"] do
        nil -> nil
        token -> Spotify.Users.get_user_by_session_token(token)
      end

    songs = Songs.list_songs()

    socket =
      socket
      |> assign(nav_items: nav_items)
      |> assign(songs: songs)
      |> assign(:current_user, current_user)
      |> assign(:playing_song, nil)
      |> assign(:is_playing, false)

    {:ok, socket}
  end

  def handle_event("toggle_play_song", %{"song_id" => song_id}, socket) do
    song = Songs.get_song(song_id)

    if socket.assigns.playing_song && socket.assigns.playing_song.id == song.id do
      # Toggle play/pause for the same song
      is_playing = !socket.assigns.is_playing

      {:noreply,
       socket
       |> assign(:is_playing, is_playing)
       |> push_event("play_song", %{
         file_path: song.filepath,
         is_playing: is_playing
       })}
    else
      # Play a new song
      {:noreply,
       socket
       |> assign(:playing_song, song)
       |> assign(:is_playing, true)
       |> push_event("play_song", %{
         file_path: song.filepath,
         is_playing: true
       })}
    end
  end

  def handle_event("update_progress", %{"progress" => progress}, socket) do
    song_duration = socket.assigns.playing_song.duration
    current_time = div(song_duration * progress, 100)

    {:noreply, socket |> assign(:current_time, current_time)}
  end
end
