# Test __lophius_fallback_parse_result
# Parses fzf --print0 --expect output: drops first element (key name), returns selections

source (status dirname)/../functions/__lophius_fallback_parse_result.fish

# Normal Enter with single selection: key is empty string, then selection
@test "single selection with Enter (empty key)" \
  (printf '\0selection1\0' | __lophius_fallback_parse_result) = "selection1"

# alt-enter pressed with single selection: key is "alt-enter", then selection
@test "single selection with alt-enter" \
  (printf 'alt-enter\0selection1\0' | __lophius_fallback_parse_result) = "selection1"

# Multiple selections (multi-select) with Enter
@test "multiple selections with Enter" \
  (printf '\0sel1\0sel2\0' | __lophius_fallback_parse_result | string collect) = (printf 'sel1\nsel2' | string collect)

# Multiple selections with alt-enter
@test "multiple selections with alt-enter" \
  (printf 'alt-enter\0sel1\0sel2\0' | __lophius_fallback_parse_result | string collect) = (printf 'sel1\nsel2' | string collect)

# Empty input (user cancelled fzf): output nothing
@test "empty input returns nothing" \
  (printf '' | __lophius_fallback_parse_result | count) -eq 0
