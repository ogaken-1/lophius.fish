function __lophius_docker_source_network
  docker network ls --format '{{"\033[34m"}}{{.Name}}{{"\033[0m"}}\t{{.Driver}}\t{{.Scope}}' 2>/dev/null | column -t -s (printf '\t')
end
