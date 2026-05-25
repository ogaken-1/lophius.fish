# __lophius_rule_dotnet.fish - Dotnet completion rules
# See: ../conf.d/lophius.fish ./lophius.fish
#
# Dotnet completion patterns for .csproj, .sln, and .slnx project files

# === Parser ===
# Parse commandline and return completion metadata
# Output format: source_type\tprompt
# source_type: csproj, solution
# Outputs nothing if no match found
function __lophius_dotnet_parse_cmdline
  set -l cmd $argv[1]

  # dotnet run/test --project (space or equals)
  if string match -rq '^dotnet (?:run|test)(?: .*)? --project(?:=| )$' -- $cmd
    printf '%s\t%s\n' csproj 'Dotnet Project> '

  # dotnet build/restore with no positional arguments (allows -flag [value] pairs)
  else if string match -rq '^dotnet (?:build|restore) (?:-(?:-[^- ]|[^- ])[^ ]* (?:[^-][^ ]* )?)*$' -- $cmd
    printf '%s\t%s\n' solution 'Dotnet Solution> '

  end
end

# === Config Builder ===
# Build fzf configuration for dotnet completion
# Arguments: source_type prompt
# Output: null-separated values: source, transformer, opts...
function __lophius_dotnet_build_config
  set -l source_type $argv[1]
  set -l prompt $argv[2]

  set -l source
  set -l transformer ''
  set -l opts

  switch $source_type
    case csproj
      set source "find . -maxdepth 5 \\( -name .git -o -name node_modules -o -name bin -o -name obj \\) -prune -o -name '*.csproj' -type f -print0"
      set -a opts $LOPHIUS_DOTNET_PRESET_PROJECT
    case solution
      set source "find . -maxdepth 5 \\( -name .git -o -name node_modules -o -name bin -o -name obj \\) -prune -o \\( -name '*.csproj' -o -name '*.sln' -o -name '*.slnx' \\) -type f -print0"
      set -a opts $LOPHIUS_DOTNET_PRESET_PROJECT
  end

  # Add prompt and read0
  set -a opts --prompt=$prompt
  set -a opts --read0

  # Output null-separated
  printf '%s\0' $source $transformer $opts
end

function __lophius_rule_dotnet
  set -l cmd (commandline)

  # Parse commandline to get completion metadata
  set -l parse_result (__lophius_dotnet_parse_cmdline $cmd)
  test -z "$parse_result" && return 1

  # Split result into source_type and prompt
  set -l parts (string split \t $parse_result)
  set -l source_type $parts[1]
  set -l prompt $parts[2]

  # Build configuration and parse null-separated output
  set -l config_output (__lophius_dotnet_build_config $source_type $prompt | string split0)

  # First element is source, second is transformer, rest are opts
  set -l source $config_output[1]
  set -l transformer $config_output[2]
  set -l opts $config_output[3..]

  __lophius_run "$source" "$transformer" $LOPHIUS_COMMON_OPTS $opts
  return 0
end
