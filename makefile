all: check-vars create-secrets build
user_exists = $(shell docker secret inspect basic-auth-user >/dev/null 2>&1 && echo $$?)
password_exists = $(shell docker secret inspect basic-auth-password >/dev/null 2>&1 && echo $$?)

check-vars:
ifndef DNS_SUFFIX
	$(error env var DNS_SUFFIX is not set)
endif

check-network:
	@docker network inspect traefik-net &> /dev/null && ([ $$? -eq 0 ] && export NETWORK_EXISTS="true") || export NETWORK_EXISTS="false"

build-network: check-network
ifndef NETWORK_EXISTS
	@-docker network create --driver=overlay traefik-net
endif

check-secrets:
ifndef FAAS_USERNAME
	$(error env var FAAS_USERNAME is not set)
endif
ifndef FAAS_PASSWORD
	$(error env var FAAS_PASSWORD is not set)
endif

create-secrets: check-secrets
ifeq (echo $(user_exists), 0)
	@echo ${FAAS_USERNAME} | docker secret create basic-auth-user -
endif
ifeq (echo $(password_exists), 0)
	@echo ${FAAS_PASSWORD} | docker secret create basic-auth-password -
endif

build: build-network
	@docker stack deploy -c docker-compose.yml func

refresh: destroy build

destroy:
	@docker stack rm func
	@sleep 2

destroy-all: destroy
	@-docker network rm traefik-net
