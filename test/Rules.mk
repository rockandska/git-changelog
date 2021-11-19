######
# Include header
######
sp := $(sp).x
dirstack_$(sp) := $(d)
d := $(dir)

#####
# Includes
#####

dir	:= $(d)/bats
include		$(dir)/Rules.mk

#####
# Vars
#####

TEST_DIR := $(d)
TEST_ABS_DIR := $(MKFILE_DIR)/$(d)
TEST_TARGETS := shellcheck $(TEST_BATS_TARGETS)

SHELL_CHECK_VERSION := v0.7.0

#####
# targets
#####

.PHONY: shellcheck
shellcheck: $(MKFILE_DIR)/tmp/bin/shellcheck $(MKFILE_DIR)/.github/workflows/pull_request.yml
	$(info ##### Start tests with shellcheck #####)
	while IFS= read -r -d $$'' file; do
		case "$$file" in
			*/*.sh|*/*.bash) : ;;
			*/tmp/*) continue ;;
			*) [[ $$(file -b --mime-type "$$file") == text/x-shellscript ]] && : || continue ;;
		esac
		$< -s bash -x -P $(MKFILE_DIR) $$file
	done < <(find $(MKFILE_DIR) \( -path $(MKFILE_DIR)/.git -prune \) -o \( -type f -print0 \))

.INTERMEDIATE: $(MKFILE_DIR)/tmp/bin/shellcheck
$(MKFILE_DIR)/tmp/bin/shellcheck: $(MKFILE_DIR)/tmp/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck
	mkdir -p $(@D)
	ln -r -f -s $< $@

.SECONDARY: $(MKFILE_DIR)/tmp/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck
$(MKFILE_DIR)/tmp/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck:
	$(info ##### Downloading Shellcheck $(SHELL_CHECK_VERSION))
	mkdir -p $(@D)
	wget -qO- "https://github.com/koalaman/shellcheck/releases/download/$(SHELL_CHECK_VERSION)/shellcheck-$(SHELL_CHECK_VERSION).linux.x86_64.tar.xz" | tar -xJ -C $(MKFILE_DIR)/tmp/opt

#####
# Include footer
#####
d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))
