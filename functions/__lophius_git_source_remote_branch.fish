function __lophius_git_source_remote_branch
  set -l format '%(color:magenta)%(refname:short)%09%(color:yellow)%(authordate:short)%09%(color:blue)[%(authorname)]'
  git for-each-ref refs/remotes --color=always --format="%(color:green)[remote] $format" 2>/dev/null | column -t -s (printf '\t')
end
