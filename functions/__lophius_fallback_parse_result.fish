# Parse fzf --print0 --expect output
# Input (stdin): NUL-delimited: key\0selection1\0selection2\0...
# Output: selections (one per line), with the key element dropped
function __lophius_fallback_parse_result
  # Read stdin to a temp file to preserve NUL bytes (command substitution strips NULs)
  set -l tmpfile (mktemp)
  tee $tmpfile > /dev/null
  set -l tokens (string split0 < $tmpfile)
  rm $tmpfile
  # Drop the first element (key name) and print the rest
  if test (count $tokens) -gt 1
    printf '%s\n' $tokens[2..]
  end
end
