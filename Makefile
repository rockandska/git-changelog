.ONESHELL:
.DELETE_ON_ERROR:
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c $(if $(V),-x)

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

export PATH := $(MKFILE_DIR):$(MKFILE_DIR)/tmp/bin:$(PATH)

###############

# invoking make V=1 will print everything
$(V).SILENT:

.PHONY: changelog
changelog:
	printf '%s\n' "##### Update CHANGELOG (version: $${CHANGELOG_TAG:-Unreleased} ) #####"
	git changelog
	if ! git diff --exit-code CHANGELOG.md 2>&1 > /dev/null;then
		printf '%s\n' "##### Commiting changes #####"
		git add CHANGELOG.md
		if [[ -n "$${CHANGELOG_TAG:-}" ]];then
			git commit -m "Bump version to $${CHANGELOG_TAG} [skip ci]"
			printf '%s\n' "##### Add tag '$${CHANGELOG_TAG}' #####"
			git tag -m "$${CHANGELOG_TAG}" "$${CHANGELOG_TAG}"
		else
			git commit -m "Changelog update [skip ci]"
		fi
	else
		1>&2 printf '%s\n' "No changes made to CHANGELOG.md"
	fi

.PHONY: release
release: CURRENT_GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
release: LAST_VERSION = $(shell git for-each-ref --merged $(CURRENT_GIT_BRANCH) --sort=-creatordate --format '%(refname)' refs/tags | sed 's/refs\/tags\///' | head -n1)
release: NEXT_VERSION = $(shell docker run --rm -v $(MKFILE_DIR):/tmp --workdir /tmp ghcr.io/caarlos0/svu next --strip-prefix)
release:
	printf '%s\n' "##### Release (LAST_VERSION='$${LAST_VERSION:=$(LAST_VERSION)}' / NEXT_VERSION='$${NEXT_VERSION:=$(NEXT_VERSION)}' ) #####"
	[[ "$${LAST_VERSION}" == "$${NEXT_VERSION}" ]] \
		&& { NEXT_VERSION=''; printf '%s\n' 'Version: Unreleased'; } \
		|| printf '%s\n' "Version: $${NEXT_VERSION}"
	CHANGELOG_TAG="$${NEXT_VERSION}" $(MAKE) --no-print-directory changelog

#####
# Includes
#####

dir	:= test
include		$(dir)/Rules.mk
dir	:= Docker
include		$(dir)/Rules.mk
