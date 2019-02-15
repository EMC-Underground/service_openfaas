### Create Basic Auth

```shell
echo "admin" | docker -H=<swarm_fqdn> secret create basic-auth-user -
echo "password" | docker -H=<swarm_fqdn> secret create basic-auth-password -
```

### Proxy network required
*deploy traefik before*
```shell
docker -H=<swarm_fqdn> network create --driver=overlay traefik-net
```

### Deploy

```shell
docker -H=<swarm_ip> stack deploy -c docker-compose.yml func
```
