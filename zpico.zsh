typeset ZP_HOME=${0:A:h}
typeset ZP_PLUGIN_HOME=${ZP_PLUGIN_HOME:-${HOME}/.local/share/zpico/plugins}
typeset -a ZP_PLUGINS
typeset ZP_VERSION=0.1.0

zpadd() {
  local zmodule=${1:t} zurl=${1}
  local zpath=${ZP_PLUGIN_HOME}/${zmodule}
  ZP_PLUGINS+=(${zpath})

  if [[ ! -d ${zpath} ]]; then
    mkdir -p ${zpath}
    git clone --recursive https://github.com/${zurl}.git ${zpath}
  fi

  local zscripts=(${zpath}/(init.zsh|${zmodule:t}.(zsh|plugin.zsh|zsh-theme|sh))(NOL[1]))
  source ${zscripts}
}

alias zpclean="rm -rf $(echo ${ZP_PLUGINS} $(ls -d ${ZP_PLUGIN_HOME}/*) | tr ' ' '\n' | sort | uniq -u)"
alias zpupdate="find ${ZP_PLUGIN_HOME} -type d -exec test -e '{}/.git' ';' -print0 | xargs -I {} -0 git -C {} pull -q"

_zpico_version() {
  print "zpico ${ZP_VERSION}"
}

_zpico_add() {
  local supportedSources=(github gitlab framagit local)
  local zsource="github" zbranchcmd=""
  local zmodule=${1:t} zurl=${1}
  for x in "$@"; do
    parts=(${(s/:/)x})
    case ${parts[1]} in
      source)
        if (($supportedSource[(Ie)${parts[2]}])); then
          zsource=${parts[2]}
        else
          print "Unsupported source ${parts}"
          exit 1
        fi
        ;;
      branch)
        zbranchcmd="-b ${parts[2]}"
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
  ZP_PLUGINS+=(${zpath})

  if [[ ! -d ${zpath} ]]; then
    mkdir -p ${zpath}
    git clone --recursive ${zbranchcmd} ${sourceurl} ${zpath}
  fi

  local zscripts=(${zpath/(init.zsh|${zmodule:t}.(zsh|plugin.zsh|zsh-theme|sh))(NOL[1])})
  source ${zscripts}
}

_zpico_update() {
  find ${ZP_PLUGIN_HOME} -type d -exec test -e '{}/.git' ';' -print0 | xargs -I {} -0 git -C {} pull -q
}

_zpico_selfupdate() {
  if command -v curl 1>/dev/null 2>&1; then
    curl -sL --create-dirs https://gitlab.com/thornjad/zpico/-/raw/main/zpico.zsh -o ${0:A}
  else
    print "selfupdate requires curl, please install or update manually" && exit 1
  fi
}

_zpico_clean() {
}

# TODO help
zpico() {
  local command=${1}
  case $command in
    add)
      _zpico_add "$2" "$3" "$4"
      ;;
    update)
      ;;
    selfupdate)
      ;;
    clean)
      ;;
    *)
      _zpico_version
      ;;
  esac
}
