#!/bin/sh
set -u

# Machine-local settings come from machine.env, but environment variables win.
#   LAZYGIT_AI_COMMIT_BACKEND=claude|pi   (default: claude)
#   LAZYGIT_AI_COMMIT_MODEL=<model>       (default: haiku for claude; pi default for pi)
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit"
env_backend="${LAZYGIT_AI_COMMIT_BACKEND:-}"
env_model="${LAZYGIT_AI_COMMIT_MODEL:-}"

if [ -f "$config_dir/machine.env" ]; then
  # shellcheck disable=SC1090
  . "$config_dir/machine.env"
fi

[ -n "$env_backend" ] && LAZYGIT_AI_COMMIT_BACKEND="$env_backend"
[ -n "$env_model" ] && LAZYGIT_AI_COMMIT_MODEL="$env_model"

backend="${LAZYGIT_AI_COMMIT_BACKEND:-claude}"
model="${LAZYGIT_AI_COMMIT_MODEL:-}"

if git diff --cached --quiet; then
  echo "nothing staged" >&2
  exit 1
fi

case "$backend" in
  claude)
    : "${model:=haiku}"
    msg=$(git diff --cached | head -c 60000 | claude -p \
      --model "$model" \
      --settings '{"disableAllHooks":true,"includeCoAuthoredBy":false}' \
      "/caveman:caveman-commit Staged diff on stdin. Output only the raw commit message (subject, optional body), starting directly with the subject line. Do not wrap it in markdown code fences or triple backticks. No quotes, no Co-Authored-By or other trailers.")
    ;;
  pi)
    # lazygit/nvim do not load .zshrc, so PI_CODING_AGENT_DIR may be unset and
    # pi would fall back to a different (unauthenticated) config directory.
    : "${PI_CODING_AGENT_DIR:=$HOME/.config/pi/agent}"
    export PI_CODING_AGENT_DIR

    prompt="Generate a git commit message for the staged diff on stdin. Output only the raw commit message (subject, optional body), starting directly with the subject line. Do not wrap it in markdown code fences or triple backticks. No quotes, no Co-Authored-By or other trailers."
    if [ -n "$model" ]; then
      msg=$(git diff --cached | head -c 60000 | pi -p --no-tools --no-session --no-extensions --no-skills --no-prompt-templates --no-context-files --model "$model" "$prompt")
    else
      # No model: use pi's configured default, including its default provider.
      msg=$(git diff --cached | head -c 60000 | pi -p --no-tools --no-session --no-extensions --no-skills --no-prompt-templates --no-context-files "$prompt")
    fi
    ;;
  *)
    echo "unknown LAZYGIT_AI_COMMIT_BACKEND: $backend" >&2
    exit 1
    ;;
esac

if [ -z "$msg" ]; then
  exit 1
fi

# Remove markdown fences even if the model ignores the prompt, drop
# Co-Authored-By trailers, and trim leading/trailing blank lines.
pending="$(git rev-parse --git-dir)/LAZYGIT_PENDING_COMMIT"
printf '%s\n' "$msg" |
  sed -e 's/^[[:space:]]*```[[:alnum:]_+.-]*[[:space:]]*$//' -e 's/```//g' |
  grep -iv '^co-authored-by:' |
  awk '
    /^[[:space:]]*$/ {
      if (started) blanks = blanks "\n"
      next
    }
    {
      if (!started) started = 1
      if (blanks) { printf "%s", blanks; blanks = "" }
      print
    }
  ' >"$pending"

if [ ! -s "$pending" ]; then
  rm -f "$pending"
  exit 1
fi
