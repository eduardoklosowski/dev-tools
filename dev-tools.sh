#!/bin/bash

set -e


# Utils

get_github_version() {
  wget -O - -q "https://api.github.com/repos/$1/releases/latest" | \
    python -c "import sys; import json; print(json.load(sys.stdin)['name'])"
}


title() {
  VER_LOCAL="$(eval "get_$1_local_version")"
  VER_LATEST="$(eval "get_$1_latest_version")"
  echo "$2 [ $VER_LOCAL / $VER_LATEST ]"
}


menu() {
  lines="$(($(tput lines) - 3))"
  cols="$(($(tput cols) - 4))"
  whiptail \
    --title 'DEV Tools' \
    --ok-button 'Install' \
    --checklist '' "$lines" "$cols" "$((lines - 6))" \
    3>&1 1>&2 2>&3
}


main() {
  first=true
  for tool in $(menu); do
    if $first; then
      first=false
    else
      echo
    fi
    echo "---> Instaling $tool"
    eval "install_$tool" |& sed -r 's/^/  /'
  done
}


# Run

main
