# Standard things
sp := $(sp).x
dirstack_$(sp) := $(d)
d	:= $(dir)

#####
# Includes
#####

dir	:= $(d)/Docker
include		$(dir)/Rules.mk

#####
# Vars
#####
TEST_BATS_DIR := $(d)
TEST_BATS_ABS_DIR := $(MKFILE_DIR)$(d)

TEST_BATS_TARGETS_PREFIX := test-bats
TEST_BATS_TARGETS := $(addprefix $(TEST_BATS_TARGETS_PREFIX)-,$(TEST_BATS_DOCKER_IMAGES_LIST))

#####
# Targets
#####

.PHONY: $(TEST_BATS_TARGETS_PREFIX)
$(TEST_BATS_TARGETS_PREFIX): $(TEST_BATS_TARGETS)

.PHONY: $(TEST_BATS_TARGETS)
$(TEST_BATS_TARGETS): $(TEST_BATS_TARGETS_PREFIX)-% : $(TEST_BATS_DOCKER_IMAGES_TARGET_PREFIX)-%
	$(info ##### Start tests with bats on docker (image: $(addprefix $(TEST_BATS_DOCKER_IMAGE_NAME):,$*)) #####)
	docker run -ti --rm -e BATS_PROJECT_DIR="$(MKFILE_DIR)" -v $(MKFILE_DIR):${MKFILE_DIR}:ro $(addprefix $(TEST_BATS_DOCKER_IMAGE_NAME):,$*) -r ${TEST_BATS_ABS_DIR}/specs/

# Standard things
d := $(dirstack_$(sp))
sp := $(basename $(sp))
