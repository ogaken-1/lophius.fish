function __lophius_git_source_tag
  set -l format '%(color:magenta)%(refname:short)%09%(color:yellow)%(authordate:short)%09%(color:blue)[%(authorname)]'
  git for-each-ref refs/tags --color=always --format="%(color:green)[tag] $format" 2>/dev/null | column -t -s (printf '\t')
end
