# __lophius_rule_docker.fish - Docker Completion rules
# See: ../conf.d/lophius.fish ./lophius.fish
#
# Docker completion patterns for containers, images, volumes, and networks

# === Transformers ===
# All docker resources use first column (name/repo:tag)
function __lophius_docker_to_arg
  awk '{ print $1 }'
end

# === Parser ===
# Parse commandline and return completion metadata
# Output format: source_type\tmulti\tbind_type\tprompt
# source_type: container, container_running, image, volume, network
# multi: true or false
# bind_type: default
# Outputs nothing if no match found
function __lophius_docker_parse_cmdline
  set -l cmd $argv[1]

  # docker exec (running containers only)
  if string match -rq '^docker exec(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' container_running false default 'Docker Exec> '

  # docker stop/restart/kill (running containers, multi)
  else if string match -rq '^docker (?:stop|restart|kill)(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' container_running true default 'Docker Container> '

  # docker start (stopped containers, multi) - use all containers
  else if string match -rq '^docker start(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' container true default 'Docker Start> '

  # docker rm (all containers, multi)
  else if string match -rq '^docker rm(?: .*)? $' -- $cmd
    and not string match -rq '^docker rmi ' -- $cmd
    printf '%s\t%s\t%s\t%s\n' container true default 'Docker RM> '

  # docker logs (all containers for history)
  else if string match -rq '^docker logs(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' container false default 'Docker Logs> '

  # docker attach/top/stats (running containers)
  else if string match -rq '^docker (?:attach|top|stats)(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' container_running false default 'Docker Container> '

  # docker pause/unpause (running containers, multi)
  else if string match -rq '^docker (?:pause|unpause)(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' container_running true default 'Docker Container> '

  # docker inspect (containers - could also be images, default to container)
  else if string match -rq '^docker inspect(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' container true default 'Docker Inspect> '

  # docker cp (all containers)
  else if string match -rq '^docker cp(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' container false default 'Docker CP> '

  # docker run (images)
  else if string match -rq '^docker run(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' image false default 'Docker Run> '

  # docker rmi (images, multi)
  else if string match -rq '^docker rmi(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' image true default 'Docker RMI> '

  # docker tag (images)
  else if string match -rq '^docker tag(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' image false default 'Docker Tag> '

  # docker push/save/history (images)
  else if string match -rq '^docker (?:push|save|history)(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' image false default 'Docker Image> '

  # docker create (images)
  else if string match -rq '^docker create(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' image false default 'Docker Create> '

  # docker volume rm (volumes, multi)
  else if string match -rq '^docker volume rm(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' volume true default 'Docker Volume RM> '

  # docker volume inspect (volumes, multi)
  else if string match -rq '^docker volume inspect(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' volume true default 'Docker Volume> '

  # docker network rm (networks, multi)
  else if string match -rq '^docker network rm(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' network true default 'Docker Network RM> '

  # docker network inspect (networks)
  else if string match -rq '^docker network inspect(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' network true default 'Docker Network> '

  # docker network connect/disconnect (first arg is network)
  else if string match -rq '^docker network (?:connect|disconnect)(?: .*)? $' -- $cmd
    printf '%s\t%s\t%s\t%s\n' network false default 'Docker Network> '

  end
end

# === Config Builder ===
# Build fzf configuration for docker completion
# Arguments: source_type multi bind_type prompt
# Output: null-separated values: source, transformer, opts...
function __lophius_docker_build_config
  set -l source_type $argv[1]
  set -l multi $argv[2]
  set -l bind_type $argv[3]
  set -l prompt $argv[4]

  set -l source
  set -l transformer __lophius_docker_to_arg
  set -l opts

  switch $source_type
    case container
      set source __lophius_docker_source_container
      set -a opts $LOPHIUS_DOCKER_PRESET_CONTAINER
    case container_running
      set source __lophius_docker_source_container_running
      set -a opts $LOPHIUS_DOCKER_PRESET_CONTAINER
    case image
      set source __lophius_docker_source_image
      set -a opts $LOPHIUS_DOCKER_PRESET_IMAGE
    case volume
      set source __lophius_docker_source_volume
      set -a opts $LOPHIUS_DOCKER_PRESET_VOLUME
    case network
      set source __lophius_docker_source_network
      set -a opts $LOPHIUS_DOCKER_PRESET_NETWORK
  end

  # Add multi option if needed
  if test "$multi" = true
    set -a opts --multi
  end

  # Add prompt
  set -a opts --prompt=$prompt

  # Output null-separated
  printf '%s\0' $source $transformer $opts
end

function __lophius_rule_docker
  set -l cmd (commandline)

  # Parse commandline to get completion metadata
  set -l parse_result (__lophius_docker_parse_cmdline $cmd)
  test -z "$parse_result" && return 1

  # Check if docker is accessible (user may not be in docker group)
  docker info >/dev/null 2>&1
  or return 1

  # Split result into source_type, multi, bind_type, and prompt
  set -l parts (string split \t $parse_result)
  set -l source_type $parts[1]
  set -l multi $parts[2]
  set -l bind_type $parts[3]
  set -l prompt $parts[4]

  # Build configuration and parse null-separated output
  set -l config_output (__lophius_docker_build_config $source_type $multi $bind_type $prompt | string split0)

  # First element is source, second is transformer, rest are opts
  set -l source $config_output[1]
  set -l transformer $config_output[2]
  set -l opts $LOPHIUS_COMMON_OPTS $config_output[3..]

  __lophius_run "$source" "$transformer" $opts
  return 0
end
