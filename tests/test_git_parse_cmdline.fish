# Test __lophius_git_parse_cmdline

source (status dirname)/../functions/__lophius_rule_git.fish

# ============================================================
# 1. git add
# ============================================================
@test "git add" (__lophius_git_parse_cmdline "git add ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Add Files> ')
@test "git add with options" (__lophius_git_parse_cmdline "git add -v ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Add Files> ')
@test "git add with file" (__lophius_git_parse_cmdline "git add foo.txt ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Add Files> ')

# ============================================================
# 2. git diff files (with --)
# ============================================================
@test "git diff with -- only" (__lophius_git_parse_cmdline "git diff -- ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Diff Files> ')
@test "git diff with options and --" (__lophius_git_parse_cmdline "git diff --staged -- ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Diff Files> ')

# ============================================================
# 3. git diff branch files (with -- and non-option arg before, or --no-index)
# ============================================================
@test "git diff with branch and --" (__lophius_git_parse_cmdline "git diff main -- ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Diff Branch Files> ')
@test "git diff with --no-index" (__lophius_git_parse_cmdline "git diff --no-index ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Diff Branch Files> ')
@test "git diff -- with --no-index" (__lophius_git_parse_cmdline "git diff --no-index -- ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Diff Branch Files> ')
@test "git diff -- with --no-index and file" (__lophius_git_parse_cmdline "git diff --no-index file1 ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Diff Branch Files> ')

# ============================================================
# 4. git diff (basic - branches completion)
# ============================================================
@test "git diff" (__lophius_git_parse_cmdline "git diff ") = (printf '%s\t%s\t%s\t%s\n' branch true ref_full 'Git Diff> ')

# ============================================================
# 4.5. git diff --cached/--merge-base commit
# ============================================================
@test "git diff --cached commit" (__lophius_git_parse_cmdline "git diff --cached ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Diff Commit> ')
@test "git diff --staged commit" (__lophius_git_parse_cmdline "git diff --staged ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Diff Commit> ')
@test "git diff --merge-base commit" (__lophius_git_parse_cmdline "git diff --merge-base ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Diff Commit> ')

# ============================================================
# 5. git commit -c/-C/--fixup/--squash
# ============================================================
@test "git commit -c" (__lophius_git_parse_cmdline "git commit -c ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Commit> ')
@test "git commit -C" (__lophius_git_parse_cmdline "git commit -C ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Commit> ')
@test "git commit --fixup=" (__lophius_git_parse_cmdline "git commit --fixup=") = (printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Commit> ')
@test "git commit --fixup " (__lophius_git_parse_cmdline "git commit --fixup ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Commit> ')
@test "git commit --fixup=amend:" (__lophius_git_parse_cmdline "git commit --fixup=amend:") = (printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Commit> ')
@test "git commit --fixup=reword:" (__lophius_git_parse_cmdline "git commit --fixup=reword:") = (printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Commit> ')
@test "git commit --squash=" (__lophius_git_parse_cmdline "git commit --squash=") = (printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Commit> ')
@test "git commit --squash " (__lophius_git_parse_cmdline "git commit --squash ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Commit> ')
@test "git commit --reuse-message=" (__lophius_git_parse_cmdline "git commit --reuse-message=") = (printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Commit> ')
@test "git commit --reedit-message=" (__lophius_git_parse_cmdline "git commit --reedit-message=") = (printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Commit> ')
@test "git commit -c with options" (__lophius_git_parse_cmdline "git commit -v -c ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Commit> ')

# git commit -c/-C/--fixup/--squash with -- falls through to commit files
@test "git commit -c with -- falls to commit files" (__lophius_git_parse_cmdline "git commit -c -- ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Commit Files> ')

# ============================================================
# 6. git commit files
# ============================================================
@test "git commit with file" (__lophius_git_parse_cmdline "git commit foo.txt ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Commit Files> ')
@test "git commit with options and space" (__lophius_git_parse_cmdline "git commit -v ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Commit Files> ')
@test "git commit with --amend" (__lophius_git_parse_cmdline "git commit --amend ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Commit Files> ')

# git commit files exclusions
@test "git commit -m should not match" (test -z (__lophius_git_parse_cmdline "git commit -m ")) $status -eq 0
@test "git commit -F should not match" (test -z (__lophius_git_parse_cmdline "git commit -F ")) $status -eq 0
@test "git commit --date should not match" (test -z (__lophius_git_parse_cmdline "git commit --date ")) $status -eq 0
@test "git commit --template should not match" (test -z (__lophius_git_parse_cmdline "git commit --template ")) $status -eq 0
@test "git commit --trailer should not match" (test -z (__lophius_git_parse_cmdline "git commit --trailer ")) $status -eq 0

# ============================================================
# 6.5. git commit --author
# ============================================================
@test "git commit --author " (__lophius_git_parse_cmdline "git commit --author ") = (printf '%s\t%s\t%s\t%s\n' author false author 'Git Commit Author> ')
@test "git commit --author=" (__lophius_git_parse_cmdline "git commit --author=") = (printf '%s\t%s\t%s\t%s\n' author false author 'Git Commit Author> ')
@test "git commit -m 'msg' --author " (__lophius_git_parse_cmdline "git commit -m 'msg' --author ") = (printf '%s\t%s\t%s\t%s\n' author false author 'Git Commit Author> ')

# Negative cases: --author with value should NOT trigger author completion
@test "git commit --author=foo should not match" (
  test -z (__lophius_git_parse_cmdline "git commit --author=foo ")
) $status -eq 0

@test "git commit --author foo should not match" (
  test -z (__lophius_git_parse_cmdline "git commit --author foo ")
) $status -eq 0

# Positive case: --amend with --author
@test "git commit --amend --author " (
  __lophius_git_parse_cmdline "git commit --amend --author "
) = (printf '%s\t%s\t%s\t%s\n' author false author 'Git Commit Author> ')

# ============================================================
# 7. git checkout branch files
# ============================================================
@test "git checkout branch files" (__lophius_git_parse_cmdline "git checkout main ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Checkout Branch Files> ')
@test "git checkout branch files with --" (__lophius_git_parse_cmdline "git checkout main -- ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Checkout Branch Files> ')

# git checkout -b/-B/--orphan with new branch name should trigger start-point completion
@test "git checkout -b branch should be start-point" (__lophius_git_parse_cmdline "git checkout -b main ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Checkout Start> ')
@test "git checkout -B branch should be start-point" (__lophius_git_parse_cmdline "git checkout -B main ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Checkout Start> ')
@test "git checkout --orphan branch should be start-point" (__lophius_git_parse_cmdline "git checkout --orphan main ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Checkout Start> ')

# git checkout -b/-B with --track (remote branch completion)
@test "git checkout -b with --track" (__lophius_git_parse_cmdline "git checkout -b foo --track ") = (printf '%s\t%s\t%s\t%s\n' remote_branch false ref_simple 'Git Checkout Track> ')
@test "git checkout -B with --track" (__lophius_git_parse_cmdline "git checkout -B foo --track ") = (printf '%s\t%s\t%s\t%s\n' remote_branch false ref_simple 'Git Checkout Track> ')
@test "git checkout -b with --track=" (__lophius_git_parse_cmdline "git checkout -b foo --track=") = (printf '%s\t%s\t%s\t%s\n' remote_branch false ref_simple 'Git Checkout Track> ')
@test "git checkout -B with --track=" (__lophius_git_parse_cmdline "git checkout -B foo --track=") = (printf '%s\t%s\t%s\t%s\n' remote_branch false ref_simple 'Git Checkout Track> ')
@test "git checkout -b with -t" (__lophius_git_parse_cmdline "git checkout -b foo -t ") = (printf '%s\t%s\t%s\t%s\n' remote_branch false ref_simple 'Git Checkout Track> ')
@test "git checkout -B with -t" (__lophius_git_parse_cmdline "git checkout -B foo -t ") = (printf '%s\t%s\t%s\t%s\n' remote_branch false ref_simple 'Git Checkout Track> ')

# ============================================================
# 8. git checkout (branch completion)
# ============================================================
@test "git checkout" (__lophius_git_parse_cmdline "git checkout ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Checkout> ')

# git checkout exclusions (new branch name position - should not trigger completion)
@test "git checkout -b should not match" (test -z (__lophius_git_parse_cmdline "git checkout -b ")) $status -eq 0
@test "git checkout -B should not match" (test -z (__lophius_git_parse_cmdline "git checkout -B ")) $status -eq 0
@test "git checkout --orphan should not match" (test -z (__lophius_git_parse_cmdline "git checkout --orphan ")) $status -eq 0
@test "git checkout --track should not match" (test -z (__lophius_git_parse_cmdline "git checkout --track ")) $status -eq 0
@test "git checkout --track= should not match" (test -z (__lophius_git_parse_cmdline "git checkout --track=")) $status -eq 0
@test "git checkout -t should not match" (test -z (__lophius_git_parse_cmdline "git checkout -t ")) $status -eq 0
@test "git checkout with -- should not match branch" (__lophius_git_parse_cmdline "git checkout -- ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Checkout Files> ')
@test "git checkout --conflict should not match" (test -z (__lophius_git_parse_cmdline "git checkout --conflict ")) $status -eq 0
@test "git checkout --pathspec-from-file should not match" (test -z (__lophius_git_parse_cmdline "git checkout --pathspec-from-file ")) $status -eq 0

# ============================================================
# 9. git checkout files
# ============================================================
@test "git checkout files with --" (__lophius_git_parse_cmdline "git checkout -- ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Checkout Files> ')

# ============================================================
# 10. git branch rename/copy
# ============================================================
@test "git branch -m" (__lophius_git_parse_cmdline "git branch -m ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_simple 'Git Branch> ')
@test "git branch -M" (__lophius_git_parse_cmdline "git branch -M ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_simple 'Git Branch> ')
@test "git branch -m old" (__lophius_git_parse_cmdline "git branch -m old ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_simple 'Git Branch> ')
@test "git branch -c" (__lophius_git_parse_cmdline "git branch -c ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_simple 'Git Branch> ')
@test "git branch -C" (__lophius_git_parse_cmdline "git branch -C ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_simple 'Git Branch> ')

# ============================================================
# 11. git branch upstream
# ============================================================
@test "git branch -u" (__lophius_git_parse_cmdline "git branch -u ") = (printf '%s\t%s\t%s\t%s\n' remote_branch false ref_simple 'Git Branch Upstream> ')
@test "git branch --set-upstream-to=" (__lophius_git_parse_cmdline "git branch --set-upstream-to=") = (printf '%s\t%s\t%s\t%s\n' remote_branch false ref_simple 'Git Branch Upstream> ')
@test "git branch --set-upstream-to " (__lophius_git_parse_cmdline "git branch --set-upstream-to ") = (printf '%s\t%s\t%s\t%s\n' remote_branch false ref_simple 'Git Branch Upstream> ')

# ============================================================
# 12. git branch edit-description
# ============================================================
@test "git branch --edit-description" (__lophius_git_parse_cmdline "git branch --edit-description ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_simple 'Git Branch> ')

# ============================================================
# 13. git branch filter options
# ============================================================
@test "git branch --merged" (__lophius_git_parse_cmdline "git branch --merged ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Branch Filter> ')
@test "git branch --no-merged" (__lophius_git_parse_cmdline "git branch --no-merged ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Branch Filter> ')
@test "git branch --contains" (__lophius_git_parse_cmdline "git branch --contains ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Branch Filter> ')
@test "git branch --no-contains" (__lophius_git_parse_cmdline "git branch --no-contains ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Branch Filter> ')

# ============================================================
# 14. git branch -d/-D
# ============================================================
@test "git branch -d" (__lophius_git_parse_cmdline "git branch -d ") = (printf '%s\t%s\t%s\t%s\n' branch true ref_simple 'Git Delete Branch> ')
@test "git branch -D" (__lophius_git_parse_cmdline "git branch -D ") = (printf '%s\t%s\t%s\t%s\n' branch true ref_simple 'Git Delete Branch> ')
@test "git branch -d with branch" (__lophius_git_parse_cmdline "git branch -d feature ") = (printf '%s\t%s\t%s\t%s\n' branch true ref_simple 'Git Delete Branch> ')

# ============================================================
# 15. git reset branch files
# ============================================================
@test "git reset with branch" (__lophius_git_parse_cmdline "git reset HEAD ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Reset Branch Files> ')
@test "git reset with branch and file" (__lophius_git_parse_cmdline "git reset HEAD file.txt ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Reset Branch Files> ')

# ============================================================
# 16. git reset (commit completion)
# ============================================================
@test "git reset" (__lophius_git_parse_cmdline "git reset ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Reset> ')
@test "git reset with --soft" (__lophius_git_parse_cmdline "git reset --soft ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Reset> ')
@test "git reset with --hard" (__lophius_git_parse_cmdline "git reset --hard ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Reset> ')
@test "git reset with --mixed" (__lophius_git_parse_cmdline "git reset --mixed ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Reset> ')

# git reset exclusions
@test "git reset --pathspec-from-file should not match" (test -z (__lophius_git_parse_cmdline "git reset --pathspec-from-file ")) $status -eq 0

# ============================================================
# 17. git reset files (fallback with --)
# ============================================================
@test "git reset files with --" (__lophius_git_parse_cmdline "git reset -- ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Reset Files> ')
@test "git reset files with -- and options" (__lophius_git_parse_cmdline "git reset --soft -- ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Reset Files> ')

# ============================================================
# 18. git switch
# ============================================================
@test "git switch" (__lophius_git_parse_cmdline "git switch ") = (printf '%s\t%s\t%s\t%s\n' switch_branch false ref_simple 'Git Switch> ')
@test "git switch with -c" (__lophius_git_parse_cmdline "git switch -c ") = (printf '%s\t%s\t%s\t%s\n' switch_branch false ref_simple 'Git Switch> ')
@test "git switch with --create" (__lophius_git_parse_cmdline "git switch --create ") = (printf '%s\t%s\t%s\t%s\n' switch_branch false ref_simple 'Git Switch> ')

# git switch start-point
@test "git switch -c newbranch" (__lophius_git_parse_cmdline "git switch -c newbranch ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Switch Start> ')
@test "git switch -C newbranch" (__lophius_git_parse_cmdline "git switch -C newbranch ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Switch Start> ')
@test "git switch --create newbranch" (__lophius_git_parse_cmdline "git switch --create newbranch ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Switch Start> ')
@test "git switch --detach" (__lophius_git_parse_cmdline "git switch --detach ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Switch Detach> ')

# ============================================================
# 19. git restore --source
# ============================================================
@test "git restore -s" (__lophius_git_parse_cmdline "git restore -s ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Restore Source> ')
@test "git restore --source=" (__lophius_git_parse_cmdline "git restore --source=") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Restore Source> ')
@test "git restore --source " (__lophius_git_parse_cmdline "git restore --source ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Restore Source> ')

# git restore -s with -- falls through to restore source files
@test "git restore -s with -- falls to restore files" (__lophius_git_parse_cmdline "git restore -s -- ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Restore Files> ')

# ============================================================
# 20. git restore source files
# ============================================================
@test "git restore with source and file" (__lophius_git_parse_cmdline "git restore -s HEAD ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Restore Files> ')
@test "git restore with --source=ref" (__lophius_git_parse_cmdline "git restore --source=HEAD ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Restore Files> ')
@test "git restore with --source ref" (__lophius_git_parse_cmdline "git restore --source HEAD ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Restore Files> ')

# ============================================================
# 20.5 git restore --staged (no source) - staged file completion
# ============================================================
@test "git restore --staged" (__lophius_git_parse_cmdline "git restore --staged ") = (printf '%s\t%s\t%s\t%s\n' staged_file true file 'Git Restore Staged> ')
@test "git restore -S" (__lophius_git_parse_cmdline "git restore -S ") = (printf '%s\t%s\t%s\t%s\n' staged_file true file 'Git Restore Staged> ')
@test "git restore --staged with options" (__lophius_git_parse_cmdline "git restore --staged --quiet ") = (printf '%s\t%s\t%s\t%s\n' staged_file true file 'Git Restore Staged> ')
@test "git restore -S with file" (__lophius_git_parse_cmdline "git restore -S file.txt ") = (printf '%s\t%s\t%s\t%s\n' staged_file true file 'Git Restore Staged> ')

# ============================================================
# 20.6 git restore (no source) - worktree file completion
# ============================================================
@test "git restore" (__lophius_git_parse_cmdline "git restore ") = (printf '%s\t%s\t%s\t%s\n' modified_file true file 'Git Restore> ')
@test "git restore --worktree" (__lophius_git_parse_cmdline "git restore --worktree ") = (printf '%s\t%s\t%s\t%s\n' modified_file true file 'Git Restore> ')
@test "git restore -W" (__lophius_git_parse_cmdline "git restore -W ") = (printf '%s\t%s\t%s\t%s\n' modified_file true file 'Git Restore> ')
@test "git restore --staged --worktree" (__lophius_git_parse_cmdline "git restore --staged --worktree ") = (printf '%s\t%s\t%s\t%s\n' modified_file true file 'Git Restore> ')
@test "git restore -S -W" (__lophius_git_parse_cmdline "git restore -S -W ") = (printf '%s\t%s\t%s\t%s\n' modified_file true file 'Git Restore> ')
@test "git restore -SW" (__lophius_git_parse_cmdline "git restore -SW ") = (printf '%s\t%s\t%s\t%s\n' modified_file true file 'Git Restore> ')
@test "git restore -WS" (__lophius_git_parse_cmdline "git restore -WS ") = (printf '%s\t%s\t%s\t%s\n' modified_file true file 'Git Restore> ')
@test "git restore with file" (__lophius_git_parse_cmdline "git restore file.txt ") = (printf '%s\t%s\t%s\t%s\n' modified_file true file 'Git Restore> ')

# git restore exclusions
@test "git restore --pathspec-from-file should not match" (test -z (__lophius_git_parse_cmdline "git restore --pathspec-from-file ")) $status -eq 0

# ============================================================
# 21. git rebase branch (with branch argument)
# ============================================================
@test "git rebase with branch" (__lophius_git_parse_cmdline "git rebase main ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Rebase Branch> ')
@test "git rebase with --onto and branch" (__lophius_git_parse_cmdline "git rebase --onto main feature ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Rebase Branch> ')

# git rebase branch should not trigger when preceded by these options
@test "git rebase -x arg should not be rebase branch" (__lophius_git_parse_cmdline "git rebase -x cmd ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Rebase> ')
@test "git rebase --exec arg should not be rebase branch" (__lophius_git_parse_cmdline "git rebase --exec cmd ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Rebase> ')

# ============================================================
# 22. git rebase (commit completion)
# ============================================================
@test "git rebase" (__lophius_git_parse_cmdline "git rebase ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Rebase> ')
@test "git rebase with --onto=" (__lophius_git_parse_cmdline "git rebase --onto=") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Rebase> ')
@test "git rebase with --onto " (__lophius_git_parse_cmdline "git rebase --onto ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Rebase> ')
@test "git rebase with -i" (__lophius_git_parse_cmdline "git rebase -i ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Rebase> ')

# git rebase exclusions
@test "git rebase -x should not match" (test -z (__lophius_git_parse_cmdline "git rebase -x ")) $status -eq 0
@test "git rebase -s should not match" (test -z (__lophius_git_parse_cmdline "git rebase -s ")) $status -eq 0
@test "git rebase -X should not match" (test -z (__lophius_git_parse_cmdline "git rebase -X ")) $status -eq 0
@test "git rebase --exec should not match" (test -z (__lophius_git_parse_cmdline "git rebase --exec ")) $status -eq 0
@test "git rebase --strategy should not match" (test -z (__lophius_git_parse_cmdline "git rebase --strategy ")) $status -eq 0
@test "git rebase --strategy-option should not match" (test -z (__lophius_git_parse_cmdline "git rebase --strategy-option ")) $status -eq 0

# ============================================================
# 23. git merge --into-name
# ============================================================
@test "git merge --into-name=" (__lophius_git_parse_cmdline "git merge --into-name=") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Merge Branch> ')
@test "git merge --into-name " (__lophius_git_parse_cmdline "git merge --into-name ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Merge Branch> ')

# ============================================================
# 24. git merge
# ============================================================
@test "git merge" (__lophius_git_parse_cmdline "git merge ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Merge> ')
@test "git merge with --no-ff" (__lophius_git_parse_cmdline "git merge --no-ff ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Merge> ')

# git merge exclusions
@test "git merge -m should not match" (test -z (__lophius_git_parse_cmdline "git merge -m ")) $status -eq 0
@test "git merge -F should not match" (test -z (__lophius_git_parse_cmdline "git merge -F ")) $status -eq 0
@test "git merge -s should not match" (test -z (__lophius_git_parse_cmdline "git merge -s ")) $status -eq 0
@test "git merge -X should not match" (test -z (__lophius_git_parse_cmdline "git merge -X ")) $status -eq 0
@test "git merge --file should not match" (test -z (__lophius_git_parse_cmdline "git merge --file ")) $status -eq 0
@test "git merge --strategy should not match" (test -z (__lophius_git_parse_cmdline "git merge --strategy ")) $status -eq 0
@test "git merge --strategy-option should not match" (test -z (__lophius_git_parse_cmdline "git merge --strategy-option ")) $status -eq 0

# git merge control flow exclusions
@test "git merge --continue should not match" (test -z (__lophius_git_parse_cmdline "git merge --continue ")) $status -eq 0
@test "git merge --abort should not match" (test -z (__lophius_git_parse_cmdline "git merge --abort ")) $status -eq 0
@test "git merge --quit should not match" (test -z (__lophius_git_parse_cmdline "git merge --quit ")) $status -eq 0

# ============================================================
# 25. git stash apply/drop/pop/show
# ============================================================
@test "git stash apply" (__lophius_git_parse_cmdline "git stash apply ") = (printf '%s\t%s\t%s\t%s\n' stash false stash 'Git Stash> ')
@test "git stash drop" (__lophius_git_parse_cmdline "git stash drop ") = (printf '%s\t%s\t%s\t%s\n' stash false stash 'Git Stash> ')
@test "git stash pop" (__lophius_git_parse_cmdline "git stash pop ") = (printf '%s\t%s\t%s\t%s\n' stash false stash 'Git Stash> ')
@test "git stash show" (__lophius_git_parse_cmdline "git stash show ") = (printf '%s\t%s\t%s\t%s\n' stash false stash 'Git Stash> ')
@test "git stash apply with options" (__lophius_git_parse_cmdline "git stash apply --index ") = (printf '%s\t%s\t%s\t%s\n' stash false stash 'Git Stash> ')

# ============================================================
# 26. git stash branch (with branch name and stash reference)
# ============================================================
@test "git stash branch with name" (__lophius_git_parse_cmdline "git stash branch newbranch ") = (printf '%s\t%s\t%s\t%s\n' stash false stash 'Git Stash> ')

# ============================================================
# 27. git stash branch (branch completion)
# ============================================================
@test "git stash branch" (__lophius_git_parse_cmdline "git stash branch ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Stash Branch> ')

# ============================================================
# 28. git stash push files
# ============================================================
@test "git stash push" (__lophius_git_parse_cmdline "git stash push ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Stash Push Files> ')
@test "git stash push with -m" (__lophius_git_parse_cmdline "git stash push -m msg ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Stash Push Files> ')

# ============================================================
# 28.5 git stash save (deprecated)
# ============================================================
@test "git stash save" (__lophius_git_parse_cmdline "git stash save ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Stash Save Files> ')
@test "git stash save with message" (__lophius_git_parse_cmdline "git stash save 'message' ") = (printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Stash Save Files> ')

# ============================================================
# 28.6 git stash store
# ============================================================
@test "git stash store" (__lophius_git_parse_cmdline "git stash store ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Stash Store> ')

# ============================================================
# 29. git log file (with --)
# ============================================================
@test "git log with --" (__lophius_git_parse_cmdline "git log -- ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Log File> ')
@test "git log with branch and --" (__lophius_git_parse_cmdline "git log main -- ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Log File> ')

# ============================================================
# 30. git log (branch completion)
# ============================================================
@test "git log" (__lophius_git_parse_cmdline "git log ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Log> ')
@test "git log with --oneline" (__lophius_git_parse_cmdline "git log --oneline ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Log> ')

# git log exclusions
@test "git log --skip should not match" (test -z (__lophius_git_parse_cmdline "git log --skip ")) $status -eq 0
@test "git log --since should not match" (test -z (__lophius_git_parse_cmdline "git log --since ")) $status -eq 0
@test "git log --after should not match" (test -z (__lophius_git_parse_cmdline "git log --after ")) $status -eq 0
@test "git log --until should not match" (test -z (__lophius_git_parse_cmdline "git log --until ")) $status -eq 0
@test "git log --before should not match" (test -z (__lophius_git_parse_cmdline "git log --before ")) $status -eq 0
@test "git log --committer should not match" (test -z (__lophius_git_parse_cmdline "git log --committer ")) $status -eq 0
@test "git log --date should not match" (test -z (__lophius_git_parse_cmdline "git log --date ")) $status -eq 0
@test "git log --branches should not match" (test -z (__lophius_git_parse_cmdline "git log --branches ")) $status -eq 0
@test "git log --tags should not match" (test -z (__lophius_git_parse_cmdline "git log --tags ")) $status -eq 0
@test "git log --remotes should not match" (test -z (__lophius_git_parse_cmdline "git log --remotes ")) $status -eq 0
@test "git log --glob should not match" (test -z (__lophius_git_parse_cmdline "git log --glob ")) $status -eq 0
@test "git log --exclude should not match" (test -z (__lophius_git_parse_cmdline "git log --exclude ")) $status -eq 0
@test "git log --pretty should not match" (test -z (__lophius_git_parse_cmdline "git log --pretty ")) $status -eq 0
@test "git log --format should not match" (test -z (__lophius_git_parse_cmdline "git log --format ")) $status -eq 0
@test "git log --grep should not match" (test -z (__lophius_git_parse_cmdline "git log --grep ")) $status -eq 0
@test "git log --grep-reflog should not match" (test -z (__lophius_git_parse_cmdline "git log --grep-reflog ")) $status -eq 0
@test "git log --min-parents should not match" (test -z (__lophius_git_parse_cmdline "git log --min-parents ")) $status -eq 0
@test "git log --max-parents should not match" (test -z (__lophius_git_parse_cmdline "git log --max-parents ")) $status -eq 0

# ============================================================
# 30.5 git log --author
# ============================================================
@test "git log --author " (__lophius_git_parse_cmdline "git log --author ") = (printf '%s\t%s\t%s\t%s\n' author false author 'Git Log Author> ')
@test "git log --author=" (__lophius_git_parse_cmdline "git log --author=") = (printf '%s\t%s\t%s\t%s\n' author false author 'Git Log Author> ')
@test "git log --oneline --author " (__lophius_git_parse_cmdline "git log --oneline --author ") = (printf '%s\t%s\t%s\t%s\n' author false author 'Git Log Author> ')

# Negative cases: --author with value should NOT trigger author completion
@test "git log --author=foo should not match" (
  test -z (__lophius_git_parse_cmdline "git log --author=foo ")
) $status -eq 0

@test "git log --author foo should not match" (
  test -z (__lophius_git_parse_cmdline "git log --author foo ")
) $status -eq 0

# ============================================================
# 30.6 git shortlog --author
# ============================================================
@test "git shortlog --author " (__lophius_git_parse_cmdline "git shortlog --author ") = (printf '%s\t%s\t%s\t%s\n' author false author 'Git Shortlog Author> ')
@test "git shortlog --author=" (__lophius_git_parse_cmdline "git shortlog --author=") = (printf '%s\t%s\t%s\t%s\n' author false author 'Git Shortlog Author> ')

# Negative cases
@test "git shortlog --author=foo should not match" (
  test -z (__lophius_git_parse_cmdline "git shortlog --author=foo ")
) $status -eq 0

@test "git shortlog --author foo should not match" (
  test -z (__lophius_git_parse_cmdline "git shortlog --author foo ")
) $status -eq 0

# ============================================================
# 31. git tag list commit
# ============================================================
@test "git tag -l --contains" (__lophius_git_parse_cmdline "git tag -l --contains ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag List Commit> ')
@test "git tag --list --no-contains" (__lophius_git_parse_cmdline "git tag --list --no-contains ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag List Commit> ')
@test "git tag -l --merged" (__lophius_git_parse_cmdline "git tag -l --merged ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag List Commit> ')
@test "git tag --list --no-merged" (__lophius_git_parse_cmdline "git tag --list --no-merged ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag List Commit> ')
@test "git tag -l --points-at" (__lophius_git_parse_cmdline "git tag -l --points-at ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag List Commit> ')
# --contains, --no-contains, --merged, --no-merged implicitly enable list mode
@test "git tag --contains" (__lophius_git_parse_cmdline "git tag --contains ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag List Commit> ')
@test "git tag --no-contains" (__lophius_git_parse_cmdline "git tag --no-contains ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag List Commit> ')
@test "git tag --merged" (__lophius_git_parse_cmdline "git tag --merged ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag List Commit> ')
@test "git tag --no-merged" (__lophius_git_parse_cmdline "git tag --no-merged ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag List Commit> ')
@test "git tag --points-at" (__lophius_git_parse_cmdline "git tag --points-at ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag List Commit> ')

# ============================================================
# 32. git tag delete
# ============================================================
@test "git tag -d" (__lophius_git_parse_cmdline "git tag -d ") = (printf '%s\t%s\t%s\t%s\n' tag true ref_simple 'Git Tag Delete> ')
@test "git tag --delete" (__lophius_git_parse_cmdline "git tag --delete ") = (printf '%s\t%s\t%s\t%s\n' tag true ref_simple 'Git Tag Delete> ')
@test "git tag -d with tag" (__lophius_git_parse_cmdline "git tag -d v1.0 ") = (printf '%s\t%s\t%s\t%s\n' tag true ref_simple 'Git Tag Delete> ')

# ============================================================
# 33. git tag (basic)
# ============================================================
@test "git tag" (__lophius_git_parse_cmdline "git tag ") = (printf '%s\t%s\t%s\t%s\n' tag false ref_simple 'Git Tag> ')
@test "git tag with -a" (__lophius_git_parse_cmdline "git tag -a ") = (printf '%s\t%s\t%s\t%s\n' tag false ref_simple 'Git Tag> ')

# git tag exclusions
@test "git tag -u should not match" (test -z (__lophius_git_parse_cmdline "git tag -u ")) $status -eq 0
@test "git tag -m should not match" (test -z (__lophius_git_parse_cmdline "git tag -m ")) $status -eq 0
@test "git tag -F should not match" (test -z (__lophius_git_parse_cmdline "git tag -F ")) $status -eq 0
@test "git tag --local-user should not match" (test -z (__lophius_git_parse_cmdline "git tag --local-user ")) $status -eq 0
@test "git tag --format should not match" (test -z (__lophius_git_parse_cmdline "git tag --format ")) $status -eq 0

# git tag verify
@test "git tag -v" (__lophius_git_parse_cmdline "git tag -v ") = (printf '%s\t%s\t%s\t%s\n' tag false ref_simple 'Git Tag Verify> ')

# git tag create with commit
@test "git tag with tagname" (__lophius_git_parse_cmdline "git tag v1.0 ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag Commit> ')
@test "git tag -a with tagname" (__lophius_git_parse_cmdline "git tag -a v1.0 ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag Commit> ')
@test "git tag -s with tagname" (__lophius_git_parse_cmdline "git tag -s v1.0 ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag Commit> ')

# ============================================================
# 34. git mv files
# ============================================================
@test "git mv" (__lophius_git_parse_cmdline "git mv ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Mv Files> ')
@test "git mv with file" (__lophius_git_parse_cmdline "git mv file.txt ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Mv Files> ')

# ============================================================
# 35. git rm files
# ============================================================
@test "git rm" (__lophius_git_parse_cmdline "git rm ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Rm Files> ')
@test "git rm with --cached" (__lophius_git_parse_cmdline "git rm --cached ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Rm Files> ')

# ============================================================
# 36. git show
# ============================================================
@test "git show" (__lophius_git_parse_cmdline "git show ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Show> ')
@test "git show with --stat" (__lophius_git_parse_cmdline "git show --stat ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Show> ')

# git show exclusions
@test "git show --pretty should not match" (test -z (__lophius_git_parse_cmdline "git show --pretty ")) $status -eq 0
@test "git show --format should not match" (test -z (__lophius_git_parse_cmdline "git show --format ")) $status -eq 0

# ============================================================
# 37. git revert
# ============================================================
@test "git revert" (__lophius_git_parse_cmdline "git revert ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_simple 'Git Revert> ')
@test "git revert with -n" (__lophius_git_parse_cmdline "git revert -n ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_simple 'Git Revert> ')
@test "git revert with --no-commit" (__lophius_git_parse_cmdline "git revert --no-commit ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_simple 'Git Revert> ')

# git revert control flow exclusions
@test "git revert --continue should not match" (test -z (__lophius_git_parse_cmdline "git revert --continue ")) $status -eq 0
@test "git revert --skip should not match" (test -z (__lophius_git_parse_cmdline "git revert --skip ")) $status -eq 0
@test "git revert --abort should not match" (test -z (__lophius_git_parse_cmdline "git revert --abort ")) $status -eq 0
@test "git revert --quit should not match" (test -z (__lophius_git_parse_cmdline "git revert --quit ")) $status -eq 0

# ============================================================
# 38. git cherry-pick
# ============================================================
@test "git cherry-pick" (__lophius_git_parse_cmdline "git cherry-pick ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Cherry-pick> ')
@test "git cherry-pick with -n" (__lophius_git_parse_cmdline "git cherry-pick -n ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Cherry-pick> ')
@test "git cherry-pick with commit" (__lophius_git_parse_cmdline "git cherry-pick abc123 ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Cherry-pick> ')

# git cherry-pick exclusions (control flow options)
@test "git cherry-pick --continue should not match" (test -z (__lophius_git_parse_cmdline "git cherry-pick --continue ")) $status -eq 0
@test "git cherry-pick --abort should not match" (test -z (__lophius_git_parse_cmdline "git cherry-pick --abort ")) $status -eq 0
@test "git cherry-pick --skip should not match" (test -z (__lophius_git_parse_cmdline "git cherry-pick --skip ")) $status -eq 0
@test "git cherry-pick --quit should not match" (test -z (__lophius_git_parse_cmdline "git cherry-pick --quit ")) $status -eq 0

# ============================================================
# 39. git blame
# ============================================================
@test "git blame" (__lophius_git_parse_cmdline "git blame ") = (printf '%s\t%s\t%s\t%s\n' ls_file false file 'Git Blame> ')
@test "git blame with -L" (__lophius_git_parse_cmdline "git blame -L 1,10 ") = (printf '%s\t%s\t%s\t%s\n' ls_file false file 'Git Blame> ')
@test "git blame with rev" (__lophius_git_parse_cmdline "git blame HEAD ") = (printf '%s\t%s\t%s\t%s\n' ls_file false file 'Git Blame> ')
@test "git blame with --" (__lophius_git_parse_cmdline "git blame -- ") = (printf '%s\t%s\t%s\t%s\n' ls_file false file 'Git Blame> ')

# ============================================================
# 40. git worktree
# ============================================================
@test "git worktree add with path" (__lophius_git_parse_cmdline "git worktree add ../hotfix ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_simple 'Git Worktree> ')
@test "git worktree add -b with path" (__lophius_git_parse_cmdline "git worktree add -b feature ../feature ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_simple 'Git Worktree> ')

# git worktree subcommands without completion
@test "git worktree list should not match" (test -z (__lophius_git_parse_cmdline "git worktree list ")) $status -eq 0
@test "git worktree prune should not match" (test -z (__lophius_git_parse_cmdline "git worktree prune ")) $status -eq 0

# ============================================================
# 41. git format-patch
# ============================================================
@test "git format-patch" (__lophius_git_parse_cmdline "git format-patch ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Format-patch> ')
@test "git format-patch with -o" (__lophius_git_parse_cmdline "git format-patch -o patches ") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Format-patch> ')

# git format-patch exclusions
@test "git format-patch --in-reply-to should not match" (test -z (__lophius_git_parse_cmdline "git format-patch --in-reply-to ")) $status -eq 0
@test "git format-patch --to should not match" (test -z (__lophius_git_parse_cmdline "git format-patch --to ")) $status -eq 0
@test "git format-patch --cc should not match" (test -z (__lophius_git_parse_cmdline "git format-patch --cc ")) $status -eq 0

# git format-patch --interdiff/--range-diff
@test "git format-patch --interdiff=" (__lophius_git_parse_cmdline "git format-patch --interdiff=") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Format-patch Diff> ')
@test "git format-patch --range-diff=" (__lophius_git_parse_cmdline "git format-patch --range-diff=") = (printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Format-patch Diff> ')

# ============================================================
# 42. git describe
# ============================================================
@test "git describe" (__lophius_git_parse_cmdline "git describe ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Describe> ')
@test "git describe with --tags" (__lophius_git_parse_cmdline "git describe --tags ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Describe> ')
@test "git describe with --all" (__lophius_git_parse_cmdline "git describe --all ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Describe> ')

# ============================================================
# 43. git push
# ============================================================
@test "git push" (__lophius_git_parse_cmdline "git push ") = (printf '%s\t%s\t%s\t%s\n' remote false file 'Git Push Remote> ')
@test "git push with options" (__lophius_git_parse_cmdline "git push -f ") = (printf '%s\t%s\t%s\t%s\n' remote false file 'Git Push Remote> ')
@test "git push origin" (__lophius_git_parse_cmdline "git push origin ") = (printf '%s\t%s\t%s\t%s\n' branch true ref_simple 'Git Push Branch> ')
@test "git push origin main" (__lophius_git_parse_cmdline "git push origin main ") = (printf '%s\t%s\t%s\t%s\n' branch true ref_simple 'Git Push Branch> ')

# git push exclusions
@test "git push --repo should not match" (test -z (__lophius_git_parse_cmdline "git push --repo ")) $status -eq 0
@test "git push -o should not match" (test -z (__lophius_git_parse_cmdline "git push -o ")) $status -eq 0

# ============================================================
# 44. git pull
# ============================================================
@test "git pull" (__lophius_git_parse_cmdline "git pull ") = (printf '%s\t%s\t%s\t%s\n' remote false file 'Git Pull Remote> ')
@test "git pull with options" (__lophius_git_parse_cmdline "git pull --rebase ") = (printf '%s\t%s\t%s\t%s\n' remote false file 'Git Pull Remote> ')
@test "git pull origin" (__lophius_git_parse_cmdline "git pull origin ") = (printf '%s\t%s\t%s\t%s\n' branch false ref_simple 'Git Pull Branch> ')

# ============================================================
# 45. git fetch
# ============================================================
@test "git fetch" (__lophius_git_parse_cmdline "git fetch ") = (printf '%s\t%s\t%s\t%s\n' remote false file 'Git Fetch Remote> ')
@test "git fetch with options" (__lophius_git_parse_cmdline "git fetch --prune ") = (printf '%s\t%s\t%s\t%s\n' remote false file 'Git Fetch Remote> ')
@test "git fetch origin" (__lophius_git_parse_cmdline "git fetch origin ") = (printf '%s\t%s\t%s\t%s\n' branch true ref_simple 'Git Fetch Branch> ')
@test "git fetch origin main" (__lophius_git_parse_cmdline "git fetch origin main ") = (printf '%s\t%s\t%s\t%s\n' branch true ref_simple 'Git Fetch Branch> ')

# git fetch exclusions
@test "git fetch --upload-pack should not match" (test -z (__lophius_git_parse_cmdline "git fetch --upload-pack ")) $status -eq 0
@test "git fetch --all should not match" (test -z (__lophius_git_parse_cmdline "git fetch --all ")) $status -eq 0

# ============================================================
# 46. git bisect
# ============================================================
@test "git bisect start" (__lophius_git_parse_cmdline "git bisect start ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Bisect> ')
@test "git bisect start with bad" (__lophius_git_parse_cmdline "git bisect start HEAD ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Bisect> ')
@test "git bisect bad" (__lophius_git_parse_cmdline "git bisect bad ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Bisect> ')
@test "git bisect good" (__lophius_git_parse_cmdline "git bisect good ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Bisect> ')
@test "git bisect good with commit" (__lophius_git_parse_cmdline "git bisect good v1.0 ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Bisect> ')
@test "git bisect new" (__lophius_git_parse_cmdline "git bisect new ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Bisect> ')
@test "git bisect old" (__lophius_git_parse_cmdline "git bisect old ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Bisect> ')
@test "git bisect skip" (__lophius_git_parse_cmdline "git bisect skip ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Bisect> ')
@test "git bisect reset" (__lophius_git_parse_cmdline "git bisect reset ") = (printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Bisect> ')

# git bisect subcommands without completion
@test "git bisect next should not match" (test -z (__lophius_git_parse_cmdline "git bisect next ")) $status -eq 0
@test "git bisect log should not match" (test -z (__lophius_git_parse_cmdline "git bisect log ")) $status -eq 0
@test "git bisect run should not match" (test -z (__lophius_git_parse_cmdline "git bisect run ")) $status -eq 0
@test "git bisect replay should not match" (test -z (__lophius_git_parse_cmdline "git bisect replay ")) $status -eq 0

# git bisect start with -- (pathspec)
@test "git bisect start with --" (__lophius_git_parse_cmdline "git bisect start HEAD~10 HEAD -- ") = (printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Bisect Files> ')

# ============================================================
# No match cases
# ============================================================
@test "unknown command has no output" (test -z (__lophius_git_parse_cmdline "ls ")) $status -eq 0
@test "git without space has no output" (test -z (__lophius_git_parse_cmdline "git")) $status -eq 0
@test "git status has no output" (test -z (__lophius_git_parse_cmdline "git status ")) $status -eq 0
@test "git clone has no output" (test -z (__lophius_git_parse_cmdline "git clone ")) $status -eq 0
