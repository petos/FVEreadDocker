VERSION ?= latest
.DEFAULT_GOAL := build
IMAGE ?= fveread:$(VERSION)

DOCKER_RUN_OPTS ?= --volume ./conf:/opt/fve/config -v ./conf/FVErc:/etc/FVErc -v ./data/:/opt/fve/data -p8000:80 -p 8001:443
#-v ./conf/lighttpd.conf:/etc/lighttpd/lighttpd.conf

UID ?= $(shell id -u)
GID ?= $(shell id -g)


build: Dockerfile
	docker buildx build  --no-cache . -t $(IMAGE)

debug:
	docker run $(DOCKER_RUN_OPTS) -it -u $(UID):$(GID) $(IMAGE)

run:
	$(eval PWD=$(shell pwd))
	docker run $(DOCKER_RUN_OPTS) -u $(UID):$(GID) $(IMAGE)

# Removes all the running containers
# TODO: this should only target $IMAGE instances
cleanup:
	$(eval CONTAINERS=$(shell docker container ls -aq))
	docker container rm $(CONTAINERS)

cb:
	-make cleanup
	make build

cbd:
	make cb
	make debug

publish:
	@VERSION=$$(date +%Y%m%d%H); \
	for TAG in $$VERSION latest; do \
		echo ">>> Building and pushing tag $$TAG..."; \
		IMAGE=fveread:$$TAG; \
		make cleanup; \
		make build VERSION=$$TAG; \
		docker tag $$IMAGE petoss/$$IMAGE; \
		docker push petoss/$$IMAGE; \
	done
