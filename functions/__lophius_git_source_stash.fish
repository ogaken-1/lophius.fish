function __lophius_git_source_stash
  set -l format '%C(magenta)%gd%x09%C(yellow)%cr%x09%C(auto)%s'
  git stash list --color=always --format="$format" | column -t -s (printf '\t')
end
