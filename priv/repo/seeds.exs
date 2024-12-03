alias Spotify.Repo
alias Spotify.Songs.{Singer, Song}

# Add Singers
singer1 = Repo.insert!(%Singer{name: "Chitralekha Sen", genre: "Folk"})
singer2 = Repo.insert!(%Singer{name: "Hasan Raheem", genre: "Love"})

# Add songs
Repo.insert(%Song{
  title: "Kaliyo Kood Padiyo",
  image: "https://img.youtube.com/vi/TkfViqleqJc/maxresdefault.jpg",
  duration: "3:33",
  genre: "Folk",
  singer_id: singer1.id,
  filepath: "songs/kaliyo_kood_padiyo.mp3"
})

Repo.insert(%Song{
  title: "Samjho Na X Wishes - Mashup",
  image: "https://img.youtube.com/vi/n5CxWkohlCs/maxresdefault.jpg",
  duration: "3:09",
  genre: "Love",
  singer_id: singer2.id,
  filepath: "songs/samjho_na_x_wishes.mp3"
})
