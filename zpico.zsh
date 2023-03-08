# Zpico -- the miniscule zsh package manager
#
# https://github.com/thornjad/zpico
# Copyright (c) 2021-2023 Jade Michael Thornton under the terms of the ISC License

typeset ZP_VERSION=0.5.0

typeset ZP_HOME=${0:A:h}
typeset ZP_PLUGIN_HOME=${ZP_PLUGIN_HOME:-${HOME}/.local/share/zpico/plugins}

_zpico_add() {
  local supportedSources=(github gitlab framagit codeberg local)
  local zsource="github" zbranchcmd="" zuse=""
  local zmodule=${1:t} zrepo=${1}
  local zpath=${ZP_PLUGIN_HOME}/${zmodule}

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

  local sourceurl="https://${zsource}.com/${zrepo}.git"
  if [[ "$zsource" =~ "local" ]]; then
    sourceurl="${zrepo}.git"
  fi

  if [[ ! -d ${zpath} ]]; then
    mkdir -p ${zpath}
    git clone --recursive ${zbranchcmd} ${sourceurl} ${zpath}
  fi

  local zscripts=(${zpath}/(${zuse}|init.zsh|${zmodule:t}.(zsh|plugin.zsh|zsh-theme|sh)|*.plugin.zsh)(NOL[1]))
  if [[ "$zscripts" != "" ]]; then
    source ${zscripts}
  fi
}

_zpico_remove() {
  local zpath=${ZP_PLUGIN_HOME}/${1:t}
  rm -rf $zpath
}

_zpico_remove_all() {
  read "choice?Remove all downloaded plugins [y/N]? "
  if [[ ${${choice:0:1}:l} = "y" ]]; then
    echo "Removing all downloaded plugins... "
    rm -rf ${ZP_PLUGIN_HOME}
  fi
}

_zpico_update() {
  git -C "${ZP_PLUGIN_HOME}/${1:t}" pull -q --no-rebase
  git -C "${ZP_PLUGIN_HOME}/${1:t}" submodule update
}

_zpico_update_all() {
  echo "Updating all plugins..."
  # For all git-controlled directories in the plugin home, execute a git pull
  find ${ZP_PLUGIN_HOME} -type d -maxdepth 1 -exec test -e '{}/.git' ';' -print0 |
    while IFS= read -r -d '' plugin; do
      echo "\t$(basename $plugin)..."
      _zpico_update $plugin
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

_zpico_assert_exists() {
  if [[ ! -d "${ZP_PLUGIN_HOME}/${1:t}"  ]]; then
    echo "Package ${1} not found"
    return 1
  fi
}

_zpico_help() {
  print "zpico ${ZP_VERSION}\n"
  print "zpico add <package-repo> [[source:<source>] [branch:<branch>] [use:<glob>]] -- Add package"
  print "zpico remove <package-repo> -- Remove package"
  print "zpico remove --all -- Remove all packages"
  print "zpico update <package-repo> -- Update package"
  print "zpico update --all -- Update all packages"
  print "zpico selfupdate -- Update Zpico"
}

zpico() {
  local zmodule="$2"

  case "$1" in
    add)
      _zpico_add "$2" "$3" "$4" "$5"
      ;;
    remove)
      case ${zmodule} in
        "")
          _zpico_help
          ;;
        "--all")
          _zpico_remove_all
          ;;
        *)
          echo "Removing ${zmodule}..."
          _zpico_assert_exists $zmodule && _zpico_remove $zmodule
          ;;
      esac
      ;;
    update)
      case ${zmodule} in
        "")
          _zpico_help
          ;;
        "--all")
          _zpico_update_all
          ;;
        *)
          echo "Updating ${zmodule}..."
          _zpico_assert_exists $zmodule && _zpico_update $zmodule
          ;;
      esac
      ;;
    selfupdate)
      _zpico_selfupdate
      ;;
    *)
      ;;
  esac
}
