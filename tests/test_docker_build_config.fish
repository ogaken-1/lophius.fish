# Test __lophius_docker_build_config output format and values
# The function outputs null-separated: source, transformer, then opts
# Arguments: source_type multi bind_type prompt

source (status dirname)/../functions/__lophius_rule_docker.fish
source (status dirname)/../conf.d/lophius.fish

# Helper function to parse build_config output
# Arguments: source_type multi bind_type prompt
function _parse_build_config
  set -l source_type $argv[1]
  set -l multi $argv[2]
  set -l bind_type $argv[3]
  set -l prompt $argv[4]

  # Parse null-separated output
  set -l output (__lophius_docker_build_config $source_type $multi $bind_type $prompt | string split0)

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

# ============================================================
# container type
# ============================================================
@test "container: source is container source" (
  set result (_parse_build_config container true default "Test> ")
  string match -q "source:__lophius_docker_source_container" -- $result
) $status -eq 0

@test "container: transformer is docker_to_arg" (
  set result (_parse_build_config container true default "Test> ")
  string match -q "*transformer:__lophius_docker_to_arg*" -- $result
) $status -eq 0

@test "container: opts has prompt" (
  set result (_parse_build_config container true default "Test> ")
  string match -q "*opts:has_prompt*" -- $result
) $status -eq 0

@test "container: opts has multi when multi=true" (
  set result (_parse_build_config container true default "Test> ")
  string match -q "*opts:has_multi*" -- $result
) $status -eq 0

@test "container: opts does not have multi when multi=false" (
  set result (_parse_build_config container false default "Test> ")
  string match -q "*opts:no_multi*" -- $result
) $status -eq 0

# ============================================================
# container_running type
# ============================================================
@test "container_running: source is container_running source" (
  set result (_parse_build_config container_running true default "Test> ")
  string match -q "source:__lophius_docker_source_container_running" -- $result
) $status -eq 0

@test "container_running: transformer is docker_to_arg" (
  set result (_parse_build_config container_running true default "Test> ")
  string match -q "*transformer:__lophius_docker_to_arg*" -- $result
) $status -eq 0

@test "container_running: opts has multi when multi=true" (
  set result (_parse_build_config container_running true default "Test> ")
  string match -q "*opts:has_multi*" -- $result
) $status -eq 0

@test "container_running: opts does not have multi when multi=false" (
  set result (_parse_build_config container_running false default "Test> ")
  string match -q "*opts:no_multi*" -- $result
) $status -eq 0

# ============================================================
# image type
# ============================================================
@test "image: source is image source" (
  set result (_parse_build_config image true default "Test> ")
  string match -q "source:__lophius_docker_source_image" -- $result
) $status -eq 0

@test "image: transformer is docker_to_arg" (
  set result (_parse_build_config image true default "Test> ")
  string match -q "*transformer:__lophius_docker_to_arg*" -- $result
) $status -eq 0

@test "image: opts has multi when multi=true" (
  set result (_parse_build_config image true default "Test> ")
  string match -q "*opts:has_multi*" -- $result
) $status -eq 0

@test "image: opts does not have multi when multi=false" (
  set result (_parse_build_config image false default "Test> ")
  string match -q "*opts:no_multi*" -- $result
) $status -eq 0

# ============================================================
# volume type
# ============================================================
@test "volume: source is volume source" (
  set result (_parse_build_config volume true default "Test> ")
  string match -q "source:__lophius_docker_source_volume" -- $result
) $status -eq 0

@test "volume: transformer is docker_to_arg" (
  set result (_parse_build_config volume true default "Test> ")
  string match -q "*transformer:__lophius_docker_to_arg*" -- $result
) $status -eq 0

@test "volume: opts has multi when multi=true" (
  set result (_parse_build_config volume true default "Test> ")
  string match -q "*opts:has_multi*" -- $result
) $status -eq 0

@test "volume: opts does not have multi when multi=false" (
  set result (_parse_build_config volume false default "Test> ")
  string match -q "*opts:no_multi*" -- $result
) $status -eq 0

# ============================================================
# network type
# ============================================================
@test "network: source is network source" (
  set result (_parse_build_config network true default "Test> ")
  string match -q "source:__lophius_docker_source_network" -- $result
) $status -eq 0

@test "network: transformer is docker_to_arg" (
  set result (_parse_build_config network true default "Test> ")
  string match -q "*transformer:__lophius_docker_to_arg*" -- $result
) $status -eq 0

@test "network: opts has multi when multi=true" (
  set result (_parse_build_config network true default "Test> ")
  string match -q "*opts:has_multi*" -- $result
) $status -eq 0

@test "network: opts does not have multi when multi=false" (
  set result (_parse_build_config network false default "Test> ")
  string match -q "*opts:no_multi*" -- $result
) $status -eq 0

# ============================================================
# Direct output verification (simpler tests)
# ============================================================
@test "container: direct source check" (__lophius_docker_build_config container false default 'test> ' | string split0)[1] = __lophius_docker_source_container
@test "container_running: direct source check" (__lophius_docker_build_config container_running false default 'test> ' | string split0)[1] = __lophius_docker_source_container_running
@test "image: direct source check" (__lophius_docker_build_config image false default 'test> ' | string split0)[1] = __lophius_docker_source_image
@test "volume: direct source check" (__lophius_docker_build_config volume false default 'test> ' | string split0)[1] = __lophius_docker_source_volume
@test "network: direct source check" (__lophius_docker_build_config network false default 'test> ' | string split0)[1] = __lophius_docker_source_network

# All types use the same transformer
@test "all types use same transformer" (__lophius_docker_build_config container false default 'test> ' | string split0)[2] = __lophius_docker_to_arg
