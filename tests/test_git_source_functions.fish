# Test git source functions
#
# Tests the following source functions:
# - __lophius_git_source_status
# - __lophius_git_source_ls_files
# - __lophius_git_source_staged
# - __lophius_git_source_modified
# - __lophius_git_source_log
# - __lophius_git_source_branch
# - __lophius_git_source_remote_branch
# - __lophius_git_source_tag
# - __lophius_git_source_reflog
# - __lophius_git_source_stash
# - __lophius_git_source_remote
# - __lophius_git_source_author
#
# Note: __lophius_git_source_switch_branch is tested in test_git_switch_branch_filter.fish

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

# ANSI escape pattern for stripping colors
# Use directly with: | string replace -ra $ANSI_ESCAPE ''
set -g ANSI_ESCAPE '\x1b\[[0-9;]*m'

# ============================================================
# 1. source_status tests
# ============================================================

@test "source_status: returns output when there are modified files" (
    _setup_test_repo
    echo "content" > testfile.txt
    git add testfile.txt
    git commit -m "add testfile" --quiet
    echo "modified" > testfile.txt
    set -l output (__lophius_git_source_status)
    _cleanup_test_repo
    test -n "$output"
) $status -eq 0

@test "source_status: returns empty when working directory is clean" (
    _setup_test_repo
    set -l output (__lophius_git_source_status)
    _cleanup_test_repo
    test -z "$output"
) $status -eq 0

