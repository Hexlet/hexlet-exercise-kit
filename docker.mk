ID := $(shell basename $(CURDIR))
CONTAINER_ID := $(addsuffix _container, $(ID))
CONTAINER_ID_INTERNAL := $(addsuffix _container_internal, $(ID))
IMAGE_ID := $(addsuffix _image, $(ID))
CS = $(shell docker ps -a -q)

test:
ifeq ([], $(shell docker inspect $(CONTAINER_ID) 2> /dev/null))
	@ echo "Please, run 'make start' before 'make test'" >&2; exit 1;
else
	docker exec -it $(CONTAINER_ID) make test -C /usr/src/app
endif

build: stop
	docker build -t $(IMAGE_ID) .

bash:
	docker run -it --read-only -v $(CURDIR)/exercise/:/usr/src/app $(IMAGE_ID) /bin/bash -l

attach:
	docker exec -it $(CONTAINER_ID) /bin/bash -l

start: stop
ifeq ([], $(shell docker inspect $(IMAGE_ID) 2> /dev/null))
	@ echo "Please, run 'make build' before 'make start'" >&2; exit 1;
else
	docker run --read-only -d -t -v $(CURDIR)/exercise/:/usr/src/app -v $(CURDIR)/exercise_internal:/exercise_internal \
		-p 8000:8000 -p 8080:8080 -u user --name $(CONTAINER_ID) $(IMAGE_ID)
endif

# stop:
# 	@ docker stop $(CS) > /dev/null 2>&1; echo ""

stop:
	@ docker rm -f $(CS) > /dev/null 2>&1; echo ""

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
	docker exec $(CONTAINER_ID) make test -C /exercise_internal
endif

.PHONY: test build bash run stop
