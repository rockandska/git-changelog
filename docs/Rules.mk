######
# Include header
######
sp := $(sp).x
dirstack_$(sp) := $(d)
d := $(dir)


#####
# Docs vars
#####

DOCS_DIR := $(d)
DOCS_ABS_DIR := $(MKFILE_DIR)/$(d)
DOCS_TARGETS := docs-serve

MKDOCS_DOCKER_VERSION := 1.1.2

.SECONDARY: $(DOCS_DIR)/requirements.txt
$(DOCS_DIR)/requirements.txt:
	cat > $@ <<EOF
		mkdocs==$(MKDOCS_DOCKER_VERSION)
	EOF

.PHONY: docs-serve
docs-serve: $(DOCS_DIR)/requirements.txt
	trap 'rc=$$?; trap - INT ERR EXIT; exec 3<&-;docker rm -f "$${MKDOCS_NAME}" 1> /dev/null 2>&1; exit $$rc;' INT ERR EXIT
	URL=http://127.0.0.1:9000
	MKDOCS_NAME="mkdocs-git-hangelog-$$(echo $RANDOM | md5sum | head -c 20;)"
	docker run \
		-d \
		--name "$${MKDOCS_NAME}" \
		-v $(MKFILE_DIR):/mkdocs:ro \
		-p 9000:9000 \
		-e "LIVE_RELOAD_SUPPORT=true" \
		-e "DOCS_DIRECTORY=/mkdocs" \
		-e "AUTO_UPDATE=true" \
		-e "UPDATE_INTERVAL=1" \
		-e "DEV_ADDR=0.0.0.0:9000" \
		polinux/mkdocs:$(MKDOCS_DOCKER_VERSION) > /dev/null 2>&1 &
	while ! grep -q "HTTP/1.1 200 OK" <<<"$${response:-}";do
			echo "Waiting for mkdocs server...."
			sleep 1
			if [[ "$$(docker inspect --format="{{.State.Running}}" $$MKDOCS_NAME)" == "true" ]];then
				exec 3<>/dev/tcp/0.0.0.0/9000 || true
				echo -en "GET / HTTP/1.1\r\nHost: 0.0.0.0\r\nConnection: close\r\n\r\n" >&3 || true
				response="$$(cat <&3 2> /dev/null || true)"
			else
				docker logs $$MKDOCS_NAME
				1>&2 echo "Error: mkdocs container stopped !"
				exit 1
			fi
	done
	echo "Ok. Mkdocs server is started"
	echo "Opening mkdocs website with default broser..."
	path=$$(command -v xdg-open || command -v gnome-open);
	if [[ -x $${BROWSER:-} ]];then
		"$$BROWSER" "$$URL";
	elif [[ -n "$$path" ]];then
		"$$path" "$$URL";
	else
		echo "Can't find browser";
	fi;
	read -p 'Press any key when finished'
	wait

#####
# Include footer
#####
d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))
