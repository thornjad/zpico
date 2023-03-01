# Zpico -- the miniscule zsh package manager
#
# Version 0.4.0
#
# https://github.com/thornjad/zpico
# Copyright (c) 2021-2023 Jade Michael Thornton under the terms of the ISC License

typeset ZP_HOME=${0:A:h}
typeset ZP_PLUGIN_HOME=${ZP_PLUGIN_HOME:-${HOME}/.local/share/zpico/plugins}
typeset ZP_VERSION=0.4.0

_zpico_version() {
  print "zpico ${ZP_VERSION}"
}

_zpico_add() {
  local supportedSources=(github gitlab framagit local)
  local zsource="github" zbranchcmd="" zuse=""
  local zmodule=${1:t} zurl=${1}
  for x in "$@"; do
    parts=(${(s/:/)x})
    case ${parts[1]} in
      source)
        if ((${supportedSources[(Ie)${parts[2]}]})); then
          zsource=${parts[2]}
        else
          print "Unsupported source ${parts}"
          return 1
        fi
        ;;
      branch)
        zbranchcmd="-b ${parts[2]}"
        ;;
      use)
        zuse=${parts[2]}
        ;;
      *)
        ;;
    esac
  done

  local sourceurl="https://${zsource}.com/${zurl}.git"
  if [[ "$zsource" =~ "local" ]]; then
    sourceurl="${zurl}.git"
  fi

  local zpath=${ZP_PLUGIN_HOME}/${zmodule}

  if [[ ! -d ${zpath} ]]; then
    mkdir -p ${zpath}
    git clone --recursive ${zbranchcmd} ${sourceurl} ${zpath}
  fi

  local zscripts=(${zpath}/(${zuse}|init.zsh|${zmodule:t}.(zsh|plugin.zsh|zsh-theme|sh)|*.plugin.zsh)(NOL[1]))
  if [[ "$zscripts" != "" ]]; then
    source ${zscripts}
  fi
}

_zpico_update() {
  echo "Updating all plugins..."
  # For all git-controlled directories in the plugin home, execute a git pull
  find ${ZP_PLUGIN_HOME} -type d -maxdepth 1 -exec test -e '{}/.git' ';' -print0 |
    while IFS= read -r -d '' plugin; do
      echo "\t$(basename $plugin)..."
      git -C $plugin pull -q --no-rebase
      git -C $plugin submodule update
    done
  echo "Done"
}

_zpico_selfupdate() {
  if command -v curl 1>/dev/null 2>&1; then
    curl -sL --create-dirs https://raw.githubusercontent.com/thornjad/zpico/main/zpico.zsh -o ${0:A}
  else
    print "selfupdate requires curl, please install curl or update zpico manually" && return 1
  fi
}

_zpico_clean() {
  read "choice?Remove all downloaded plugins [y/N]? "
  if [[ ${${choice:0:1}:l} = "y" ]]; then
    echo "Removing all downloaded plugins... "
    find ${ZP_PLUGIN_HOME} -type d -maxdepth 1 -exec test -e '{}/.git' ';' -print0 | xargs -0tI {} rm -rf {}
  fi
}

zpico() {
  case "$1" in
    add)
      _zpico_add "$2" "$3" "$4" "$5"
      ;;
    update)
      _zpico_update
      ;;
    selfupdate)
      _zpico_selfupdate
      ;;
    clean)
      _zpico_clean
      ;;
    *)
      _zpico_version
      print "\nzpico add <package-repo> [[source:<source>] [branch:<branch>] [use:<glob>]] -- Add package"
      print "zpico update -- Update all packages"
      print "zpico selfupdate -- Update Zpico"
      print "zpico clean -- Remove all downloaded plugins"
      ;;
  esac
}
