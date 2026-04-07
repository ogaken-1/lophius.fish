function __lophius_git_source_branch
  set -l format '%(color:magenta)%(refname:short)%09%(color:yellow)%(authordate:short)%09%(color:blue)[%(authorname)]'
  git for-each-ref refs/heads refs/remotes --color=always --format="%(color:green)[branch] $format" 2>/dev/null | column -t -s (printf '\t')
end
