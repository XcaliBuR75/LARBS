#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.zsh
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS

# Key bindings
# ------------

# The code at the top and the bottom of this file is the same as in completion.zsh.
# Refer to that file for explanation.
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  __fzf_key_bindings_options="options=(${(j: :)${(kv)options[@]}})"
else
  () {
    __fzf_key_bindings_options="setopt"
    'local' '__fzf_opt'
    for __fzf_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__fzf_opt" ]]; then
        __fzf_key_bindings_options+=" -o $__fzf_opt"
      else
        __fzf_key_bindings_options+=" +o $__fzf_opt"
      fi
    done
  }
fi

'emulate' 'zsh' '-o' 'no_aliases'

{

[[ -o interactive ]] || return 0

# ALT-L - Paste the selected file path(s) into the command line
__fsel() {
  local cmd="${FZF_ALT_L_COMMAND:-"command ag --hidden --ignore '\\.gitignore' --ignore-dir '\\.*git*' --null -g '\\.' 2>/dev/null | xargs -0 dirname | LC_ALL=C sort -u"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --cycle --bind=ctrl-z:ignore,tab:toggle-down,btab:toggle-up $FZF_DEFAULT_OPTS $FZF_ALT_L_OPTS" $(__fzfcmd) +m "$@" | while read item; do
    echo -n "${(q)item}"
  done
  local ret=$?
  echo
  return $ret
}

__fzfcmd() {
  [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file-widget() {
LBUFFER="l ${LBUFFER}$(__fsel)"
  zle accept-line
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N            fzf-file-widget
bindkey -M emacs '\el' fzf-file-widget
bindkey -M vicmd '\el' fzf-file-widget
bindkey -M viins '\el' fzf-file-widget

# ALT-D - Paste the selected file path(s) into the command line
__fsel1() {
  local cmd="${FZF_ALT_D_COMMAND:-"command cat $HOME/Downloads/bulk-tmp 2>/dev/null"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --cycle --bind=ctrl-z:ignore,tab:toggle-down,btab:toggle-up $FZF_DEFAULT_OPTS --pointer="" --color=pointer:#A6E3A1 $FZF_ALT_D_OPTS" $(__fzfcmd) +m "$@" | while read item; do
    echo -n "${(q)item}"
  done
  local ret=$?
  echo
  return $ret
}

__fzfcmd() {
  [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file1-widget() {
LBUFFER="v /${LBUFFER}$(__fsel1)"
  zle accept-line
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N            fzf-file1-widget
bindkey -M emacs '\ed' fzf-file1-widget
bindkey -M vicmd '\ed' fzf-file1-widget
bindkey -M viins '\ed' fzf-file1-widget

# ALT-A - Concatenate files and print on the standard output
__fsel2() {
  local cmd="${FZF_ALT_D_COMMAND:-"command ag --hidden --ignore '\\.gitignore' --ignore-dir '\\.*git*' -g '\\./' 2>/dev/null"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --cycle --bind=ctrl-z:ignore,tab:toggle-down,btab:toggle-up $FZF_DEFAULT_OPTS --pointer="" --color=pointer:#BAC2DE --preview 'bat --color=always --style=plain --line-range=:500 {}' $FZF_ALT_D_OPTS" $(__fzfcmd) +m "$@" | while read item; do
    echo -n "${(q)item}"
  done
  local ret=$?
  echo
  return $ret
}

__fzfcmd() {
  [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file2-widget() {
LBUFFER="cat ${LBUFFER}$(__fsel2)"
  zle accept-line
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N            fzf-file2-widget
bindkey -M emacs '\ea' fzf-file2-widget
bindkey -M vicmd '\ea' fzf-file2-widget
bindkey -M viins '\ea' fzf-file2-widget

# ALT-S - Concatenate files and print on the standard output
__fsel3() {
  local cmd="${FZF_ALT_D_COMMAND:-"command ag --hidden --ignore '\\.gitignore' --ignore-dir '\\.*git*' -g '\\./' 2>/dev/null"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --cycle --bind=ctrl-z:ignore,tab:toggle-down,btab:toggle-up $FZF_DEFAULT_OPTS --pointer="" --color=pointer:#A6E3A1 --preview 'bat --color=always --style=plain --line-range=:500 {}' $FZF_ALT_D_OPTS" $(__fzfcmd) +m "$@" | while read item; do
    echo -n "${(q)item}"
  done
  local ret=$?
  echo
  return $ret
}

__fzfcmd() {
  [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file3-widget() {
LBUFFER="v ${LBUFFER}$(__fsel3)"
  zle accept-line
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N            fzf-file3-widget
bindkey -M emacs '\es' fzf-file3-widget
bindkey -M vicmd '\es' fzf-file3-widget
bindkey -M viins '\es' fzf-file3-widget

# ALT-O - cd into the selected directory
fzf-cd-widget() {
local cmd="${FZF_ALT_O_COMMAND:-"command ag --hidden --ignore '\\.gitignore' --ignore-dir '\\.*git*' --null -g '\\.' $HOME/Downloads/bulk-tmp-dir 2>/dev/null"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --cycle --bind=ctrl-z:ignore,tab:toggle-down,btab:toggle-up $FZF_DEFAULT_OPTS --pointer="" --color=pointer:#96CDFB $FZF_ALT_O_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="cd /${(q)dir} && l"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}
zle     -N             fzf-cd-widget
bindkey -M emacs '\eo' fzf-cd-widget
bindkey -M vicmd '\eo' fzf-cd-widget
bindkey -M viins '\eo' fzf-cd-widget

# ALT-P - cd into the selected directory
fzf-cdh-widget() {
  local cmd="${FZF_ALT_P_COMMAND:-"command ag --hidden --ignore '\\.gitignore' --ignore-dir '\\.*git*' --null -g '\\.' 2>/dev/null | xargs -0 dirname | LC_ALL=C sort -u"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --cycle --bind=ctrl-z:ignore,tab:toggle-down,btab:toggle-up $FZF_DEFAULT_OPTS --pointer="" --color=pointer:#96CDFB $FZF_ALT_P_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="cd ${(q)dir} && l"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}
zle     -N             fzf-cdh-widget
bindkey -M emacs '\ep' fzf-cdh-widget
bindkey -M vicmd '\ep' fzf-cdh-widget
bindkey -M viins '\ep' fzf-cdh-widget

# ALT-U - List the entire filesystem and pipe the result into a file
__fsel4() {
  cd "/"
  local cmd="${FZF_ALT_U_COMMAND:-"command ag -i --hidden --ignore '\\.gitignore' --ignore-dir '\\.*git*' -g '\\./' > $HOME/Downloads/bulk-tmp 2>/dev/null"}"
  local cmd1="${FZF_ALT_U_COMMAND:-"command ag -i --hidden --ignore '\\.gitignore' --ignore-dir '\\.*git*' --null -g '\\./' 2>/dev/null | xargs -0 dirname | LC_ALL=C sort -u > $HOME/Downloads/bulk-tmp-dir"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  eval "$cmd"
  eval "$cmd1"
}

__fzfcmd() {
  [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-updb-widget() {
LBUFFER="${LBUFFER}$(__fsel4)"
  zle accept-line
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N            fzf-updb-widget
bindkey -M emacs '\eu' fzf-updb-widget
bindkey -M vicmd '\eu' fzf-updb-widget
bindkey -M viins '\eu' fzf-updb-widget

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS --pointer="" --color=pointer:#50fa7b -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore,tab:toggle-down,btab:toggle-up $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    zle accept-line
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N            fzf-history-widget
bindkey -M emacs '\e ' fzf-history-widget
bindkey -M vicmd '\e ' fzf-history-widget
bindkey -M viins '\e ' fzf-history-widget

} always {
  eval $__fzf_key_bindings_options
  'unset' '__fzf_key_bindings_options'
}
