export
all: check-vars create-secrets build
password_exists = $(shell docker secret inspect basic-auth-password >/dev/null 2>&1 && echo $$?)
check-vars:
network_exists = $(shell docker network inspect traefik-net >/dev/null 2>&1 && echo $$?)
ifndef DNS_SUFFIX
	$(error env var DNS_SUFFIX is not set)
endif

build-network:
ifeq (echo $(network_exists), 1)
	@docker network create --driver=overlay traefik-net
endif

check-secrets:
ifndef FAAS_USERNAME
	$(error env var FAAS_USERNAME is not set)
endif
ifndef FAAS_PASSWORD
	$(error env var FAAS_PASSWORD is not set)
endif

create-secrets: check-secrets
	$(eval USER_EXISTS := $(shell docker secret inspect basic-auth-user >/dev/null 2>&1 && echo $$?))
	@echo ${USER_EXISTS}
ifeq (echo $(user_exists), 1)
	@echo ${FAAS_USERNAME} | docker secret create basic-auth-user -
endif
ifeq (echo $(password_exists), 1)
	@echo ${FAAS_PASSWORD} | docker secret create basic-auth-password -
endif

build: build-network
	echo $(user_exists)
	@docker stack deploy -c docker-compose.yml func

refresh: destroy build

destroy:
	@docker stack rm func
	@sleep 2

destroy-all: destroy
	@docker secret rm basic-auth-user
	@docker secret rm basic-auth-password
	@-docker network rm traefik-net
