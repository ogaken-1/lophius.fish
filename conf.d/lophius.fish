# lophius.fish
#
# Git completion patterns ported from zeno.zsh
# https://github.com/yuki-yano/zeno.zsh
#
# SPDX-License-Identifier: MIT
# See LICENSE file for full license information

# === User Configuration ===
set -g LOPHIUS_GIT_CAT 'cat'
set -g LOPHIUS_GIT_TREE 'tree'

# === Preview Commands ===
set -g LOPHIUS_GIT_STATUS_PREVIEW "! git diff --exit-code --color=always -- {-1} || ! git diff --exit-code --cached --color=always -- {-1} 2>/dev/null || $LOPHIUS_GIT_TREE {-1} 2>/dev/null"
set -g LOPHIUS_GIT_LS_FILES_PREVIEW "$LOPHIUS_GIT_CAT {}"
set -g LOPHIUS_GIT_STAGED_PREVIEW 'git diff --cached --color=always -- {}'
set -g LOPHIUS_GIT_MODIFIED_PREVIEW 'git diff --color=always -- {}'
set -g LOPHIUS_GIT_LOG_PREVIEW 'git show --color=always {2}'
set -g LOPHIUS_GIT_STASH_PREVIEW 'git show --color=always {1}'
set -g LOPHIUS_GIT_REF_PREVIEW "
  switch {1}
    case '[branch]' '[remote]'
      git log {2} --decorate --pretty='format:%C(yellow)%h %C(green)%cd %C(reset)%s%C(red)%d %C(cyan)[%an]' --date=iso --graph --color=always
    case '[switch]'
      # Try local branch first, then fall back to remote ref
      git log {2} --decorate --pretty='format:%C(yellow)%h %C(green)%cd %C(reset)%s%C(red)%d %C(cyan)[%an]' --date=iso --graph --color=always 2>/dev/null; or git log (git for-each-ref --format='%(refname:short)' 'refs/remotes/*/{2}' | head -1) --decorate --pretty='format:%C(yellow)%h %C(green)%cd %C(reset)%s%C(red)%d %C(cyan)[%an]' --date=iso --graph --color=always
    case '[tag]'
      git log {2} --pretty='format:%C(yellow)%h %C(green)%cd %C(reset)%s%C(red)%d %C(cyan)[%an]' --date=iso --graph --color=always
    case '[commit]' '[reflog]'
      git show --color=always {2}
  end
"
set -g LOPHIUS_GIT_AUTHOR_PREVIEW "git --no-pager log --author={} --oneline --color=always --format='%C(green)%h%C(reset) %C(yellow)%ad%C(reset) %s' --date=short | head -n 100"

# === Key Bindings ===
set -g LOPHIUS_GIT_DEFAULT_BIND 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up,?:toggle-preview'
set -g LOPHIUS_GIT_REF_BIND "ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up,?:toggle-preview,ctrl-b:reload(fish -c __lophius_git_source_branch),ctrl-c:reload(fish -c __lophius_git_source_log),ctrl-t:reload(fish -c __lophius_git_source_tag),ctrl-r:reload(fish -c __lophius_git_source_reflog)"

# === Common Options
set -g LOPHIUS_COMMON_OPTS \
  --ansi \
  --expect=alt-enter \
  --height='80%' \
  --print0 \
  --no-separator \
  --select-1

# === Headers ===
set -g LOPHIUS_GIT_REF_HEADER_FULL 'C-b: branch, C-c: commit, C-t: tag, C-r: reflog'
set -g LOPHIUS_GIT_REF_HEADER_NO_COMMIT 'C-b: branch, C-t: tag, C-r: reflog'

# === Preset Options ===
set -g LOPHIUS_GIT_PRESET_STATUS \
  --multi --no-sort \
  --bind=$LOPHIUS_GIT_DEFAULT_BIND \
  --preview=$LOPHIUS_GIT_STATUS_PREVIEW

set -g LOPHIUS_GIT_PRESET_LS_FILES \
  --multi --read0 \
  --bind=$LOPHIUS_GIT_DEFAULT_BIND \
  --preview=$LOPHIUS_GIT_LS_FILES_PREVIEW

