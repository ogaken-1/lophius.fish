# __lophius_git.fish - Git Completion rules
# See: ../conf.d/lophius.fish ./lophius.fish
#
# Git completion patterns ported from zeno.zsh
# https://github.com/yuki-yano/zeno.zsh
#
# MIT License
# Copyright (c) 2021 Yuki Yano

# === Transformers ===
# fzfでの選択結果をcommandline引数形式に変換
function __lophius_git_status_to_arg
  cat | string sub -s 4
end

function __lophius_git_ref_to_arg
  cat | string split \t | head -1 | awk '{ print $2 }'
end

function __lophius_git_stash_to_arg
  cat | string split \t | head -1 | awk '{ print $1 }'
end

# === Parser ===
# Parse commandline and return completion metadata
# Output format: source_type\tmulti\tbind_type\tprompt
# source_type: branch, commit, tag, stash, status_file, ls_file (always singular)
# multi: true or false
# bind_type: ref_full, ref_simple, file, stash
# Outputs nothing if no match found
function __lophius_git_parse_cmdline
  set -l cmd $argv[1]

  # git add
  if string match -rq '^git add(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Add Files> '

  # git diff --cached/--merge-base commit
  else if string match -rq '^git diff(?: .*)? (?:--cached|--staged|--merge-base) $' -- $cmd
    and not string match -rq ' -- ' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Diff Commit> '

  # git diff files (with --)
  else if string match -rq '^git diff(?=.* -- ) .* $' -- $cmd
    and not string match -rq '^git diff.* [^-].* -- ' -- $cmd
    and not string match -rq ' --no-index ' -- $cmd
    printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Diff Files> '

  # git diff branch files
  else if string match -rq '^git diff(?=.* -- ) .* $' -- $cmd
    or string match -rq '^git diff(?=.* --no-index ) .* $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Diff Branch Files> '

  # git diff
  else if string match -rq '^git diff(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch true ref_full 'Git Diff> '

  # git commit -c/-C/--fixup/--squash
  else if string match -rq '^git commit(?: .*)? -[cC] $' -- $cmd
    or string match -rq '^git commit(?: .*)? --fixup[= ](?:amend:|reword:)?$' -- $cmd
    or string match -rq '^git commit(?: .*)? --(?:(?:reuse|reedit)-message|squash)[= ]$' -- $cmd
    and not string match -rq ' -- ' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Commit> '

  # git commit --author
  else if string match -rq '^git commit(?: .*)? --author[= ]$' -- $cmd
    printf '%s\t%s\t%s\t%s\n' author false author 'Git Commit Author> '

  # git commit files
  else if string match -rq '^git commit(?: .*) $' -- $cmd
    and not string match -rq ' -[mF] $' -- $cmd
    and not string match -rq ' --(?:author|date|template|trailer) $' -- $cmd
    and not string match -rq ' --author[= ][^ ]+ $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Commit Files> '

  # git checkout -b/-B/--orphan with new branch name (start-point completion)
  else if string match -rq '^git checkout (?:-[bB]|--orphan) [^ ]+ $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Checkout Start> '

  # git checkout -b/-B with --track (remote branch completion)
  else if string match -rq '^git checkout -[bB] [^ ]+ (?:--track[= ]?|-t )$' -- $cmd
    printf '%s\t%s\t%s\t%s\n' remote_branch false ref_simple 'Git Checkout Track> '

  # git checkout branch files
  else if string match -rq '^git checkout(?=.*(?<! (?:-[bBt]|--orphan|--track|--conflict|--pathspec-from-file)) [^-]) .* $' -- $cmd
    and not string match -rq ' --(?:conflict|pathspec-from-file) $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Checkout Branch Files> '

  # git checkout
  else if string match -rq '^git checkout(?: .*)? $' -- $cmd
    and not string match -rq ' -- ' -- $cmd
    and not string match -rq ' --(?:conflict|pathspec-from-file) $' -- $cmd
    and not string match -rq ' (?:-[bBt]|--orphan|--track[= ]?) $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Checkout> '

  # git checkout files
  else if string match -rq '^git checkout(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:conflict|pathspec-from-file) $' -- $cmd
    and not string match -rq ' (?:-[bBt]|--orphan|--track[= ]?) $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Checkout Files> '

  # git branch --set-upstream-to/-u
  else if string match -rq '^git branch(?: .*)? (?:--set-upstream-to[= ]|-u )$' -- $cmd
    printf '%s\t%s\t%s\t%s\n' remote_branch false ref_simple 'Git Branch Upstream> '

  # git branch -m/-M/-c/-C (rename/copy)
  else if string match -rq '^git branch (?:-[mMcC])(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch false ref_simple 'Git Branch> '

  # git branch --edit-description
  else if string match -rq '^git branch(?: .*)? --edit-description(?: )?$' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch false ref_simple 'Git Branch> '

  # git branch --merged/--no-merged/--contains/--no-contains
  else if string match -rq '^git branch(?: .*)? --(?:no-)?(?:merged|contains) $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Branch Filter> '

  # git branch -d/-D
  else if string match -rq '^git branch (?:-d|-D)(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:conflict|pathspec-from-file) $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch true ref_simple 'Git Delete Branch> '

  # git reset branch files
  else if string match -rq '^git reset(?=.*(?<! --pathspec-from-file) [^-]) .* $' -- $cmd
    and not string match -rq ' --pathspec-from-file $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Reset Branch Files> '

  # git reset
  else if string match -rq '^git reset(?: .*)? $' -- $cmd
    and not string match -rq ' -- ' -- $cmd
    and not string match -rq ' --pathspec-from-file $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Reset> '

  # git reset files (fallback)
  else if string match -rq '^git reset(?: .*)? $' -- $cmd
    and not string match -rq ' --pathspec-from-file $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Reset Files> '

  # git switch -c/-C/--create with new branch name (start-point completion)
  else if string match -rq '^git switch (?:-[cC]|--create) [^ ]+ $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Switch Start> '

  # git switch --detach
  else if string match -rq '^git switch(?: .*)? --detach(?: )?$' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Switch Detach> '

  # git switch
  else if string match -rq '^git switch(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' switch_branch false ref_simple 'Git Switch> '

  # git restore --source
  else if string match -rq '^git restore(?: .*)? (?:-s |--source[= ])$' -- $cmd
    and not string match -rq ' -- ' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Restore Source> '

  # git restore source files
  else if string match -rq '^git restore(?=.* (?:-s |--source[= ])) .* $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Restore Files> '

  # git restore --staged --worktree (both) - modified file completion
  else if string match -rq '^git restore .* $' -- $cmd
    and string match -rq ' (?:--staged|-[SW]*S[SW]*)' -- $cmd
    and string match -rq ' (?:--worktree|-[SW]*W[SW]*)' -- $cmd
    and not string match -rq ' (?:-s |--source[= ])' -- $cmd
    and not string match -rq ' --pathspec-from-file ' -- $cmd
    printf '%s\t%s\t%s\t%s\n' modified_file true file 'Git Restore> '

  # git restore --staged (no source) - staged file completion
  else if string match -rq '^git restore .* $' -- $cmd
    and string match -rq ' (?:--staged|-[SW]*S[SW]*)' -- $cmd
    and not string match -rq ' (?:-s |--source[= ])' -- $cmd
    and not string match -rq ' (?:--worktree|-[SW]*W[SW]*)' -- $cmd
    and not string match -rq ' --pathspec-from-file ' -- $cmd
    printf '%s\t%s\t%s\t%s\n' staged_file true file 'Git Restore Staged> '

  # git restore (no source) - modified file completion
  else if string match -rq '^git restore(?: .*)? $' -- $cmd
    and not string match -rq ' (?:-s |--source[= ])' -- $cmd
    and not string match -rq ' --pathspec-from-file ' -- $cmd
    printf '%s\t%s\t%s\t%s\n' modified_file true file 'Git Restore> '

  # git rebase branch
  else if string match -rq '^git rebase(?=.*(?<! (?:-[xsX]|--exec|--strategy(?:-options)?|--onto)) [^-]) .* $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Rebase Branch> '

  # git rebase
  else if string match -rq '^git rebase(?: .*)? (?:--onto[= ])?$' -- $cmd
    and not string match -rq ' -[xsX] $' -- $cmd
    and not string match -rq ' --(?:exec|strategy(?:-option)?) $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Rebase> '

  # git merge --into-name
  else if string match -rq '^git merge(?: .*)? --into-name[= ]$' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Merge Branch> '

  # git merge
  else if string match -rq '^git merge(?: .*)? $' -- $cmd
    and not string match -rq ' -[mFsX] $' -- $cmd
    and not string match -rq ' --(?:file|strategy(?:-option)?) $' -- $cmd
    and not string match -rq ' --(?:continue|abort|quit)' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Merge> '

  # git stash apply/drop/pop/show
  else if string match -rq '^git stash (?:apply|drop|pop|show)(?: .*)? $' -- $cmd
    or string match -rq '^git stash branch(?=.* [^-]) .* $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' stash false stash 'Git Stash> '

  # git stash branch
  else if string match -rq '^git stash branch(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Stash Branch> '

  # git stash push files
  else if string match -rq '^git stash push(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Stash Push Files> '

  # git stash save files (deprecated but still used)
  else if string match -rq '^git stash save(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' status_file true file 'Git Stash Save Files> '

  # git stash store
  else if string match -rq '^git stash store(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit false ref_simple 'Git Stash Store> '

  # git log --author
  else if string match -rq '^git log(?: .*)? --author[= ]$' -- $cmd
    printf '%s\t%s\t%s\t%s\n' author false author 'Git Log Author> '

  # git shortlog --author
  else if string match -rq '^git shortlog(?: .*)? --author[= ]$' -- $cmd
    printf '%s\t%s\t%s\t%s\n' author false author 'Git Shortlog Author> '

  # git log file
  else if string match -rq '^git log(?=.* -- ) .* $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Log File> '

  # git log
  else if string match -rq '^git log(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:skip|since|after|until|before|author|committer|date) $' -- $cmd
    and not string match -rq ' --(?:branches|tags|remotes|glob|exclude|pretty|format) $' -- $cmd
    and not string match -rq ' --grep(?:-reflog)? $' -- $cmd
    and not string match -rq ' --(?:min|max)-parents $' -- $cmd
    and not string match -rq ' --author[= ][^ ]+ $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch false ref_full 'Git Log> '

  # git tag list commit
  # --contains, --no-contains, --merged, --no-merged, --points-at implicitly enable list mode
  else if string match -rq '^git tag(?: .*)? --(?:(?:no-)?(?:contains|merged)|points-at) $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag List Commit> '

  # git tag verify
  else if string match -rq '^git tag(?: .*)? -v $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' tag false ref_simple 'Git Tag Verify> '

  # git tag delete
  else if string match -rq '^git tag(?=.* (?:-d|--delete) )(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' tag true ref_simple 'Git Tag Delete> '

  # git tag create with commit (second positional argument)
  else if string match -rq '^git tag(?=.* [^-])(?: .*)? [^-][^ ]* $' -- $cmd
    and not string match -rq '^git tag(?=.* (?:-l|--list|-d|--delete|-v) )' -- $cmd
    and not string match -rq ' -[umF] $' -- $cmd
    and not string match -rq ' --(?:local-user|format) $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Tag Commit> '

  # git tag
  else if string match -rq '^git tag(?: .*)? $' -- $cmd
    and not string match -rq ' -[umF] $' -- $cmd
    and not string match -rq ' --(?:local-user|format) $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' tag false ref_simple 'Git Tag> '

  # git mv files
  else if string match -rq '^git mv(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Mv Files> '

  # git rm files
  else if string match -rq '^git rm(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Rm Files> '

  # git show
  else if string match -rq '^git show(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:pretty|format) $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Show> '

  # git revert
  else if string match -rq '^git revert(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:continue|skip|abort|quit)' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit true ref_simple 'Git Revert> '

  # git cherry-pick
  else if string match -rq '^git cherry-pick(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:continue|abort|skip|quit)' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Cherry-pick> '

  # git blame
  else if string match -rq '^git blame(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' ls_file false file 'Git Blame> '

  # git worktree add
  else if string match -rq '^git worktree add(?=.* [^-]) .* $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch false ref_simple 'Git Worktree> '

  # git format-patch --interdiff/--range-diff
  else if string match -rq '^git format-patch(?: .*)? --(?:interdiff|range-diff)[= ]$' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Format-patch Diff> '

  # git format-patch
  else if string match -rq '^git format-patch(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:in-reply-to|to|cc) $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit false ref_full 'Git Format-patch> '

  # git describe
  else if string match -rq '^git describe(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Describe> '

  # git push remote
  else if string match -rq '^git push(?: .*)? $' -- $cmd
    and not string match -rq '^git push(?=.* [^-]) .* ' -- $cmd
    and not string match -rq ' --(?:repo|receive-pack|push-option|signed) $' -- $cmd
    and not string match -rq ' -o $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' remote false file 'Git Push Remote> '

  # git push branch (after remote)
  else if string match -rq '^git push(?=.* [^-]) .* $' -- $cmd
    and not string match -rq ' --(?:repo|receive-pack|push-option|signed) $' -- $cmd
    and not string match -rq ' -o $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch true ref_simple 'Git Push Branch> '

  # git pull remote
  else if string match -rq '^git pull(?: .*)? $' -- $cmd
    and not string match -rq '^git pull(?=.* [^-]) .* ' -- $cmd
    printf '%s\t%s\t%s\t%s\n' remote false file 'Git Pull Remote> '

  # git pull branch (after remote)
  else if string match -rq '^git pull(?=.* [^-]) .* $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch false ref_simple 'Git Pull Branch> '

  # git fetch remote
  else if string match -rq '^git fetch(?: .*)? $' -- $cmd
    and not string match -rq '^git fetch(?=.* [^-]) .* ' -- $cmd
    and not string match -rq ' --(?:upload-pack|refmap|recurse-submodules|submodule-prefix|negotiation-tip|filter) $' -- $cmd
    and not string match -rq ' --all' -- $cmd
    and not string match -rq ' -o $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' remote false file 'Git Fetch Remote> '

  # git fetch branch (after remote)
  else if string match -rq '^git fetch(?=.* [^-]) .* $' -- $cmd
    and not string match -rq ' --(?:upload-pack|refmap|recurse-submodules|submodule-prefix|negotiation-tip|filter) $' -- $cmd
    and not string match -rq ' --all' -- $cmd
    and not string match -rq ' -o $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' branch true ref_simple 'Git Fetch Branch> '

  # git bisect start with -- (pathspec)
  else if string match -rq '^git bisect start(?=.* -- ) .* $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' ls_file true file 'Git Bisect Files> '

  # git bisect (start/bad/good/new/old/skip/reset)
  else if string match -rq '^git bisect (?:start|bad|good|new|old|skip|reset)(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' commit true ref_full 'Git Bisect> '
  end
