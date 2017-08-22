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
      commit-rules "$(title commit-rules 'Commit Rules')" off \
      docker-compose "$(title docker-compose 'Docker Compose')" off \
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


# Tool - Commit Rules

get_commit-rules_local_version() {
  if type commit-rules &> /dev/null; then
    echo 'Installed'
  else
    echo '-'
  fi
}


get_commit-rules_latest_version() {
  echo 'git'
}


install_commit-rules() {
  wget -O /usr/local/bin/commit-rules 'https://gitlab.com/eduardoklosowski/commit-rules/raw/master/commit-rules'
  chmod +x /usr/local/bin/commit-rules
}


# Tool - Docker Compose

get_docker-compose_local_version() {
  if type docker-compose &> /dev/null; then
    docker-compose --version | sed -rn 's/^docker-compose version (.+), build .+$/\1/p'
  else
    echo '-'
  fi
}


get_docker-compose_latest_version() {
  get_github_version 'docker/compose'
}


install_docker-compose() {
  version="$(get_docker-compose_latest_version)"
  wget -O /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/$version/docker-compose-$(uname -s)-$(uname -m)"
  chmod +x /usr/local/bin/docker-compose
  wget -O /etc/bash_completion.d/docker-compose "https://github.com/docker/compose/raw/$version/contrib/completion/bash/docker-compose"
}


# Run

main
