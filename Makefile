VERSION ?= latest
.DEFAULT_GOAL := build
IMAGE ?= fveread:$(VERSION)

DOCKER_RUN_OPTS ?= --volume ./conf:/opt/fve/config

UID ?= $(shell id -u)
GID ?= $(shell id -g)


build: 
	make updatelocalfiles
	docker buildx build  --no-cache . -t $(IMAGE)

publishbuild: 
	make updatelocalfiles
	docker buildx build --build-arg PUBLISH=true --no-cache . -t $(IMAGE)

debug:
	docker run $(DOCKER_RUN_OPTS) -it -u $(UID):$(GID) $(IMAGE)

bash:
	docker run $(DOCKER_RUN_OPTS) -it -u $(UID):$(GID) --entrypoint /bin/bash $(IMAGE) 

run:
	docker run $(DOCKER_RUN_OPTS) -d -u $(UID):$(GID) $(IMAGE)

# Removes all the running containers
# TODO: this should only target $IMAGE instances
cleanup:
	$(eval CONTAINERS=$(shell docker container ls -aq))
	docker container rm $(CONTAINERS)

deepclean:
	docker system prune --all --force

updatelocalfiles:
	rm -fr ./scripts/*
	cp -r ../pyFVE/FVctl.py ./scripts/FVctl.py
	python -m py_compile ./scripts/*.py

cb:
	make cleanup
	make build

cbd:
	make cb
	make debug

publish:
	@VERSION=$$(date +%Y-%m-%d); \
	for TAG in $$VERSION latest; do \
		echo ">>> Building and pushing tag $$TAG..."; \
		IMAGE=fveread:$$TAG; \
		make cleanup; \
		make publishbuild VERSION=$$TAG; \
		docker tag $$IMAGE petoss/$$IMAGE; \
		docker push petoss/$$IMAGE; \
	done
