# zpico -- the minuscule zsh package manager
#
# https://github.com/thornjad/zpico
# Copyright (c) 2021-2026 Jade Michael Thornton under the terms of the ISC License

typeset ZP_VERSION=0.6.0

typeset _ZP_SELF=${0:A}
typeset ZP_PLUGIN_HOME=${ZP_PLUGIN_HOME:-${HOME}/.local/share/zpico/plugins}

_zpico_add() {
  local supportedSources=(github gitlab framagit codeberg local)
  local zsource="github" zbranch="" zuse=""
  local zmodule=${${1:t}%.git} zrepo=${1}
  local zpath=${ZP_PLUGIN_HOME}/${zmodule}

  for x in "$@"; do
    parts=(${(s/:/)x})
    case ${parts[1]} in
      source)
        if ((${supportedSources[(Ie)${parts[2]}]})); then
          zsource=${parts[2]}
        else
          print "unsupported source ${parts[2]}"
          return 1
        fi
        ;;
      branch)
        zbranch=${parts[2]}
        ;;
      use)
        zuse=${parts[2]}
        ;;
      *)
        ;;
    esac
  done

  local -A _sourcedomains=(github github.com gitlab gitlab.com framagit framagit.org codeberg codeberg.org)
  local sourceurl=""
  if [[ "$zrepo" = *"://"* ]]; then
    sourceurl="${zrepo}"
  elif [[ "$zsource" = "local" ]]; then
    sourceurl="${zrepo}"
  else
    sourceurl="https://${_sourcedomains[$zsource]}/${zrepo}.git"
  fi

  if [[ ! -d ${zpath} ]]; then
    mkdir -p ${zpath}
    if ! git clone --recursive ${zbranch:+-b} ${zbranch} ${sourceurl} ${zpath}; then
      rm -rf ${zpath}
      print "failed to clone ${sourceurl}"
      return 1
    fi
  fi

  local zscripts=(${zpath}/(${zuse}|init.zsh|${zmodule}.(zsh|plugin.zsh|zsh-theme|sh)|*.plugin.zsh)(NOL[1]))
  if [[ "$zscripts" != "" ]]; then
    source ${zscripts}
  fi
}

_zpico_remove() {
  rm -rf ${ZP_PLUGIN_HOME}/${${1:t}%.git}
}

_zpico_remove_all() {
  read "choice?Remove all downloaded plugins [y/N]? "
  if [[ ${${choice:0:1}:l} = "y" ]]; then
    print "removing all downloaded plugins..."
    rm -rf ${ZP_PLUGIN_HOME}
  fi
}

_zpico_update() {
  local zpath=${ZP_PLUGIN_HOME}/${${1:t}%.git}
  git -C "${zpath}" pull -q --no-rebase
  git -C "${zpath}" submodule update
}

_zpico_update_all() {
  print "updating all plugins..."
  for plugin in ${ZP_PLUGIN_HOME}/*(N/); do
    [[ -d "${plugin}/.git" ]] || continue
    print "  ${plugin:t}..."
    _zpico_update ${plugin:t}
  done
  print "done"
}

_zpico_selfupdate() {
  if command -v curl 1>/dev/null 2>&1; then
    local tmpfile="${_ZP_SELF}.tmp.$$"
    if curl -sfL https://raw.githubusercontent.com/thornjad/zpico/main/zpico.zsh -o "${tmpfile}"; then
      mv "${tmpfile}" "${_ZP_SELF}"
      print "updated zpico (reload shell to apply)"
    else
      rm -f "${tmpfile}"
      print "selfupdate failed" && return 1
    fi
  else
    print "selfupdate requires curl, please install curl or update zpico manually" && return 1
  fi
}

_zpico_assert_exists() {
  if [[ ! -d "${ZP_PLUGIN_HOME}/${${1:t}%.git}" ]]; then
    print "package ${1} not found"
    return 1
  fi
}

_zpico_help() {
  print "zpico ${ZP_VERSION}\n"
  print "zpico add <package-repo> [[source:<source>] [branch:<branch>] [use:<glob>]] -- add package"
  print "zpico remove <package-repo> -- remove package"
  print "zpico remove --all -- remove all packages"
  print "zpico update <package-repo> -- update package"
  print "zpico update --all -- update all packages"
  print "zpico selfupdate -- update zpico"
  print "zpico version -- print version"
  print "zpico help -- print this help"
}

zpico() {
  local zmodule="$2"

  case "$1" in
    add)
      if [[ -z "$2" ]]; then
        _zpico_help
      else
        _zpico_add "${@:2}"
      fi
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
          print "removing ${zmodule}..."
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
          print "updating ${zmodule}..."
          _zpico_assert_exists $zmodule && _zpico_update $zmodule
          ;;
      esac
      ;;
    selfupdate)
      _zpico_selfupdate
      ;;
    help|"")
      _zpico_help
      ;;
    version)
      print "zpico ${ZP_VERSION}"
      ;;
    *)
      print "unknown command: $1"
      _zpico_help
      return 1
      ;;
  esac
}
