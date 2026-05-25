# Test __lophius_dotnet_parse_cmdline output format and values

source (status dirname)/../functions/__lophius_rule_dotnet.fish

# ============================================================
# 1. csproj commands (--project flag)
# ============================================================
@test "dotnet run --project (space)" (__lophius_dotnet_parse_cmdline "dotnet run --project ") = (printf '%s\t%s\n' csproj 'Dotnet Project> ')
@test "dotnet run --project= (equals)" (__lophius_dotnet_parse_cmdline "dotnet run --project=") = (printf '%s\t%s\n' csproj 'Dotnet Project> ')
@test "dotnet run with options --project (space)" (__lophius_dotnet_parse_cmdline "dotnet run -c Debug --project ") = (printf '%s\t%s\n' csproj 'Dotnet Project> ')
@test "dotnet test --project (space)" (__lophius_dotnet_parse_cmdline "dotnet test --project ") = (printf '%s\t%s\n' csproj 'Dotnet Project> ')
@test "dotnet test --project= (equals)" (__lophius_dotnet_parse_cmdline "dotnet test --project=") = (printf '%s\t%s\n' csproj 'Dotnet Project> ')

# ============================================================
# 2. solution commands (build / restore)
# ============================================================
@test "dotnet build (no args)" (__lophius_dotnet_parse_cmdline "dotnet build ") = (printf '%s\t%s\n' solution 'Dotnet Solution> ')
@test "dotnet restore (no args)" (__lophius_dotnet_parse_cmdline "dotnet restore ") = (printf '%s\t%s\n' solution 'Dotnet Solution> ')
@test "dotnet build with options" (__lophius_dotnet_parse_cmdline "dotnet build -v normal ") = (printf '%s\t%s\n' solution 'Dotnet Solution> ')

# ============================================================
# 3. Negative cases (should not match)
# ============================================================
@test "dotnet build with positional arg should not match" (test -z (__lophius_dotnet_parse_cmdline "dotnet build foo.csproj ")) $status -eq 0
@test "dotnet restore with positional arg should not match" (test -z (__lophius_dotnet_parse_cmdline "dotnet restore ./path ")) $status -eq 0
@test "dotnet run without --project should not match" (test -z (__lophius_dotnet_parse_cmdline "dotnet run ")) $status -eq 0
@test "dotnet without subcommand should not match" (test -z (__lophius_dotnet_parse_cmdline "dotnet ")) $status -eq 0
@test "dotnet publish should not match" (test -z (__lophius_dotnet_parse_cmdline "dotnet publish ")) $status -eq 0
@test "non-dotnet command should not match" (test -z (__lophius_dotnet_parse_cmdline "git status ")) $status -eq 0
@test "dotnet build with end-of-options separator should not match" (test -z (__lophius_dotnet_parse_cmdline "dotnet build -- foo ")) $status -eq 0
@test "dotnet restore with end-of-options separator should not match" (test -z (__lophius_dotnet_parse_cmdline "dotnet restore -- myarg ")) $status -eq 0
@test "dotnet build with long flag --no-restore should match" (__lophius_dotnet_parse_cmdline "dotnet build --no-restore ") = (printf '%s\t%s\n' solution 'Dotnet Solution> ')
@test "dotnet build with long flag --verbosity value should match" (__lophius_dotnet_parse_cmdline "dotnet build --verbosity normal ") = (printf '%s\t%s\n' solution 'Dotnet Solution> ')
