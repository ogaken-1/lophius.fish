# Adapted from junegunn/fzf shell/completion.fish
# Copyright (c) 2013-2025 Junegunn Choi
# Licensed under the MIT License. See LICENSE at the repository root.

function __lophius_fallback_complete
  # Remove any trailing unescaped backslash from token and update command line
  set -l -- token (string replace -r -- '(?<!\\\\)(?:\\\\\\\\)*\\K\\\\$' '' (commandline -t | string collect) | string collect)
  commandline -rt -- $token

  # Remove any line breaks from token
  set -- token (string replace -ra -- '\\\\\\n' '' $token | string collect)

  # Determine commandline tokenize option based on fish version
  set -l -- cl_tokenize_opt '--tokens-expanded'
  string match -q -- '3.*' $version
  and set -- cl_tokenize_opt '--tokenize'

  # Strip launcher prefixes (builtin/command/doas/env/sudo/VAR=val/-opt) to get actual command
  set -l -- r_cmd '^(?:(?:builtin|command|doas|env|sudo|\\w+=\\S*|-\\S+)\\s+)*\\K[\\s\\S]+'

  # Get completion candidates
  set -l -- list (complete -C --escape -- (string join -- ' ' (commandline -pc $cl_tokenize_opt) $token | string collect))

  if test -z "$list"
    commandline -f repaint
    return
  end

  # Calculate tabstop for description alignment
  # Adapted from junegunn/fzf shell/completion.fish (lines 119-133)
  if set -l -- tabstop (string match -rga -- '--tabstop[= ](?:0*)([1-9]\\d+|[4-9])' "$FZF_DEFAULT_OPTS")[-1]
    set -- tabstop (math $tabstop - 4)
  else
    set -- tabstop 4
  end
  set -l -- max_columns (math $COLUMNS - 40)
  for i in $list[1..500]
    set -l -- item (string split -f 1 -- \t $i)
    and set -l -- len (string length -V -- $item)
    and test "$len" -gt "$tabstop" -a "$len" -lt "$max_columns"
    and set -- tabstop $len
  end
  set -- tabstop (math $tabstop + 4)

  # Pipe candidates through fzf with --print0 --expect for NUL-delimited output
  # Result format: key\0selection1\0selection2\0...
  set -l -- result (string collect -- $list \
    | fzf $LOPHIUS_COMMON_OPTS --print0 --expect=alt-enter \
        --delimiter="\t" --tabstop=$tabstop --no-multi-line --wrap-sign=\t"↳ " \
    | __lophius_fallback_parse_result)

  if test -n "$result"
    # Extract first tab-delimited field (completion text without description)
    set -- result (string replace -r -- '\t.*' '' $result)

    # No extra space after single selection that ends with path separator
    set -l -- tail ' '
    test (count $result) -eq 1
    and string match -q -- '*/' "$result"
    and set -- tail ''

    commandline -rt -- (string join -- ' ' $result)$tail
  end

  commandline -f repaint
end
