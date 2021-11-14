######
# Include header
######
sp := $(sp).x
dirstack_$(sp) := $(d)
d := $(dir)

#####
# Docker vars
#####

DOCKER_DIR := $(d)
DOCKER_ABS_DIR := $(MKFILE_DIR)$(d)
DOCKER_TARGETS := docker-build

DOCKER_REGISTRY ?=
DOCKER_REGISTRY_USER ?= rockandska
DOCKER_REGISTRY_PASSWORD ?=
DOCKER_REGISTRY_NAMESPACE ?= rockandska/
DOCKER_IMAGE_NAME := git-changelog
DOCKER_IMAGE_FULL_NAME := $(DOCKER_REGISTRY)$(DOCKER_REGISTRY_NAMESPACE)$(DOCKER_IMAGE_NAME)

DOCKERHUB_DESCRIPTION_VERSION := 2.4.2

#####
# Targets
#####

.PHONY: docker
docker: $(DOCKER_TARGETS)

.SECONDARY: docker-login
docker-login:
	printf '%s\n' '##### Try to logging to docker registry $(DOCKER_REGISTRY) #####'
	docker login $(DOCKER_REGISTRY) < /dev/null 2> /dev/null	|| {
			[[ '$(DOCKER_REGISTRY_PASSWORD)' == "" ]] && {
					1>&2 echo "Error: DOCKER_REGISTRY_PASSWORD not set";
					exit 1;
			} || echo $$'$(DOCKER_REGISTRY_PASSWORD)' | docker login --username $(DOCKER_REGISTRY_USER) --password-stdin $(DOCKER_REGISTRY);
	}

.PHONY: docker-build
docker-build:
	printf '%s\n' "##### Building Docker image : '$(DOCKER_IMAGE_NAME):latest' #####"
	docker build --quiet -f $(DOCKER_ABS_DIR)/Dockerfile $(MKFILE_DIR) -t $(DOCKER_IMAGE_NAME):latest

.PHONY: docker-publish
docker-publish: GIT_TAG = $(shell git tag --points-at 2> /dev/null | head -n1)
docker-publish: docker-build docker-login docker-sync-readme
	if [[ -n "$${GIT_TAG:=$(GIT_TAG)}" ]];then
		printf '%s\n' "##### Publishing '$(DOCKER_IMAGE_NAME):$(GIT_TAG)' on registry $(DOCKER_REGISTRY) #####"
		docker image tag $(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_FULL_NAME):$(GIT_TAG)
		docker push $(DOCKER_IMAGE_FULL_NAME):$(GIT_TAG)
	fi
	printf '%s\n' "##### Publishing '$(DOCKER_IMAGE_NAME):latest' on registry $(DOCKER_REGISTRY) #####"
	docker image tag $(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_FULL_NAME):latest
	docker push $(DOCKER_IMAGE_FULL_NAME):latest

docker-sync-readme: docker-login
	printf '%s\n' "##### Syncing README to DockerHub #####"
	if [[ -z "$(DOCKER_REGISTRY_PASSWORD)" ]];then
		printf '%s\n' "##### Try to retrieve credentials from ~/.docker/config.json #####"
		DOCKER_CONFIG_CREDS=$$(cat ~/.docker/config.json | docker run -i --rm itchyny/gojq:0.12.5 -r '.auths | with_entries( select(.key|contains("$(if $(DOCKER_REGISTRY),$(DOCKER_REGISTRY),docker.io)")))[].auth' | base64 -d)
		IFS=: read DOCKER_REGISTRY_USER DOCKER_REGISTRY_PASSWORD <<< "$${DOCKER_CONFIG_CREDS}"
	fi
	docker run -v $(MKFILE_DIR):/workspace \
	-e DOCKERHUB_USERNAME="$(if $(DOCKER_REGISTRY_USER),$(DOCKER_REGISTRY_USER),$${DOCKER_REGISTRY_USER})" \
	-e DOCKERHUB_PASSWORD="$(if $(DOCKER_REGISTRY_PASSWORD),$(DOCKER_REGISTRY_PASSWORD),$${DOCKER_REGISTRY_PASSWORD})" \
	-e DOCKERHUB_REPOSITORY="$(DOCKER_IMAGE_FULL_NAME)" \
	-e README_FILEPATH='/workspace/README.md' \
	-e SHORT_DESCRIPTION='Custom git command to generate/update CHANGELOG from conventional commits' \
	peterevans/dockerhub-description:$(DOCKERHUB_DESCRIPTION_VERSION)

#####
# Include footer
#####
d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))
