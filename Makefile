.ONESHELL:
.DELETE_ON_ERROR:
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

export PATH := $(MKFILE_DIR):$(PATH)

DOCKER_REGISTRY ?=
DOCKER_REGISTRY_USER ?= rockandska
DOCKER_REGISTRY_PASSWORD ?=
DOCKER_REGISTRY_NAMESPACE ?= rockandska/
DOCKER_IMAGE_NAME := git-changelog
DOCKER_IMAGE_FULL_NAME := $(DOCKER_REGISTRY)$(DOCKER_REGISTRY_NAMESPACE)$(DOCKER_IMAGE_NAME)

###############

# invoking make V=1 will print everything
$(V).SILENT:

.PHONY: all
all: changelog

.PHONY: changelog
changelog:
	$(info ##### CHANGELOG generation #####)
	git changelog
	git add $(MKFILE_DIR)/CHANGELOG.md
	git commit -m "Update CHANGELOG [skip ci]"

.PHONY: release
release:
	$(info ##### Release #####)
	: $${LAST_VERSION:=$$(git for-each-ref --sort=-creatordate --format '%(refname)' refs/tags | sed 's/refs\/tags\///' | head -n1)}
	: $${NEXT_VERSION:=$$(docker run --rm -v $(MKFILE_DIR):/tmp --workdir /tmp ghcr.io/caarlos0/svu next --strip-prefix)}
	[[ "$$LAST_VERSION" == "$$NEXT_VERSION" ]] && { 1>&2 echo "Error: Next version is the same as the previous one !"; exit 1; }
	[[ -z "$$NEXT_VERSION" ]] && { 1>&2 echo "Error: Next version is empty !"; exit 1; }
	echo "##### version : '$${NEXT_VERSION' #####"
	CHANGELOG_TAG="$${NEXT_VERSION}" $(MAKE) --no-print-directory changelog
	git add $(MKFILE_DIR)/CHANGELOG.md
	git commit -m "Bump version to $${NEXT_VERSION} [skip ci]"
	git tag -m "$${NEXT_VERSION}" "$${NEXT_VERSION}"

.SECONDARY: docker-login
docker-login:
	$(info ##### Try to logging to docker registry $(DOCKER_REGISTRY) #####)
	docker login $(DOCKER_REGISTRY) < /dev/null 2> /dev/null	|| {
			[[ $$'$(DOCKER_REGISTRY_PASSWORD)' == "" ]] && {
					1>&2 echo "Error: DOCKER_REGISTRY_PASSWORD not set";
					exit 1;
			} || docker login --username $(DOCKER_REGISTRY_USER) --password $$'$(DOCKER_REGISTRY_PASSWORD)' $(DOCKER_REGISTRY);
	}

.PHONY: docker-build
docker-build: DOCKER_TAG:=$(if $(shell git tag --points-at 2> /dev/null | head -n1),,latest)
docker-build:
	$(info ##### Building Docker image : '$(DOCKER_IMAGE_NAME):$(DOCKER_TAG)' #####)
	docker build --quiet -f $(MKFILE_DIR)/Dockerfile $(MKFILE_DIR) -t $(DOCKER_IMAGE_NAME):$(DOCKER_TAG) -t $(DOCKER_IMAGE_NAME):latest

.PHONY: docker-publish
docker-publish: DOCKER_TAG:=$(shell git tag --points-at 2> /dev/null | head -n1)
docker-publish: docker-build docker-login
ifneq ($(DOCKER_TAG),)
		$(info ##### Publishing '$(DOCKER_IMAGE_NAME):$(DOCKER_TAG)' on registry $(DOCKER_REGISTRY) #####)
		docker image tag $(DOCKER_IMAGE_NAME):$(DOCKER_TAG) $(DOCKER_IMAGE_FULL_NAME):$(DOCKER_TAG)
		docker push $(DOCKER_IMAGE_FULL_NAME):$(DOCKER_TAG)
endif
	$(info ##### Publishing '$(DOCKER_IMAGE_NAME):latest' on registry $(DOCKER_REGISTRY) #####)
	docker image tag $(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_FULL_NAME):latest
	docker push $(DOCKER_IMAGE_FULL_NAME):latest
