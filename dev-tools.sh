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
      docker-machine "$(title docker-machine 'Docker Machine')" off \
      docker-machine-driver-kvm "$(title docker-machine-driver-kvm 'Docker Machine KVM Driver')" off \
      kubectl "$(title kubectl 'kubectl')" off \
      minikube "$(title minikube 'Minikube')" off \
      minishift "$(title minishift 'Minishift')" off \
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


# Tool - Docker Machine

get_docker-machine_local_version() {
  if type docker-machine &> /dev/null; then
    docker-machine --version | sed -rn 's/^docker-machine version (.+), build .+$/\1/p'
  else
    echo '-'
  fi
}


get_docker-machine_latest_version() {
  get_github_version 'docker/machine'
}


install_docker-machine() {
  version="$(get_docker-machine_latest_version)"
  wget -O /usr/local/bin/docker-machine "https://github.com/docker/machine/releases/download/$version/docker-machine-$(uname -s)-$(uname -m)"
  chmod +x /usr/local/bin/docker-machine
  wget -O /etc/bash_completion.d/docker-machine "https://github.com/docker/machine/raw/$version/contrib/completion/bash/docker-machine.bash"
}


# Tool - Docker Machine KVM Driver

get_docker-machine-driver-kvm_local_version() {
  if type docker-machine-driver-kvm &> /dev/null; then
    echo 'Installed'
  else
    echo '-'
  fi
}


get_docker-machine-driver-kvm_latest_version() {
  get_github_version 'dhiltgen/docker-machine-kvm'
}


install_docker-machine-driver-kvm() {
  version="$(get_docker-machine-driver-kvm_latest_version)"
  wget -O /usr/local/bin/docker-machine-driver-kvm "https://github.com/dhiltgen/docker-machine-kvm/releases/download/$version/docker-machine-driver-kvm-ubuntu16.04"
  chmod +x /usr/local/bin/docker-machine-driver-kvm
}


# Tool - kubectl

get_kubectl_local_version() {
  if type kubectl &> /dev/null; then
    kubectl version 2> /dev/null | sed -rn 's/.* GitVersion:"(v[^"]+)".*/\1/p'
  else
    echo '-'
  fi
}


get_kubectl_latest_version() {
  wget -O - https://storage.googleapis.com/kubernetes-release/release/stable.txt
}


install_kubectl() {
  version="$(get_kubectl_latest_version)"
  wget -O /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/$version/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
  kubectl completion bash > /etc/bash_completion.d/kubectl
}


# Tool - Minikube

get_minikube_local_version() {
  if type minikube &> /dev/null; then
    minikube version | sed -rn 's/^minikube version: //p'
  else
    echo '-'
  fi
}


get_minikube_latest_version() {
  get_github_version 'kubernetes/minikube'
}


install_minikube() {
  wget -O /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  chmod +x /usr/local/bin/minikube
  minikube completion bash > /etc/bash_completion.d/minikube
}


# Tool - Minishift

get_minishift_local_version() {
  if type minishift &> /dev/null; then
    minishift version | sed -rn 's/^minishift (v[^+]+)\+.*/\1/p'
  else
    echo '-'
  fi
}


get_minishift_latest_version() {
  get_github_version 'minishift/minishift'
}


install_minishift() {
  version="$(get_minishift_latest_version)"
  wget -O - "https://github.com/minishift/minishift/releases/download/$version/minishift-${version/v/}-linux-amd64.tgz" | \
    tar -xzf - -C /usr/local/bin minishift
}


# Run

main
