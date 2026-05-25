# Test __lophius_dotnet_build_config output format and values
# The function outputs null-separated: source, transformer, then opts
# Arguments: source_type prompt

source (status dirname)/../functions/__lophius_rule_dotnet.fish
source (status dirname)/../conf.d/lophius.fish

# Helper function to parse build_config output
# Arguments: source_type prompt
function _parse_dotnet_build_config
  set -l source_type $argv[1]
  set -l prompt $argv[2]

  # Parse null-separated output
  set -l output (__lophius_dotnet_build_config $source_type $prompt | string split0)

  # First is source, second is transformer, rest are opts
  set -l source $output[1]
  set -l transformer $output[2]
  set -l opts $output[3..]

  echo "source:$source"
  if test -z "$transformer"
    echo "transformer:EMPTY"
  else
    echo "transformer:$transformer"
  end
  if string match -q "*--prompt=*" -- $opts
    echo "opts:has_prompt"
  else
    echo "opts:no_prompt"
  end
  if contains -- --read0 $opts
    echo "opts:has_read0"
  else
    echo "opts:no_read0"
  end
end

# ============================================================
# csproj type
# ============================================================
@test "csproj: source contains *.csproj" (
  set -l source (__lophius_dotnet_build_config csproj 'Dotnet Project> ' | string split0)[1]
  string match -q "*csproj*" -- $source
) $status -eq 0

@test "csproj: source does not contain *.sln" (
  set -l source (__lophius_dotnet_build_config csproj 'Dotnet Project> ' | string split0)[1]
  not string match -q "*.sln*" -- $source
) $status -eq 0

@test "csproj: transformer is empty" (
  set result (_parse_dotnet_build_config csproj "Dotnet Project> ")
  string match -q "*transformer:EMPTY*" -- $result
) $status -eq 0

@test "csproj: opts has prompt" (
  set result (_parse_dotnet_build_config csproj "Dotnet Project> ")
  string match -q "*opts:has_prompt*" -- $result
) $status -eq 0

@test "csproj: opts has read0" (
  set result (_parse_dotnet_build_config csproj "Dotnet Project> ")
  string match -q "*opts:has_read0*" -- $result
) $status -eq 0

# ============================================================
# solution type
# ============================================================
@test "solution: source contains *.csproj" (
  set -l source (__lophius_dotnet_build_config solution 'Dotnet Solution> ' | string split0)[1]
  string match -q "*csproj*" -- $source
) $status -eq 0

@test "solution: source contains *.sln" (
  set -l source (__lophius_dotnet_build_config solution 'Dotnet Solution> ' | string split0)[1]
  string match -q "*.sln*" -- $source
) $status -eq 0

@test "solution: source contains *.slnx" (
  set -l source (__lophius_dotnet_build_config solution 'Dotnet Solution> ' | string split0)[1]
  string match -q "*.slnx*" -- $source
) $status -eq 0

@test "solution: transformer is empty" (
  set result (_parse_dotnet_build_config solution "Dotnet Solution> ")
  string match -q "*transformer:EMPTY*" -- $result
) $status -eq 0

@test "solution: opts has prompt" (
  set result (_parse_dotnet_build_config solution "Dotnet Solution> ")
  string match -q "*opts:has_prompt*" -- $result
) $status -eq 0

@test "solution: opts has read0" (
  set result (_parse_dotnet_build_config solution "Dotnet Solution> ")
  string match -q "*opts:has_read0*" -- $result
) $status -eq 0

# ============================================================
# Direct output verification
# ============================================================
@test "csproj: direct source check has csproj" (
  string match -q "*csproj*" -- (__lophius_dotnet_build_config csproj 'test> ' | string split0)[1]
) $status -eq 0
@test "solution: direct source check has sln" (
  string match -q "*.sln*" -- (__lophius_dotnet_build_config solution 'test> ' | string split0)[1]
) $status -eq 0

@test "prompt is passed correctly to opts" (
  set -l opts (__lophius_dotnet_build_config csproj 'My Prompt> ' | string split0)[3..]
  string match -q "*--prompt=My Prompt>*" -- $opts
) $status -eq 0
