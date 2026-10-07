#!/usr/bin/env bash
# Scroll the focused herdr pane half a screen, like ctrl+u/ctrl+d in vim.
#   pane-scroll.sh up|down
# Programs with their own ctrl+u/ctrl+d (nvim, lazygit, less, fzf...) get the
# key instead.
set -u

herdr=${HERDR_BIN_PATH:-herdr}
pane=${HERDR_ACTIVE_PANE_ID:?}
socket=${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}
passthrough=${HERDR_SCROLL_PASSTHROUGH:-'^(g?n?vim?x?|view|lazygit|less|more|man|fzf|tig|htop|btop|yazi)$'}

case "${1:-}" in
  up) key=ctrl+u ;;
  down) key=ctrl+d ;;
  *) echo "usage: pane-scroll.sh up|down" >&2; exit 2 ;;
esac

if "$herdr" pane process-info --pane "$pane" |
  jq -e --arg re "$passthrough" '[.result.process_info.foreground_processes[].name | test($re)] | any' >/dev/null; then
  exec "$herdr" pane send-keys "$pane" "$key"
fi

read -r offset max rows < <("$herdr" pane get "$pane" |
  jq -r '.result.pane.scroll | "\(.offset_from_bottom) \(.max_offset_from_bottom) \(.viewport_rows)"')
step=$(( rows / 2 > 0 ? rows / 2 : 1 ))
if [ "$1" = up ]; then target=$(( offset + step )); else target=$(( offset - step )); fi
(( target > max )) && target=$max
(( target < 0 )) && target=0
(( target == offset )) && exit 0

# pane.scroll has no CLI wrapper; send the raw socket request
python3 - "$socket" "$pane" "$target" <<'EOF'
import json, socket, sys
path, pane, offset = sys.argv[1], sys.argv[2], int(sys.argv[3])
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect(path)
req = {"id": "pane-scroll", "method": "pane.scroll",
       "params": {"pane_id": pane, "offset_from_bottom": offset}}
s.sendall((json.dumps(req) + "\n").encode())
s.recv(65536)
EOF
