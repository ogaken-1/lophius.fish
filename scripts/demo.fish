#!/usr/bin/env fish
# demo.fish
# Launches an interactive fish session with lophius loaded for demo purposes.
# Usage: just demo

set -l repo_root (dirname (dirname (status --current-filename)))

set -l setup "
set -p fish_function_path $repo_root/functions
source $repo_root/conf.d/lophius.fish

echo ''
echo '  lophius demo'
echo '  ============'
echo '  Press <Tab> to trigger fzf completion.'
echo ''
echo '  Try these commands:'
echo '    ls <Tab>'
echo '    git <Tab>'
echo '    cd <Tab>'
echo '    kill <Tab>'
echo '    git add <Tab>'
echo '    git checkout <Tab>'
echo ''
echo '  Type exit or press Ctrl-D to quit.'
echo ''
"

exec fish --no-config -C $setup -i
