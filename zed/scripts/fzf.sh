#!/usr/bin/env bash

TRANSFORMER='
query={q}
rg_pat=${query%%  *}      # Everything before the first set of double spaces
glob_pat=""
if [[ "$query" == *"  "* ]]; then
  glob_pat=${query#*  } # Everything after the first set of double spaces
fi
if [[ -n "$glob_pat" ]]; then
  rg --column --line-number --no-heading --color=always --smart-case -e "$rg_pat" -g "$glob_pat" || true
else
  rg --column --line-number --no-heading --color=always --smart-case -e "$rg_pat" || true
fi
'
fzf --layout=default --preview-window=up:60%:wrap \
  --disabled \
  --ansi \
  --bind "start:reload:$TRANSFORMER" \
  --bind "change:reload:sleep 0.1; :$TRANSFORMER" \
  --bind "ctrl-d:preview-down,ctrl-u:preview-up" \
  --bind "enter:execute-silent(zed {1}:{2})+abort" \
  --delimiter ':' \
  --with-nth='{1}' \
  --preview '
    FILE={1}
    LINE={2}
    if [[ -n "$FILE" && -n "$LINE" && -f "$FILE" ]]; then
      bat --style=numbers,plain --color=always --theme=gruvbox-dark --highlight-line {2} {1}
    else
      echo ""
    fi
  ' \
  --preview-window '+{2}+4/3,<80(up),border-bottom' \
  --scrollbar ' ' \
  --phony \
  --query "" \
  --prompt "Search > " \
  --multi
