# Test __lophius_docker_parse_cmdline output format and values

source (status dirname)/../functions/__lophius_rule_docker.fish

# ============================================================
# 1. Container commands (running containers)
# ============================================================
@test "docker exec" (__lophius_docker_parse_cmdline "docker exec ") = (printf '%s\t%s\t%s\t%s\n' container_running false default 'Docker Exec> ')
@test "docker exec with options" (__lophius_docker_parse_cmdline "docker exec -it ") = (printf '%s\t%s\t%s\t%s\n' container_running false default 'Docker Exec> ')
@test "docker stop" (__lophius_docker_parse_cmdline "docker stop ") = (printf '%s\t%s\t%s\t%s\n' container_running true default 'Docker Container> ')
@test "docker restart" (__lophius_docker_parse_cmdline "docker restart ") = (printf '%s\t%s\t%s\t%s\n' container_running true default 'Docker Container> ')
@test "docker kill" (__lophius_docker_parse_cmdline "docker kill ") = (printf '%s\t%s\t%s\t%s\n' container_running true default 'Docker Container> ')
@test "docker attach" (__lophius_docker_parse_cmdline "docker attach ") = (printf '%s\t%s\t%s\t%s\n' container_running false default 'Docker Container> ')
@test "docker top" (__lophius_docker_parse_cmdline "docker top ") = (printf '%s\t%s\t%s\t%s\n' container_running false default 'Docker Container> ')
@test "docker stats" (__lophius_docker_parse_cmdline "docker stats ") = (printf '%s\t%s\t%s\t%s\n' container_running false default 'Docker Container> ')
@test "docker pause" (__lophius_docker_parse_cmdline "docker pause ") = (printf '%s\t%s\t%s\t%s\n' container_running true default 'Docker Container> ')
@test "docker unpause" (__lophius_docker_parse_cmdline "docker unpause ") = (printf '%s\t%s\t%s\t%s\n' container_running true default 'Docker Container> ')

# ============================================================
# 2. Container commands (all containers)
# ============================================================
@test "docker start" (__lophius_docker_parse_cmdline "docker start ") = (printf '%s\t%s\t%s\t%s\n' container true default 'Docker Start> ')
@test "docker rm" (__lophius_docker_parse_cmdline "docker rm ") = (printf '%s\t%s\t%s\t%s\n' container true default 'Docker RM> ')
@test "docker rm with options" (__lophius_docker_parse_cmdline "docker rm -f ") = (printf '%s\t%s\t%s\t%s\n' container true default 'Docker RM> ')
@test "docker logs" (__lophius_docker_parse_cmdline "docker logs ") = (printf '%s\t%s\t%s\t%s\n' container false default 'Docker Logs> ')
@test "docker inspect" (__lophius_docker_parse_cmdline "docker inspect ") = (printf '%s\t%s\t%s\t%s\n' container true default 'Docker Inspect> ')
@test "docker cp" (__lophius_docker_parse_cmdline "docker cp ") = (printf '%s\t%s\t%s\t%s\n' container false default 'Docker CP> ')

# ============================================================
# 3. Image commands
# ============================================================
@test "docker run" (__lophius_docker_parse_cmdline "docker run ") = (printf '%s\t%s\t%s\t%s\n' image false default 'Docker Run> ')
@test "docker run with options" (__lophius_docker_parse_cmdline "docker run --rm -it ") = (printf '%s\t%s\t%s\t%s\n' image false default 'Docker Run> ')
@test "docker rmi" (__lophius_docker_parse_cmdline "docker rmi ") = (printf '%s\t%s\t%s\t%s\n' image true default 'Docker RMI> ')
@test "docker rmi with options" (__lophius_docker_parse_cmdline "docker rmi -f ") = (printf '%s\t%s\t%s\t%s\n' image true default 'Docker RMI> ')
@test "docker tag" (__lophius_docker_parse_cmdline "docker tag ") = (printf '%s\t%s\t%s\t%s\n' image false default 'Docker Tag> ')
@test "docker push" (__lophius_docker_parse_cmdline "docker push ") = (printf '%s\t%s\t%s\t%s\n' image false default 'Docker Image> ')
@test "docker save" (__lophius_docker_parse_cmdline "docker save ") = (printf '%s\t%s\t%s\t%s\n' image false default 'Docker Image> ')
@test "docker history" (__lophius_docker_parse_cmdline "docker history ") = (printf '%s\t%s\t%s\t%s\n' image false default 'Docker Image> ')
@test "docker create" (__lophius_docker_parse_cmdline "docker create ") = (printf '%s\t%s\t%s\t%s\n' image false default 'Docker Create> ')

# ============================================================
# 4. Volume commands
# ============================================================
@test "docker volume rm" (__lophius_docker_parse_cmdline "docker volume rm ") = (printf '%s\t%s\t%s\t%s\n' volume true default 'Docker Volume RM> ')
@test "docker volume inspect" (__lophius_docker_parse_cmdline "docker volume inspect ") = (printf '%s\t%s\t%s\t%s\n' volume true default 'Docker Volume> ')

# ============================================================
# 5. Network commands
# ============================================================
@test "docker network rm" (__lophius_docker_parse_cmdline "docker network rm ") = (printf '%s\t%s\t%s\t%s\n' network true default 'Docker Network RM> ')
@test "docker network inspect" (__lophius_docker_parse_cmdline "docker network inspect ") = (printf '%s\t%s\t%s\t%s\n' network true default 'Docker Network> ')
@test "docker network connect" (__lophius_docker_parse_cmdline "docker network connect ") = (printf '%s\t%s\t%s\t%s\n' network false default 'Docker Network> ')
@test "docker network disconnect" (__lophius_docker_parse_cmdline "docker network disconnect ") = (printf '%s\t%s\t%s\t%s\n' network false default 'Docker Network> ')

# ============================================================
# 6. Negative cases (should not match)
# ============================================================
@test "docker without subcommand should not match" (test -z (__lophius_docker_parse_cmdline "docker ")) $status -eq 0
@test "docker ps should not match" (test -z (__lophius_docker_parse_cmdline "docker ps ")) $status -eq 0
@test "docker images should not match" (test -z (__lophius_docker_parse_cmdline "docker images ")) $status -eq 0
@test "docker build should not match" (test -z (__lophius_docker_parse_cmdline "docker build ")) $status -eq 0
@test "docker pull should not match" (test -z (__lophius_docker_parse_cmdline "docker pull ")) $status -eq 0
@test "docker without space should not match" (test -z (__lophius_docker_parse_cmdline "docker")) $status -eq 0

# ============================================================
# 7. Ensure docker rm does not match docker rmi
# ============================================================
@test "docker rmi is not docker rm" (
  set -l result (__lophius_docker_parse_cmdline "docker rmi ")
  string match -q 'image*' -- $result
) $status -eq 0

@test "docker rm is container not image" (
  set -l result (__lophius_docker_parse_cmdline "docker rm ")
  string match -q 'container*' -- $result
) $status -eq 0
