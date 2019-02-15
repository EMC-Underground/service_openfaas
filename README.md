Need to create basic auth U/P

echo "admin" | docker -H=<swarm_fqdn> secret create basic-auth-user -
echo "password" | docker -H=<swarm_fqdn> secret create basic-auth-password -

Also requires Traefik Reverse Proxy with a proxy overlay

docker -H=<swarm_fqdn> network create --driver=overlay traefik-net

Deploy with

docker -H=<swarm_ip> stack deploy -c docker-compose.yml func
