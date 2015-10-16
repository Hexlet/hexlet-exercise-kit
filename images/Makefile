# I :=

build:
	docker build -t hexlet/hexlet-$(L) $(L)

run:
	docker run -it --read-only hexlet/hexlet-$(L) /bin/bash

push:
	docker push hexlet/hexlet-$(L)

.PHONY: build run
