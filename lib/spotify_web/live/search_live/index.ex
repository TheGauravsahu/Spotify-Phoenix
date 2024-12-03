defmodule SpotifyWeb.SearchLive.Index do
  use SpotifyWeb, :live_view
  alias Spotify.Search

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:query, %{"query" => ""})
     |> assign(:results, [])}
  end

  def handle_event("search", %{"query" => query}, socket) do
    results = Search.search(query)
    {:noreply,
     socket
     |> assign(:query, %{"query" => query})
     |> assign(:results, results)}
  end
end