set -g LOPHIUS_GIT_PRESET_STAGED \
  --multi --read0 \
  --bind=$LOPHIUS_GIT_DEFAULT_BIND \
  --preview=$LOPHIUS_GIT_STAGED_PREVIEW

set -g LOPHIUS_GIT_PRESET_MODIFIED \
  --multi --read0 \
  --bind=$LOPHIUS_GIT_DEFAULT_BIND \
  --preview=$LOPHIUS_GIT_MODIFIED_PREVIEW

set -g LOPHIUS_GIT_PRESET_REF_NO_HEADER \
  --bind=$LOPHIUS_GIT_REF_BIND \
  --preview=$LOPHIUS_GIT_REF_PREVIEW \
  --preview-window=down

set -g LOPHIUS_GIT_PRESET_REF \
  $LOPHIUS_GIT_PRESET_REF_NO_HEADER \
  --header=$LOPHIUS_GIT_REF_HEADER_FULL

set -g LOPHIUS_GIT_PRESET_LOG_SIMPLE \
  --no-sort \
  --bind=$LOPHIUS_GIT_DEFAULT_BIND \
  --preview=$LOPHIUS_GIT_LOG_PREVIEW

set -g LOPHIUS_GIT_PRESET_STASH \
  --bind=$LOPHIUS_GIT_DEFAULT_BIND \
  --preview=$LOPHIUS_GIT_STASH_PREVIEW

set -g LOPHIUS_GIT_PRESET_REMOTE \
  --bind=$LOPHIUS_GIT_DEFAULT_BIND

set -g LOPHIUS_GIT_PRESET_AUTHOR \
  --bind=$LOPHIUS_GIT_DEFAULT_BIND \
  --preview=$LOPHIUS_GIT_AUTHOR_PREVIEW

# ============================================================
# Docker Configuration
# ============================================================

# === Docker Preview Commands ===
set -g LOPHIUS_DOCKER_CONTAINER_PREVIEW 'docker inspect {1} 2>/dev/null | jq -C ".[0] | {Id, Name, Image, State, Mounts: .Mounts[0:3], Ports: .NetworkSettings.Ports}" 2>/dev/null || docker inspect {1}'
set -g LOPHIUS_DOCKER_IMAGE_PREVIEW 'docker inspect {1} 2>/dev/null | jq -C ".[0] | {Id, RepoTags, Size, Created, Architecture, Os}" 2>/dev/null || docker inspect {1}'
set -g LOPHIUS_DOCKER_VOLUME_PREVIEW 'docker volume inspect {1} 2>/dev/null | jq -C ".[0]" 2>/dev/null || docker volume inspect {1}'
set -g LOPHIUS_DOCKER_NETWORK_PREVIEW 'docker network inspect {1} 2>/dev/null | jq -C ".[0] | {Name, Driver, Scope, IPAM, Containers}" 2>/dev/null || docker network inspect {1}'

# === Docker Key Bindings ===
set -g LOPHIUS_DOCKER_DEFAULT_BIND 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up,?:toggle-preview'

# === Docker Preset Options ===
set -g LOPHIUS_DOCKER_PRESET_CONTAINER \
  --no-sort \
  --bind=$LOPHIUS_DOCKER_DEFAULT_BIND \
  --preview=$LOPHIUS_DOCKER_CONTAINER_PREVIEW \
  --preview-window=right:50%

set -g LOPHIUS_DOCKER_PRESET_IMAGE \
  --no-sort \
  --bind=$LOPHIUS_DOCKER_DEFAULT_BIND \
  --preview=$LOPHIUS_DOCKER_IMAGE_PREVIEW \
  --preview-window=right:50%

set -g LOPHIUS_DOCKER_PRESET_VOLUME \
  --bind=$LOPHIUS_DOCKER_DEFAULT_BIND \
  --preview=$LOPHIUS_DOCKER_VOLUME_PREVIEW \
  --preview-window=right:40%

set -g LOPHIUS_DOCKER_PRESET_NETWORK \
  --bind=$LOPHIUS_DOCKER_DEFAULT_BIND \
  --preview=$LOPHIUS_DOCKER_NETWORK_PREVIEW \
  --preview-window=right:40%

if [ -z "$LOPHIUS_NO_DEFAULT_BINDING" ]
  bind tab lophius
end

