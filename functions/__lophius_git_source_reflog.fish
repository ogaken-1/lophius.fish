function __lophius_git_source_reflog
  set -l format '%C(magenta)%h%x09%C(yellow)%cr%x09%C(blue)[%an]%x09%C(auto)%s%d'
  git reflog --decorate --color=always --format="%C(green)[reflog] $format" 2>/dev/null | column -t -s (printf '\t')
end
