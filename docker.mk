USER := tirion
HOME := /nonexistent
ID := $(shell basename $(CURDIR))
CONTAINER_ID := $(addsuffix _container, $(ID))
CONTAINER_ID_INTERNAL := $(addsuffix _container_internal, $(ID))
IMAGE_ID := $(addsuffix _image, $(ID))
CS = $(shell docker ps -a -q)
ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

docs-js:
	docker exec -it $(CONTAINER_ID) /bin/bash -c 'sudo -E PATH=$$PATH HOME=$(HOME) -u $(USER) rm -rf docs && mkdir -p docs && /import-documentation/dist/bin/import-documentation.js . -o docs'

test:
ifeq ([], $(shell docker inspect $(CONTAINER_ID) 2> /dev/null))
	@ echo "Please, run 'make start' before 'make test'" >&2; exit 1;
else
	docker exec -it $(CONTAINER_ID) /bin/bash -c 'sudo -E PATH=$$PATH HOME=$(HOME) -u $(USER) make test -C /usr/src/app'
endif

prepare:
ifeq ([], $(shell docker inspect $(CONTAINER_ID) 2> /dev/null))
	@ echo "Please, run 'make start' before 'make test'" >&2; exit 1;
else
	docker exec -it $(CONTAINER_ID) make prepare -C /usr/src/app
endif

build: stop
	docker build -t $(IMAGE_ID) .

bash:
	docker run --read-only -it -v /tmp \
	  -v $(CURDIR)/exercise_internal:/exercise_internal \
	  -v $(CURDIR)/exercise/:/usr/src/app $(IMAGE_ID) \
	  /bin/bash -c 'sudo -E PATH=$$PATH HOME=$(HOME) -u $(USER) /bin/bash --norc'

attach:
	docker exec -it $(CONTAINER_ID) /bin/bash -c 'sudo -E PATH=$$PATH HOME=$(HOME) -u $(USER) /bin/bash --norc'

logs:
	docker logs -f $(CONTAINER_ID)

start: stop
ifeq ([], $(shell docker inspect $(IMAGE_ID) 2> /dev/null))
	@ echo "Please, run 'make build' before 'make start'" >&2; exit 1;
else
	docker run -d -t --read-only --rm \
		--label hexlet-exercise \
		-v $(ROOT_DIR)import-documentation:/import-documentation \
		-v /tmp \
		-v $(CURDIR)/services.conf:/etc/supervisor/conf.d/services.conf \
		-v $(CURDIR)/exercise/:/usr/src/app \
		-v $(CURDIR)/exercise_internal:/exercise_internal \
		-p 8000:8000 -p 80:8080 --name $(CONTAINER_ID) $(IMAGE_ID)
endif

stop:
	docker stop `docker ps -a -q --filter label=hexlet-exercise` || true

diff:
	@ docker diff $(CS)

# start_internal: stop
# ifeq ([], $(shell docker inspect $(IMAGE_ID) 2> /dev/null))
# 	@ echo "Please, run 'make build'" >&2; exit 1;
# else
# 	docker run -d -t -v $(CURDIR)/exercise_internal:/exercise_internal --name $(CONTAINER_ID_INTERNAL) $(IMAGE_ID)
# endif

test_internal:
ifeq ([], $(shell docker inspect $(CONTAINER_ID) 2> /dev/null))
	@ echo "Please, run 'make start_internal'" >&2; exit 1;
else
	# docker exec $(CONTAINER_ID) make test -C /exercise_internal
	docker exec $(CONTAINER_ID) /bin/bash -c 'sudo -E PATH=$$PATH HOME=$(HOME) -u $(USER) make test -C /exercise_internal'
endif


lint-js:
	npx eslint .

all: build start test

.PHONY: test build bash run stop start
