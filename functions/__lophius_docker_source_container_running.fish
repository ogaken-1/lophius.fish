function __lophius_docker_source_container_running
  docker ps --format '{{"\033[32m"}}{{.Names}}{{"\033[0m"}}\t{{"\033[33m"}}{{.ID}}{{"\033[0m"}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null | column -t -s (printf '\t')
end
