VERSION ?= latest
.DEFAULT_GOAL := build
IMAGE ?= fveread:$(VERSION)

DOCKER_RUN_OPTS ?= --volume ./conf:/opt/fve/config
# -p8000:80 -p 8001:443
# -v ./conf/lighttpd.conf:/etc/lighttpd/lighttpd.conf

UID ?= $(shell id -u)
GID ?= $(shell id -g)


build: 
#	rm -fr ./scripts/*
#	cp -r ../pyFVE/FVctl.py ./scripts/FVctl.py
#	python -m py_compile ./scripts/*.py
	docker buildx build  --no-cache . -t $(IMAGE)

debug:
	docker run $(DOCKER_RUN_OPTS) -it -u $(UID):$(GID) $(IMAGE)

run:
	docker run $(DOCKER_RUN_OPTS) -d -u $(UID):$(GID) $(IMAGE)

# Removes all the running containers
# TODO: this should only target $IMAGE instances
cleanup:
	$(eval CONTAINERS=$(shell docker container ls -aq))
	docker container rm $(CONTAINERS)
deepclean:
	docker system prune --all --force

cb:
	-make cleanup
	make build

cbd:
	make cb
	make debug

publish:
	@VERSION=$$(date +%Y%m%d%H%M); \
	for TAG in $$VERSION latest; do \
		echo ">>> Building and pushing tag $$TAG..."; \
		IMAGE=fveread:$$TAG; \
		make cleanup; \
		make build VERSION=$$TAG; \
		docker tag $$IMAGE petoss/$$IMAGE; \
		docker push petoss/$$IMAGE; \
	done
