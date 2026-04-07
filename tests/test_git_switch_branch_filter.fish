# Test LOPHIUS_GIT_SWITCH_BRANCH_SOURCE filtering logic
#
# The filtering rules are:
# 1. Local branches: Always included
# 2. Remote branches:
#    - If no duplicate (only exists in one remote): included
#    - If duplicate exists AND checkout.defaultRemote is NOT set: excluded
#    - If duplicate exists AND checkout.defaultRemote is set AND matches: included
#    - If duplicate exists AND checkout.defaultRemote is set but doesn't match: excluded
# 3. HEAD references (e.g., origin/HEAD): Always excluded

source (status dirname)/../conf.d/lophius.fish

# Add functions directory to fish_function_path for autoloading
set -g fish_function_path (status dirname)/../functions $fish_function_path

# ============================================================
# Helper functions
# ============================================================

# Setup a test git repository with an initial commit
function _setup_test_repo
    set -g _test_repo_dir (mktemp -d)
    set -g _test_original_dir (pwd)
    # Isolate from user's git config
    set -gx GIT_CONFIG_GLOBAL /dev/null
    set -gx GIT_CONFIG_NOSYSTEM 1
    cd $_test_repo_dir
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    git commit --allow-empty -m "initial" --quiet
end

# Cleanup test repository
function _cleanup_test_repo
    cd $_test_original_dir
    rm -rf $_test_repo_dir
    set -e _test_repo_dir
    set -e _test_original_dir
    # Restore git config environment
    set -e GIT_CONFIG_GLOBAL
    set -e GIT_CONFIG_NOSYSTEM
end

# Get branch names from switch_branch source output (extracts second field after [switch])
function _get_switch_branches
    __lophius_git_source_switch_branch 2>/dev/null | \
        string replace -ra '\x1b\[[0-9;]*m' '' | \
        string match -r '\[switch\]\s+(\S+)' | \
        string match -rv '^\[switch\]'
end

# Check if a branch name is in the output
# Returns 0 (true) if found, 1 (false) otherwise
function _branch_included -a branch_name
    set -l branches (_get_switch_branches)
    contains -- $branch_name $branches
    return $status
end

# Count occurrences of a branch name in the output
function _count_branch_occurrences -a branch_name
    set -l branches (_get_switch_branches)
    set -l count 0
    for b in $branches
        if test "$b" = "$branch_name"
            set count (math $count + 1)
        end
    end
    echo $count
end

# ============================================================
# 1. Basic cases
# ============================================================

