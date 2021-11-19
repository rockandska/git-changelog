# Standard things
sp := $(sp).x
dirstack_$(sp) := $(d)
d	:= $(dir)

# Vars
TEST_BATS_DOCKER_DIR := $(d)
TEST_BATS_DOCKER_ABS_DIR := $(MKFILE_DIR)/$(d)
TEST_BATS_DOCKER_VERSION := 54e965fa9d269c2b3ff9036d81f32bac3df0edea
TEST_BATS_DOCKER_IMAGE_NAME ?= git-changelog-bats-test
TEST_BATS_DOCKER_IMAGES_LIST := $(notdir $(basename $(wildcard $(TEST_BATS_DOCKER_ABS_DIR)/*.dockerfile)))
TEST_BATS_DOCKER_IMAGES_TARGET_PREFIX := test-bats-docker-build
TEST_BATS_DOCKER_IMAGES_TARGETS := $(addprefix $(TEST_BATS_DOCKER_IMAGES_TARGET_PREFIX)-,$(TEST_BATS_DOCKER_IMAGES_LIST))

#####
# Targets
#####

# Build
.PHONY: $(TEST_BATS_DOCKER_IMAGES_TARGET_PREFIX)
$(TEST_BATS_DOCKER_IMAGES_TARGET_PREFIX): $(TEST_BATS_DOCKER_IMAGES_TARGETS)

.PHONY: $(TEST_BATS_DOCKER_IMAGES_TARGETS)
$(TEST_BATS_DOCKER_IMAGES_TARGETS): $(TEST_BATS_DOCKER_IMAGES_TARGET_PREFIX)-% :
	$(info ##### Build '$(TEST_BATS_DOCKER_IMAGE_NAME):$(*)' docker image #####)
	docker build \
		--quiet \
		-f $(TEST_BATS_DOCKER_DIR)/$(*).dockerfile \
		--build-arg BATS_VERSION="$(TEST_BATS_DOCKER_VERSION)" \
		-t $(TEST_BATS_DOCKER_IMAGE_NAME):$(*) \
		$(TEST_BATS_DOCKER_DIR)

# Standard things
d := $(dirstack_$(sp))
sp := $(basename $(sp))
