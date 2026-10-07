#!/usr/bin/env bash
# Reinstall herdr plugins at pinned revisions
set -euo pipefail

herdr plugin install -y ChmaraX/herdr-nvim --ref 5e849b5377fd409d2fd4be159c9c9fa36c251f7a
herdr plugin install -y bojackduy/nvim-herdr-navigation/herdr-vim-navigator --ref 7798a2f027465698cb1a51695327e138319f61f3
