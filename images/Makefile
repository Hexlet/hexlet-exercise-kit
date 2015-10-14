# I :=

build:
	docker build -t hexlet/hexlet-$(I) $(I)

run:
	docker run -it --read-only hexlet/hexlet-$(I) /bin/bash

push:
	docker push hexlet/hexlet-$(I)

.PHONY: build run
