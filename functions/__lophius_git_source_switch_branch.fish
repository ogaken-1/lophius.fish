function __lophius_git_source_switch_branch
  set -l default_remote (git config checkout.defaultRemote 2>/dev/null)
  set -l green (set_color green)
  set -l normal (set_color normal)
  set -l yellow (set_color yellow)
  set -l blue (set_color blue)
  git for-each-ref refs/heads refs/remotes \
    --format="%(refname)%09%(refname:short)%09%(authordate:short)%09%(authorname)" 2>/dev/null | \
  awk -F"\t" -v default_remote="$default_remote" -v green="$green" -v normal="$normal" -v yellow="$yellow" -v blue="$blue" '
    # First pass: collect all data
    {
      refname = $1
      short = $2
      date = $3
      author = $4

      if (refname ~ /^refs\/heads\//) {
        # Local branch
        branch = short
        local_branches[branch] = 1
        if (!(branch in first_date)) {
          first_date[branch] = date
          first_author[branch] = author
        }
      } else if (refname ~ /^refs\/remotes\//) {
        # Remote branch - skip HEAD refs
        if (short ~ /\/HEAD$/) next

        # Extract remote and branch name
        idx = index(short, "/")
        remote = substr(short, 1, idx - 1)
        branch = substr(short, idx + 1)

        # Count occurrences per branch
        remote_count[branch]++
        remote_names[branch, remote_count[branch]] = remote

        if (!(branch in first_date)) {
          first_date[branch] = date
          first_author[branch] = author
        }
      }
    }
    END {
      # Second pass: output filtered results
      for (branch in first_date) {
        include = 0
        if (branch in local_branches) {
          include = 1
        } else if (branch in remote_count) {
          if (remote_count[branch] == 1) {
            include = 1
          } else if (default_remote != "") {
            for (i = 1; i <= remote_count[branch]; i++) {
              if (remote_names[branch, i] == default_remote) {
                include = 1
                break
              }
            }
          }
        }
        if (include) {
          printf "%s[switch]%s %s\t%s%s\t%s[%s]%s\n", green, normal, branch, yellow, first_date[branch], blue, first_author[branch], normal
        }
      }
    }
  ' | sort -t" " -k2 | column -t -s (printf "\t")
end
