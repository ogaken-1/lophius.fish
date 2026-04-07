# lophius.fish
# ref: ../conf.d/lophius.fish

function __lophius_load_rules
  set -g __lophius_rules_loaded && return
  set -g __lophius_rules_loaded 1

  for dir in $fish_function_path
    for file in $dir/__lophius_rule_*.fish
      test -f $file && source $file
    end
  end
end

function __lophius_run
  set -l source $argv[1]
  set -l transformer $argv[2]
  set -e argv[1..2]
  set -l opts $argv

  # Run fzf
  # Check if source is a function, if so call directly, otherwise eval
  set -l selections
  if functions -q $source
    set selections ($source | fzf $LOPHIUS_COMMON_OPTS $opts | string split0)
  else
    set selections (eval $source | fzf $LOPHIUS_COMMON_OPTS $opts | string split0)
  end

  # first element is typed key (--expect)
  set -l key $selections[1]
  set -e selections[1]

  if [ (count $selections) -eq 0 ]
    commandline -f repaint
    return
  end

  set -l results
  for sel in $selections
    if [ -n "$transformer" ]
      set -a results (printf '%s' "$sel" | eval $transformer)
    else
      set -a results $sel
    end
  end

  commandline -i (string join ' ' -- (string escape -- $results))
  commandline -f repaint
end

function lophius
  # Skip fzf completion when fish's pager is active (cycling through native completions)
  if commandline --paging-mode
    commandline -f complete
    return
  end

  # Fall back to native completion when mid-token (e.g. typing "git sta<TAB>")
  # to avoid fzf hijacking incremental token completion.
  if test -n (commandline -t)
    commandline -f complete
    return
  end

  __lophius_load_rules

  for func in (functions -a | string match '__lophius_rule_*')
    if $func
      return 0
    end
  end

  __lophius_fallback_complete
end
