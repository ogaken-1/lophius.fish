function __lophius_git_source_log
  set -l format '%C(magenta)%h%x09%C(yellow)%cr%x09%C(blue)[%an]%x09%C(auto)%s%d'
  git log --decorate --color=always --format="%C(green)[commit] $format" | column -t -s (printf '\t')
end