@test "switch_branch: local branch only is included" (
    _setup_test_repo
    git branch test-local
    _branch_included test-local
    set -l result $status
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "switch_branch: remote branch (single remote, no local) is included" (
    _setup_test_repo
    # Create a fake remote ref using update-ref
    git update-ref refs/remotes/origin/feature-remote HEAD
    _branch_included feature-remote
    set -l result $status
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "switch_branch: local branch takes precedence over same-named remote" (
    _setup_test_repo
    git branch main-test
    git update-ref refs/remotes/origin/main-test HEAD
    set -l count (_count_branch_occurrences main-test)
    _cleanup_test_repo
    # main-test should appear exactly once (local takes precedence)
    test $count -eq 1
) $status -eq 0

# ============================================================
# 2. Duplicate handling (no defaultRemote)
# ============================================================

@test "switch_branch: branch on 2 remotes without defaultRemote is excluded" (
    _setup_test_repo
    git config --unset checkout.defaultRemote 2>/dev/null; or true
    git update-ref refs/remotes/origin/dup-branch HEAD
    git update-ref refs/remotes/upstream/dup-branch HEAD
    _branch_included dup-branch
    set -l result $status
    _cleanup_test_repo
    # Should NOT be included (result should be non-zero)
    test $result -ne 0
) $status -eq 0

@test "switch_branch: branch on 3 remotes without defaultRemote is excluded" (
    _setup_test_repo
    git config --unset checkout.defaultRemote 2>/dev/null; or true
    git update-ref refs/remotes/origin/triple-branch HEAD
    git update-ref refs/remotes/upstream/triple-branch HEAD
    git update-ref refs/remotes/fork/triple-branch HEAD
    _branch_included triple-branch
    set -l result $status
    _cleanup_test_repo
    # Should NOT be included (result should be non-zero)
    test $result -ne 0
) $status -eq 0

# ============================================================
# 3. Duplicate handling (with defaultRemote)
# ============================================================

@test "switch_branch: branch on 2 remotes with defaultRemote matching first is included" (
    _setup_test_repo
    git config checkout.defaultRemote origin
    git update-ref refs/remotes/origin/dup-default HEAD
    git update-ref refs/remotes/upstream/dup-default HEAD
    _branch_included dup-default
    set -l result $status
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "switch_branch: branch on 2 remotes with defaultRemote matching second is included" (
    _setup_test_repo
    git config checkout.defaultRemote upstream
    git update-ref refs/remotes/origin/dup-default2 HEAD
    git update-ref refs/remotes/upstream/dup-default2 HEAD
    _branch_included dup-default2
    set -l result $status
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "switch_branch: branch on 2 remotes with defaultRemote matching neither is excluded" (
    _setup_test_repo
    git config checkout.defaultRemote other-remote
    git update-ref refs/remotes/origin/dup-nomatch HEAD
    git update-ref refs/remotes/upstream/dup-nomatch HEAD
    _branch_included dup-nomatch
    set -l result $status
    _cleanup_test_repo
    # Should NOT be included (result should be non-zero)
    test $result -ne 0
) $status -eq 0

@test "switch_branch: branch on 3 remotes with defaultRemote matching one is included" (
    _setup_test_repo
    git config checkout.defaultRemote fork
    git update-ref refs/remotes/origin/triple-default HEAD
    git update-ref refs/remotes/upstream/triple-default HEAD
    git update-ref refs/remotes/fork/triple-default HEAD
    _branch_included triple-default
    set -l result $status
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

# ============================================================
# 4. HEAD exclusion
# ============================================================

@test "switch_branch: origin/HEAD is excluded" (
    _setup_test_repo
    git update-ref refs/remotes/origin/HEAD HEAD
    _branch_included HEAD
    set -l result $status
    _cleanup_test_repo
    # Should NOT be included (result should be non-zero)
    test $result -ne 0
) $status -eq 0

@test "switch_branch: upstream/HEAD is excluded" (
    _setup_test_repo
    git update-ref refs/remotes/upstream/HEAD HEAD
    _branch_included HEAD
    set -l result $status
    _cleanup_test_repo
    # Should NOT be included (result should be non-zero)
    test $result -ne 0
) $status -eq 0

# ============================================================
# 5. Edge cases
# ============================================================

@test "switch_branch: branch name with slash (feature/test) is handled correctly" (
    _setup_test_repo
    git branch feature/test-slash
    _branch_included feature/test-slash
    set -l result $status
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "switch_branch: remote branch with slash is handled correctly" (
    _setup_test_repo
    git update-ref refs/remotes/origin/feature/remote-slash HEAD
    _branch_included feature/remote-slash
    set -l result $status
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "switch_branch: empty repository (only initial commit, no extra branches) returns main/master" (
    _setup_test_repo
    set -l branches (_get_switch_branches)
    _cleanup_test_repo
    # Should have at least one branch (main or master depending on git config)
    test (count $branches) -ge 1
) $status -eq 0

@test "switch_branch: multiple local branches are all included" (
    _setup_test_repo
    git branch local-one
    git branch local-two
    git branch local-three
    _branch_included local-one
    set -l result1 $status
    _branch_included local-two
    set -l result2 $status
    _branch_included local-three
    set -l result3 $status
    _cleanup_test_repo
    test $result1 -eq 0 -a $result2 -eq 0 -a $result3 -eq 0
) $status -eq 0

@test "switch_branch: mix of local, single remote, and duplicate remote branches - correct filtering" (
    _setup_test_repo
    git config --unset checkout.defaultRemote 2>/dev/null; or true
    # Local branch
    git branch local-mix
    # Single remote branch (should be included)
    git update-ref refs/remotes/origin/single-remote HEAD
    # Duplicate remote branch (should be excluded without defaultRemote)
    git update-ref refs/remotes/origin/dup-mix HEAD
    git update-ref refs/remotes/upstream/dup-mix HEAD

    _branch_included local-mix
    set -l local_result $status
    _branch_included single-remote
    set -l single_result $status
    _branch_included dup-mix
    set -l dup_result $status
    _cleanup_test_repo
    # local and single-remote should be included (status 0), dup-mix should NOT (status non-zero)
    test $local_result -eq 0 -a $single_result -eq 0 -a $dup_result -ne 0
) $status -eq 0

@test "switch_branch: defaultRemote set to non-existent remote excludes duplicates" (
    _setup_test_repo
    git config checkout.defaultRemote nonexistent
    git update-ref refs/remotes/origin/dup-nonexist HEAD
    git update-ref refs/remotes/upstream/dup-nonexist HEAD
    _branch_included dup-nonexist
    set -l result $status
    _cleanup_test_repo
    # Should NOT be included (result should be non-zero)
    test $result -ne 0
) $status -eq 0

# ============================================================
# 6. Additional edge cases
# ============================================================

@test "switch_branch: branch name with hyphen is handled correctly" (
    _setup_test_repo
    git branch my-hyphen-branch
    _branch_included my-hyphen-branch
    set -l result $status
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "switch_branch: branch name with underscore is handled correctly" (
    _setup_test_repo
    git branch my_underscore_branch
    _branch_included my_underscore_branch
    set -l result $status
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "switch_branch: single remote branch without local counterpart is included" (
    _setup_test_repo
    git update-ref refs/remotes/origin/only-on-origin HEAD
    _branch_included only-on-origin
    set -l result $status
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "switch_branch: local branch shadows single remote branch" (
    _setup_test_repo
    git branch shadow-test
    git update-ref refs/remotes/origin/shadow-test HEAD
    set -l count (_count_branch_occurrences shadow-test)
    _cleanup_test_repo
    # Should appear only once
    test $count -eq 1
) $status -eq 0
