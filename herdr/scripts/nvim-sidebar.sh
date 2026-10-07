#!/usr/bin/env bash
# Toggle the herdr-nvim sidebar and remember its width between toggles.
# herdr-nvim always opens the sidebar at 50%; this opens it at 65% instead,
# records the sidebar's share of the tab width on close and restores it on the
# next open.
set -u

herdr=${HERDR_BIN_PATH:-herdr}
tab=${HERDR_ACTIVE_TAB_ID:-}
state_dir=${XDG_STATE_HOME:-$HOME/.local/state}/herdr
state_file=$state_dir/nvim-sidebar-width
# width used until a width has been saved
default_share=0.65

sidebar_pane() {
  "$herdr" pane list | jq -r --arg tab "$tab" \
    '.result.panes[] | select(.label == "nvim sidebar" and ($tab == "" or .tab_id == $tab)) | .pane_id' | head -1
}

# Sidebar share of the tab width (0..1), from the split it sits in.
sidebar_share() {
  "$herdr" pane layout --pane "$1" | jq -r --arg id "$1" '
    .result.layout as $l
    | ($l.panes[] | select(.pane_id == $id).rect) as $r
    | [$l.splits[] | select(.direction == "right"
        and ($r.y >= .rect.y) and ($r.y + $r.height <= .rect.y + .rect.height)
        and ($r.x >= .rect.x) and ($r.x + $r.width <= .rect.x + .rect.width))]
    | max_by(.rect.width)
    | if $r.x > .rect.x then 1 - .ratio else .ratio end'
}

sidebar=$(sidebar_pane)

if [ -n "$sidebar" ]; then
  share=$(sidebar_share "$sidebar")
  if [ -n "$share" ] && [ "$share" != null ]; then
    mkdir -p "$state_dir" && printf '%s\n' "$share" >"$state_file"
  fi
  exec "$herdr" plugin action invoke toggle --plugin chmarax.herdr-nvim >/dev/null
fi

"$herdr" plugin action invoke toggle --plugin chmarax.herdr-nvim >/dev/null
want=$(cat "$state_file" 2>/dev/null || echo "$default_share")

# toggle returns before the pane exists; wait for it
for _ in $(seq 30); do
  sidebar=$(sidebar_pane)
  [ -n "$sidebar" ] && break
  sleep 0.1
done
[ -n "$sidebar" ] || exit 0

have=$(sidebar_share "$sidebar")
[ -n "$have" ] && [ "$have" != null ] || exit 0

# Resize moves the sidebar's inner border; toward the neighbour widens it.
read -r dir amount < <(awk -v want="$want" -v have="$have" -v x="$(
  "$herdr" pane layout --pane "$sidebar" | jq -r --arg id "$sidebar" '.result.layout.panes[] | select(.pane_id == $id).rect.x'
)" 'BEGIN {
  d = want - have; grow = d > 0; a = grow ? d : -d
  right = x > 0
  dir = (right == grow) ? "left" : "right"
  printf "%s %.4f\n", dir, a
}')
awk -v a="$amount" 'BEGIN { exit !(a >= 0.005) }' || exit 0
"$herdr" pane resize --pane "$sidebar" --direction "$dir" --amount "$amount" >/dev/null
