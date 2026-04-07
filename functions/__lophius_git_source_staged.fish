function __lophius_git_source_staged
  git diff --cached --name-only --relative -z
end
