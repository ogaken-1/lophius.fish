# __lophius_kill.fish - kill completion rules
#
# PID completion rule is ported from zeno.zsh
# https://github.com/yuki-yano/zeno.zsh
#
# MIT License
# Copyright (c) 2021 Yuki Yano

function __lophius_rule_kill
  set -l cmd (commandline)

  # kill PID
  if string match -rq '^kill( .*)? $' -- $cmd
    and not string match -rq ' -[lns] $' -- $cmd
    LANG=C __lophius_run \
      'ps -ef | sed 1d' \
      'awk \'{ print $2 }\'' \
      --multi \
      --prompt='Kill Process> '
    return 0
  end

  return 1
end
