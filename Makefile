.ONESHELL:
.DELETE_ON_ERROR:
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c $(if $(V),-x)

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

export PATH := $(MKFILE_DIR):$(MKFILE_DIR)/tmp/bin:$(PATH)

DOCKER_REGISTRY ?=
DOCKER_REGISTRY_USER ?= rockandska
DOCKER_REGISTRY_PASSWORD ?=
DOCKER_REGISTRY_NAMESPACE ?= rockandska/
DOCKER_IMAGE_NAME := git-changelog
DOCKER_IMAGE_FULL_NAME := $(DOCKER_REGISTRY)$(DOCKER_REGISTRY_NAMESPACE)$(DOCKER_IMAGE_NAME)

GIT_TAG :=$(shell git tag --points-at 2> /dev/null | head -n1)
LAST_VERSION := $(shell git for-each-ref --sort=-creatordate --format '%(refname)' refs/tags | sed 's/refs\/tags\///' | head -n1)
NEXT_VERSION := $(shell docker run --rm -v $(MKFILE_DIR):/tmp --workdir /tmp ghcr.io/caarlos0/svu next --strip-prefix)

SHELL_CHECK_VERSION := v0.7.0

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
	[[ "$(LAST_VERSION)" == "$(NEXT_VERSION)" ]] && { 1>&2 echo "Error: Next version is the same as the previous one !"; exit 1; }
	[[ -z "$(NEXT_VERSION)" ]] && { 1>&2 echo "Error: Next version is empty !"; exit 1; }
	$(info ##### version : '$(NEXT_VERSION)' #####)
	CHANGELOG_TAG="$(NEXT_VERSION)" $(MAKE) --no-print-directory changelog
	git commit --amend --no-edit -m "Bump version to $(NEXT_VERSION) [skip ci]"
	git tag -m "$(NEXT_VERSION)" "$(NEXT_VERSION)"

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
docker-build:
	$(info ##### Building Docker image : '$(DOCKER_IMAGE_NAME):latest' #####)
	docker build --quiet -f $(MKFILE_DIR)/Dockerfile $(MKFILE_DIR) -t $(DOCKER_IMAGE_NAME):latest $(if $(GIT_TAG),-t $(DOCKER_IMAGE_NAME):$(GIT_TAG))

.PHONY: docker-publish
docker-publish: docker-build docker-login
ifneq ($(GIT_TAG),)
	$(info ##### Publishing '$(DOCKER_IMAGE_NAME):$(GIT_TAG)' on registry $(DOCKER_REGISTRY) #####)
	docker image tag $(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_FULL_NAME):$(GIT_TAG)
	docker push $(DOCKER_IMAGE_FULL_NAME):$(GIT_TAG)
endif
	$(info ##### Publishing '$(DOCKER_IMAGE_NAME):latest' on registry $(DOCKER_REGISTRY) #####)
	docker image tag $(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_FULL_NAME):latest
	docker push $(DOCKER_IMAGE_FULL_NAME):latest

.PHONY: test
test: shellcheck

.PHONY: shellcheck
shellcheck: $(MKFILE_DIR)/tmp/bin/shellcheck
	$(info ##### Start tests with shellcheck #####)
	while IFS= read -r -d $$'' file; do
		case "$$file" in
			*/*.sh|*/*.bash) : ;;
			*/tmp/*) continue ;;
			*) [[ $$(file -b --mime-type "$$file") == text/x-shellscript ]] && : || continue ;;
		esac
		$< -s bash -x -P $(MKFILE_DIR) $$file
	done < <(find $(MKFILE_DIR) -type f \! -path "$(MKFILE_DIR)/.git/*" -print0)

.INTERMEDIATE: $(MKFILE_DIR)/tmp/bin/shellcheck
$(MKFILE_DIR)/tmp/bin/shellcheck: $(MKFILE_DIR)/tmp/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck
	mkdir -p $(@D)
	ln -r -f -s $< $@

.SECONDARY: $(MKFILE_DIR)/tmp/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck
$(MKFILE_DIR)/tmp/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck:
	$(info ##### Downloading Shellcheck $(SHELL_CHECK_VERSION))
	mkdir -p $(@D)
	wget -qO- "https://github.com/koalaman/shellcheck/releases/download/$(SHELL_CHECK_VERSION)/shellcheck-$(SHELL_CHECK_VERSION).linux.x86_64.tar.xz" | tar -xJ -C $(MKFILE_DIR)/tmp/opt
