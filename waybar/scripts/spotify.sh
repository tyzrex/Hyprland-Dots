#!/bin/bash

# The name of polybar bar which houses the main spotify module and the control modules.
PARENT_BAR="now-playing"
PARENT_BAR_PID=$(pgrep -a "polybar" | grep "$PARENT_BAR" | cut -d" " -f1)

# Set the source audio player here.
# Players supporting the MPRIS spec are supported.
# Examples: spotify, vlc, chrome, mpv and others.
# Use `playerctld` to always detect the latest player.
# See more here: https://github.com/altdesktop/playerctl/#selecting-players-to-control
PLAYER="spotify"

# Format of the information displayed
# Eg. {{ artist }} - {{ album }} - {{ title }}
# See more attributes here: https://github.com/altdesktop/playerctl/#printing-properties-and-metadata
FORMAT="{{ title }} - {{ artist }}"

# Custom labels
OFFLINE_LABEL="Offline"
NO_MUSIC_LABEL="Nothing Playing"

# Sends $2 as message to all polybar PIDs that are part of $1
update_hooks() {
    while IFS= read -r id
    do
        polybar-msg -p "$id" hook spotify-play-pause $2 1>/dev/null 2>&1
    done < <(echo "$1")
}

# Check if Spotify is running
if pgrep -x "$PLAYER" > /dev/null; then
  # Get the current player status
  status=$(playerctl --player="$PLAYER" status)
  if [ "$status" = "Playing" ]; then
    # Get the current song name and artist
    metadata=$(playerctl --player="$PLAYER" metadata --format "$FORMAT")
    update_hooks "$PARENT_BAR_PID" 1
    echo "$metadata"
  else
    update_hooks "$PARENT_BAR_PID" 2
    echo "$NO_MUSIC_LABEL"
  fi
else