@test "source_status: shows staged files" (
    _setup_test_repo
    echo "content" > newfile.txt
    git add newfile.txt
    set -l output (__lophius_git_source_status | string replace -ra $ANSI_ESCAPE '')
    set -l result (echo "$output" | string match -q '*newfile.txt*'; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

# ============================================================
# 2. source_ls_files tests
# ============================================================

@test "source_ls_files: lists tracked files (null-separated)" (
    _setup_test_repo
    echo "content" > tracked.txt
    git add tracked.txt
    git commit -m "add tracked" --quiet
    set -l output (__lophius_git_source_ls_files | string split0)
    set -l result (contains -- tracked.txt $output; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "source_ls_files: returns empty in repo without tracked files" (
    _setup_test_repo
    # Initial commit is empty, so no files tracked
    set -l output (__lophius_git_source_ls_files)
    _cleanup_test_repo
    test -z "$output"
) $status -eq 0

@test "source_ls_files: lists multiple tracked files" (
    _setup_test_repo
    echo "a" > file_a.txt
    echo "b" > file_b.txt
    git add file_a.txt file_b.txt
    git commit -m "add files" --quiet
    set -l output (__lophius_git_source_ls_files | string split0)
    set -l count (count $output)
    _cleanup_test_repo
    test $count -eq 2
) $status -eq 0

# ============================================================
# 3. source_staged tests
# ============================================================

@test "source_staged: lists staged files when files are staged" (
    _setup_test_repo
    echo "content" > staged.txt
    git add staged.txt
    set -l output (__lophius_git_source_staged | string split0)
    set -l result (contains -- staged.txt $output; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "source_staged: returns empty when nothing staged" (
    _setup_test_repo
    set -l output (__lophius_git_source_staged)
    _cleanup_test_repo
    test -z "$output"
) $status -eq 0

@test "source_staged: shows modified staged file" (
    _setup_test_repo
    echo "content" > existing.txt
    git add existing.txt
    git commit -m "add file" --quiet
    echo "modified" > existing.txt
    git add existing.txt
    set -l output (__lophius_git_source_staged | string split0)
    set -l result (contains -- existing.txt $output; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

# ============================================================
# 4. source_modified tests
# ============================================================

@test "source_modified: lists modified files when files are modified" (
    _setup_test_repo
    echo "content" > modfile.txt
    git add modfile.txt
    git commit -m "add file" --quiet
    echo "changed" > modfile.txt
    set -l output (__lophius_git_source_modified | string split0)
    set -l result (contains -- modfile.txt $output; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "source_modified: returns empty when no modifications" (
    _setup_test_repo
    set -l output (__lophius_git_source_modified)
    _cleanup_test_repo
    test -z "$output"
) $status -eq 0

@test "source_modified: does not include untracked files" (
    _setup_test_repo
    echo "untracked" > untracked.txt
    set -l output (__lophius_git_source_modified)
    _cleanup_test_repo
    test -z "$output"
) $status -eq 0

# ============================================================
# 5. source_log tests
# ============================================================

@test "source_log: returns commit entries with [commit] prefix" (
    _setup_test_repo
    set -l output (__lophius_git_source_log | string replace -ra $ANSI_ESCAPE '')
    set -l result (echo "$output" | string match -q '*commit*'; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "source_log: contains commit message" (
    _setup_test_repo
    git commit --allow-empty -m "test log message" --quiet
    set -l output (__lophius_git_source_log | string replace -ra $ANSI_ESCAPE '')
    set -l result (echo "$output" | string match -q '*test log message*'; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "source_log: shows multiple commits" (
    _setup_test_repo
    git commit --allow-empty -m "second commit" --quiet
    git commit --allow-empty -m "third commit" --quiet
    set -l line_count (__lophius_git_source_log | string replace -ra $ANSI_ESCAPE '' | wc -l | string trim)
    _cleanup_test_repo
    test $line_count -ge 3
) $status -eq 0

# ============================================================
# 6. source_branch tests
# ============================================================

@test "source_branch: lists local branches with [branch] prefix" (
    _setup_test_repo
    git branch test-branch
    set -l output (__lophius_git_source_branch | string replace -ra $ANSI_ESCAPE '')
    set -l result (echo "$output" | string match -q '*test-branch*'; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "source_branch: lists remote branches" (
    _setup_test_repo
    git update-ref refs/remotes/origin/remote-branch HEAD
    set -l output (__lophius_git_source_branch | string replace -ra $ANSI_ESCAPE '')
    set -l result (echo "$output" | string match -q '*origin/remote-branch*'; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "source_branch: lists both local and remote branches" (
    _setup_test_repo
    git branch local-branch
    git update-ref refs/remotes/origin/remote-branch HEAD
    set -l output (__lophius_git_source_branch | string replace -ra $ANSI_ESCAPE '')
    set -l has_local (echo "$output" | string match -q '*local-branch*'; echo $status)
    set -l has_remote (echo "$output" | string match -q '*origin/remote-branch*'; echo $status)
    _cleanup_test_repo
    test $has_local -eq 0 -a $has_remote -eq 0
) $status -eq 0

# ============================================================
# 7. source_remote_branch tests
# ============================================================

@test "source_remote_branch: lists only remote branches with [remote] prefix" (
    _setup_test_repo
    git update-ref refs/remotes/origin/feature HEAD
    set -l output (__lophius_git_source_remote_branch | string replace -ra $ANSI_ESCAPE '')
    set -l result (echo "$output" | string match -q '*origin/feature*'; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "source_remote_branch: does not list local branches" (
    _setup_test_repo
    git branch local-only
    set -l output (__lophius_git_source_remote_branch | string replace -ra $ANSI_ESCAPE '')
    set -l match_result (echo "$output" | string match -q '*local-only*'; echo $status)
    _cleanup_test_repo
    # match_result should be 1 (no match) for the test to pass
    test $match_result -ne 0
) $status -eq 0

@test "source_remote_branch: returns empty when no remotes" (
    _setup_test_repo
    set -l output (__lophius_git_source_remote_branch)
    _cleanup_test_repo
    test -z "$output"
) $status -eq 0

# ============================================================
# 8. source_tag tests
# ============================================================

@test "source_tag: lists tags with [tag] prefix" (
    _setup_test_repo
    git tag v1.0.0
    set -l output (__lophius_git_source_tag | string replace -ra $ANSI_ESCAPE '')
    set -l result (echo "$output" | string match -q '*v1.0.0*'; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "source_tag: returns empty when no tags" (
    _setup_test_repo
    set -l output (__lophius_git_source_tag)
    _cleanup_test_repo
    test -z "$output"
) $status -eq 0

@test "source_tag: lists multiple tags" (
    _setup_test_repo
    git tag v1.0.0
    git tag v2.0.0
    set -l output (__lophius_git_source_tag | string replace -ra $ANSI_ESCAPE '')
    set -l has_v1 (echo "$output" | string match -q '*v1.0.0*'; echo $status)
    set -l has_v2 (echo "$output" | string match -q '*v2.0.0*'; echo $status)
    _cleanup_test_repo
    test $has_v1 -eq 0 -a $has_v2 -eq 0
) $status -eq 0

# ============================================================
# 9. source_reflog tests
# ============================================================

@test "source_reflog: returns reflog entries with [reflog] prefix" (
    _setup_test_repo
    set -l output (__lophius_git_source_reflog | string replace -ra $ANSI_ESCAPE '')
    set -l result (echo "$output" | string match -q '*reflog*'; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "source_reflog: contains commit hash" (
    _setup_test_repo
    set -l hash (git rev-parse --short HEAD)
    set -l output (__lophius_git_source_reflog | string replace -ra $ANSI_ESCAPE '')
    set -l result (echo "$output" | string match -q "*$hash*"; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "source_reflog: shows multiple entries after commits" (
    _setup_test_repo
    git commit --allow-empty -m "second" --quiet
    git commit --allow-empty -m "third" --quiet
    set -l line_count (__lophius_git_source_reflog | string replace -ra $ANSI_ESCAPE '' | wc -l | string trim)
    _cleanup_test_repo
    test $line_count -ge 3
) $status -eq 0

# ============================================================
# 10. source_stash tests
# ============================================================

@test "source_stash: returns stash entries when stashes exist" (
    _setup_test_repo
    echo "content" > stashfile.txt
    git add stashfile.txt
    git stash push -m "test stash" --quiet
    set -l output (__lophius_git_source_stash | string replace -ra $ANSI_ESCAPE '')
    set -l result (echo "$output" | string match -q '*stash*'; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "source_stash: returns empty when no stashes" (
    _setup_test_repo
    set -l output (__lophius_git_source_stash)
    _cleanup_test_repo
    test -z "$output"
) $status -eq 0

@test "source_stash: shows stash message" (
    _setup_test_repo
    echo "content" > stashfile.txt
    git add stashfile.txt
    git stash push -m "my stash message" --quiet
    set -l output (__lophius_git_source_stash | string replace -ra $ANSI_ESCAPE '')
    set -l result (echo "$output" | string match -q '*my stash message*'; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

# ============================================================
# 11. source_remote tests
# ============================================================

@test "source_remote: lists remotes" (
    _setup_test_repo
    git remote add origin https://example.com/repo.git
    set -l output (__lophius_git_source_remote)
    _cleanup_test_repo
    test "$output" = origin
) $status -eq 0

@test "source_remote: returns empty when no remotes" (
    _setup_test_repo
    set -l output (__lophius_git_source_remote)
    _cleanup_test_repo
    test -z "$output"
) $status -eq 0

@test "source_remote: lists multiple remotes" (
    _setup_test_repo
    git remote add origin https://example.com/repo.git
    git remote add upstream https://example.com/upstream.git
    set -l output (__lophius_git_source_remote)
    set -l has_origin (echo "$output" | string match -q '*origin*'; echo $status)
    set -l has_upstream (echo "$output" | string match -q '*upstream*'; echo $status)
    _cleanup_test_repo
    test $has_origin -eq 0 -a $has_upstream -eq 0
) $status -eq 0

# ============================================================
# 12. source_author tests
# ============================================================

@test "source_author: returns unique authors from log" (
    _setup_test_repo
    set -l output (__lophius_git_source_author)
    _cleanup_test_repo
    test -n "$output"
) $status -eq 0

@test "source_author: format is Name <email>" (
    _setup_test_repo
    set -l output (__lophius_git_source_author)
    # Check format matches "Name <email>" pattern
    set -l result (echo "$output" | string match -q '*<*@*>*'; echo $status)
    _cleanup_test_repo
    test $result -eq 0
) $status -eq 0

@test "source_author: returns unique authors only" (
    _setup_test_repo
    git commit --allow-empty -m "second" --quiet
    git commit --allow-empty -m "third" --quiet
    set -l count (__lophius_git_source_author | wc -l | string trim)
    _cleanup_test_repo
    # Should have only one unique author
    test $count -eq 1
) $status -eq 0

@test "source_author: shows multiple unique authors" (
    _setup_test_repo
    git commit --allow-empty -m "commit by test user" --quiet
    # Create commit with different author
    GIT_AUTHOR_NAME="Another User" GIT_AUTHOR_EMAIL="another@example.com" \
        git commit --allow-empty -m "commit by another user" --quiet
    set -l count (__lophius_git_source_author | wc -l | string trim)
    _cleanup_test_repo
    test $count -eq 2
) $status -eq 0
