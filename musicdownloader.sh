#!/bin/bash
while [[ $album != "q" ]]
do
  echo "Enter title of album (or d for delete q for quit or l for list): "
  read -r album
  if [[ $album == "d" ]]; then
    echo "What album would you like to delete?"
    read -r deleteAlbum
    rm -r "$HOME/Music/$deleteAlbum" && echo "Folder deleted" || echo "Failed to remove directory, please check manually"
    continue
  elif [[ $album == "q" ]]; then
    echo "Saving albums"
    rclone sync ~/Music Mega:Music && echo "Successfully saved" || echo "Something went wrong, please try again"
    break
  fi
  if [[ $album == "l" ]]; then
    echo "LIST MODE"
    albumList=()
    urlList=()
    while [[ $albumItem != "q" ]]; do
      echo "Enter title of album (q to quit): "
      read -r albumItem
      if [[ $albumItem == "q" ]]; then
        break
      fi
      echo "Enter url: "
      read -r urlItem
      albumList+=("${albumItem}")
      urlList+=("${urlItem}")
    done
    albumLen=${#albumList[@]}
    urlLen=${#urlList[@]}
    if [[ $albumLen != $urlLen ]]; then
      echo "Album length: $albumLen Url length: $urlLen"
      echo "An unexpected error has occured, please retry"
      break
    fi
    for (( i=0; i<$albumLen; i++ )); do
      currentDir="$HOME/Music/${albumList[$i]}"
      currentUrl="${urlList[$i]}"
      mkdir "$currentDir"; cd "$currentDir"
      yt-dlp "$currentUrl" -f m4a -o "%(title)s.%(ext)s" 
    done
    for (( i=0; i<$albumLen; i++ )); do
      currentDir="$HOME/Music/${albumList[$i]}"
      cd "$currentDir"
      echo "Manual intervention required for: ${albumList[$i]}? [y/N]"
      read -r intervention
      if [[ $intervention == "y" ]]; then
        dolphin .
      fi
      echo "Scanning ${albumList[$i]}..."
      picard ./* -e SCAN
    done
    echo "Save to server? [Y/n]"
    read -r saveServer
    if [[ $saveServer != "n" ]]; then
      rclone sync $HOME/Music Mega:Music
    fi
  break
  fi
  dir="$HOME/Music/$album"
  echo "Enter url: "
  read -r youtubeUrl
  mkdir "$dir"; cd "$dir"
  yt-dlp $youtubeUrl -f m4a -o "%(title)s.%(ext)s" 
  echo "Manual intervention required? [y/N]"
  read -r intervention
  if [[ $intervention == "y" ]]; then
    dolphin .
  fi
  picard ./* -e SCAN
done
