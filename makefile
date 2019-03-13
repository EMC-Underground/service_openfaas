all: checks create-secrets

check-vars:
ifndef FAAS_USERNAME
	$(error env var FAAS_USERNAME is not set)
endif
ifndef FAAS_PASSWORD
	$(error env var FAAS_PASSWORD is not set)
endif
ifndef DNS_SUFFIX
	$(error env var DNS_SUFFIX is not set)
endif

check-network:
	@docker network inspect traefik-net &> /dev/null && ([ $$? -eq 0 ] && NETWORK_EXISTS="true") || NETWORK_EXISTS="false"

build-network: check-network
	@-echo $$(NETWORK_EXISTS)
ifndef NETWORK_EXISTS
	@-docker network create --driver=overlay traefik-net
endif

create-secrets:
	echo ${FAAS_USERNAME} | docker secret create basic-auth-user -
	echo ${FAAS_PASSWORD} | docker secret create basic-auth-password -
