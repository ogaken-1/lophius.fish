# __lophius_rule_cd.fish - cd completion rules
#
# Completion rule is ported from zeno.zsh
# https://github.com/yuki-yano/zeno.zsh
#
# MIT License
# Copyright (c) 2021 Yuki Yano

function __lophius_rule_cd
  set -l cmd (commandline)
  if string match -rq '^cd $' -- $cmd
    __lophius_run \
      "find . -maxdepth 5 -path '*/.git' -prune -o -type d -print0" \
      "cut -c 3-" \
      --read0 \
      --prompt='Chdir> ' \
      --preview='cd {} && ls -a | sed '"'"'/^[.]*$/d'"'"
    return 0
  end
  return 1
end
