.ONESHELL:
.DELETE_ON_ERROR:
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

export PATH := $(MKFILE_DIR):$(PATH)

.PHONY: all
all: changelog

.PHONY: changelog
changelog:
	git changelog
	git add $(MKFILE_DIR)/CHANGELOG.md
	git commit -m "Update CHANGELOG [skip ci]"

.PHONY: release
release:
	@: $${LAST_VERSION:=$$(git for-each-ref --sort=-creatordate --format '%(refname)' refs/tags | sed 's/refs\/tags\///' | head -n1)}
	@: $${NEXT_VERSION:=$$(docker run --rm -v $(MKFILE_DIR):/tmp --workdir /tmp ghcr.io/caarlos0/svu next --strip-prefix)}
	[[ "$$LAST_VERSION" == "$$NEXT_VERSION" ]] && { 1>&2 echo "Error: Next version is the same as the previous one !"; exit 1; }
	[[ -z "$$NEXT_VERSION" ]] && { 1>&2 echo "Error: Next version is empty !"; exit 1; }
	CHANGELOG_TAG="$${NEXT_VERSION}" $(MAKE) --no-print-directory changelog
	git add $(MKFILE_DIR)/CHANGELOG.md
	git commit -m "Bump version to $${NEXT_VERSION} [skip ci]"
	git tag -m "$${NEXT_VERSION}" "$${NEXT_VERSION}"