end

# === Config Builder ===
# Build configuration based on completion metadata
# Arguments: source_type multi bind_type prompt
# Output format (null-separated): source\0transformer\0opt1\0opt2\0...
function __lophius_git_build_config
  set -l source_type $argv[1]
  set -l multi $argv[2]
  set -l bind_type $argv[3]
  set -l prompt $argv[4]

  set -l source ''
  set -l opts
  set -l transformer ''

  # Set source and transformer based on source_type
  switch $source_type
    case status_file
      set source __lophius_git_source_status
      set -a opts $LOPHIUS_GIT_PRESET_STATUS
      set transformer __lophius_git_status_to_arg

    case ls_file
      set source __lophius_git_source_ls_files
      set -a opts $LOPHIUS_GIT_PRESET_LS_FILES

    case staged_file
      set source __lophius_git_source_staged
      set -a opts $LOPHIUS_GIT_PRESET_STAGED

    case modified_file
      set source __lophius_git_source_modified
      set -a opts $LOPHIUS_GIT_PRESET_MODIFIED

    case branch
      set source __lophius_git_source_branch
      set transformer __lophius_git_ref_to_arg

    case remote_branch
      set source __lophius_git_source_remote_branch
      set transformer __lophius_git_ref_to_arg
      set -a opts $LOPHIUS_GIT_PRESET_REF_NO_HEADER

    case switch_branch
      set source __lophius_git_source_switch_branch
      set transformer __lophius_git_ref_to_arg
      set -a opts $LOPHIUS_GIT_PRESET_REF_NO_HEADER

    case commit
      set source __lophius_git_source_log
      set transformer __lophius_git_ref_to_arg

    case tag
      set source __lophius_git_source_tag
      set transformer __lophius_git_ref_to_arg

    case stash
      set source __lophius_git_source_stash
      set -a opts $LOPHIUS_GIT_PRESET_STASH
      set transformer __lophius_git_stash_to_arg

    case remote
      set source __lophius_git_source_remote
      set -a opts $LOPHIUS_GIT_PRESET_REMOTE

    case author
      set source __lophius_git_source_author
      set -a opts $LOPHIUS_GIT_PRESET_AUTHOR
  end

  # Set opts based on bind_type for ref types (branch, commit, tag)
  switch $source_type
    case branch commit tag
      switch $bind_type
        case ref_full
          # Full preset with header (shows reload keys)
          set -a opts $LOPHIUS_GIT_PRESET_REF
        case ref_simple
          # Simple preset: use LOG_SIMPLE for commits, no header for branches/tags
          switch $source_type
            case commit
              set -a opts $LOPHIUS_GIT_PRESET_LOG_SIMPLE
            case branch tag
              set -a opts $LOPHIUS_GIT_PRESET_REF_NO_HEADER
          end
      end
  end

  # Add --multi if needed
  # Note: status_file and ls_file presets already include --multi
  if test "$multi" = true
    switch $source_type
      case branch commit tag stash
        set -a opts --multi
    end
  end

  # Add prompt
  set -a opts --prompt=$prompt

  # Output null-separated: source, transformer, then opts
  printf '%s\0' $source $transformer $opts
end

function __lophius_rule_git
  set -l cmd (commandline)

  # Parse commandline to get completion metadata
  set -l parse_result (__lophius_git_parse_cmdline $cmd)
  test -z "$parse_result" && return 1

  # Split result into source_type, multi, bind_type, and prompt
  set -l parts (string split \t $parse_result)
  set -l source_type $parts[1]
  set -l multi $parts[2]
  set -l bind_type $parts[3]
  set -l prompt $parts[4]

  # Build configuration and parse null-separated output
  set -l config_output (__lophius_git_build_config $source_type $multi $bind_type $prompt | string split0)

  # First element is source, second is transformer, rest are opts
  set -l source $config_output[1]
  set -l transformer $config_output[2]
  set -l opts $LOPHIUS_COMMON_OPTS $config_output[3..]

  __lophius_run "$source" "$transformer" $opts
  return 0
end
