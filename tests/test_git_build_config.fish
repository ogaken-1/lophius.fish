# Test __lophius_git_build_config output format and values
# The function outputs null-separated: source, transformer, then opts
# Arguments: source_type multi bind_type prompt

source (status dirname)/../functions/__lophius_rule_git.fish
source (status dirname)/../conf.d/lophius.fish

# Helper function to parse build_config output
# Arguments: source_type multi bind_type prompt
function _parse_build_config
  set -l source_type $argv[1]
  set -l multi $argv[2]
  set -l bind_type $argv[3]
  set -l prompt $argv[4]

  # Parse null-separated output
  set -l output (__lophius_git_build_config $source_type $multi $bind_type $prompt | string split0)

  # First is source, second is transformer, rest are opts
  set -l source $output[1]
  set -l transformer $output[2]
  set -l opts $output[3..]

  # Return results
  echo "source:$source"
  if test -z "$transformer"
    echo "transformer:EMPTY"
  else
    echo "transformer:$transformer"
  end
  if contains -- --multi $opts
    echo "opts:has_multi"
  else
    echo "opts:no_multi"
  end
  if string match -q "*--prompt=*" -- $opts
    echo "opts:has_prompt"
  else
    echo "opts:no_prompt"
  end
end

# === Test status_file type ===
@test "status_file: source is status source" (
  set result (_parse_build_config status_file true file "Test> ")
  string match -q "source:*status*" -- $result
) $status -eq 0

@test "status_file: transformer is status_to_arg" (
  set result (_parse_build_config status_file true file "Test> ")
  string match -q "*transformer:__lophius_git_status_to_arg*" -- $result
) $status -eq 0

@test "status_file: opts has prompt" (
  set result (_parse_build_config status_file true file "Test> ")
  string match -q "*opts:has_prompt*" -- $result
) $status -eq 0

# === Test branch type (singular - no --multi) ===
@test "branch: source is branch source" (
  set result (_parse_build_config branch false ref_full "Test> ")
  string match -q "source:__lophius_git_source_branch" -- $result
) $status -eq 0

@test "branch: transformer is ref_to_arg" (
  set result (_parse_build_config branch false ref_full "Test> ")
  string match -q "*transformer:__lophius_git_ref_to_arg*" -- $result
) $status -eq 0

@test "branch: opts does not have multi when multi=false" (
  set result (_parse_build_config branch false ref_full "Test> ")
  string match -q "*opts:no_multi*" -- $result
) $status -eq 0

# === Test branch type with multi=true ===
@test "branch with multi=true: opts has multi" (
  set result (_parse_build_config branch true ref_full "Test> ")
  string match -q "*opts:has_multi*" -- $result
) $status -eq 0

# === Test commit type ===
@test "commit: source is log source" (
  set result (_parse_build_config commit false ref_full "Test> ")
  string match -q "source:__lophius_git_source_log" -- $result
) $status -eq 0

@test "commit: transformer is ref_to_arg" (
  set result (_parse_build_config commit false ref_full "Test> ")
  string match -q "*transformer:__lophius_git_ref_to_arg*" -- $result
) $status -eq 0

# === Test ls_file type ===
@test "ls_file: source is ls-files" (
  set result (_parse_build_config ls_file true file "Test> ")
  string match -q "source:__lophius_git_source_ls_files" -- $result
) $status -eq 0

@test "ls_file: transformer is empty" (
  set result (_parse_build_config ls_file true file "Test> ")
  string match -q "*transformer:EMPTY*" -- $result
) $status -eq 0

# === Test tag type ===
@test "tag: source is tag source" (
  set result (_parse_build_config tag false ref_simple "Test> ")
  string match -q "source:__lophius_git_source_tag" -- $result
) $status -eq 0

@test "tag: transformer is ref_to_arg" (
  set result (_parse_build_config tag false ref_simple "Test> ")
  string match -q "*transformer:__lophius_git_ref_to_arg*" -- $result
) $status -eq 0

# === Test stash type ===
@test "stash: source is stash source" (
  set result (_parse_build_config stash false stash "Test> ")
  string match -q "source:__lophius_git_source_stash" -- $result
) $status -eq 0

@test "stash: transformer is stash_to_arg" (
  set result (_parse_build_config stash false stash "Test> ")
  string match -q "*transformer:__lophius_git_stash_to_arg*" -- $result
) $status -eq 0

# === Test branch with ref_simple bind_type (no header) ===
@test "branch ref_simple: source is still branch source" (
  set result (_parse_build_config branch false ref_simple "Test> ")
  string match -q "source:__lophius_git_source_branch" -- $result
) $status -eq 0

# === Test commit with ref_simple bind_type ===
@test "commit ref_simple: uses LOG_SIMPLE preset" (
  set result (_parse_build_config commit false ref_simple "Test> ")
  string match -q "source:__lophius_git_source_log" -- $result
) $status -eq 0

# === Test commit with multi=true ===
@test "commit with multi=true: has multi option" (
  set result (_parse_build_config commit true ref_full "Test> ")
  string match -q "*opts:has_multi*" -- $result
) $status -eq 0

# === Test tag with multi=true ===
@test "tag with multi=true: has multi option" (
  set result (_parse_build_config tag true ref_simple "Test> ")
  string match -q "*opts:has_multi*" -- $result
) $status -eq 0

# === Test stash with multi=true ===
@test "stash with multi=true: has multi option" (
  set result (_parse_build_config stash true stash "Test> ")
  string match -q "*opts:has_multi*" -- $result
) $status -eq 0

# ============================================================
# remote
# ============================================================
@test "remote: source is remote source" (__lophius_git_build_config remote false file 'test> ' | string split0)[1] = __lophius_git_source_remote
@test "remote: transformer is empty" (__lophius_git_build_config remote false file 'test> ' | string split0)[2] = ''

# ============================================================
# remote_branch
# ============================================================
@test "remote_branch: source is remote branch source" (__lophius_git_build_config remote_branch false ref_simple 'test> ' | string split0)[1] = __lophius_git_source_remote_branch
@test "remote_branch: transformer is ref_to_arg" (__lophius_git_build_config remote_branch false ref_simple 'test> ' | string split0)[2] = __lophius_git_ref_to_arg

# ============================================================
# switch_branch
# ============================================================
@test "switch_branch: source is switch branch source" (__lophius_git_build_config switch_branch false ref_simple 'test> ' | string split0)[1] = __lophius_git_source_switch_branch
@test "switch_branch: transformer is ref_to_arg" (__lophius_git_build_config switch_branch false ref_simple 'test> ' | string split0)[2] = __lophius_git_ref_to_arg
