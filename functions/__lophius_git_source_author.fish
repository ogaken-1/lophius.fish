function __lophius_git_source_author
  git log --format='%an <%ae>' | sort -u
end
