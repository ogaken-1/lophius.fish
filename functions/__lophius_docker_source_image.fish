function __lophius_docker_source_image
  docker images --format '{{"\033[36m"}}{{.Repository}}:{{.Tag}}{{"\033[0m"}}\t{{"\033[33m"}}{{.ID}}{{"\033[0m"}}\t{{.Size}}\t{{.CreatedSince}}' 2>/dev/null | column -t -s (printf '\t')
end
