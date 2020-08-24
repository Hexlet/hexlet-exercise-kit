DOWNLOADER_IMAGE_NAME=hexlet/bitbucket_downloader
SSH_KEYS_PATH?=$(HOME)/.ssh
DOWNLOADER_FLAG?=
UNAME=$(shell whoami)
UID=$(shell id -u)

setup: pull build-downloader
	mkdir exercises
	mkdir courses
	mkdir projects
	make -C import-documentation all

pull:
	docker pull hexlet/hexlet-python
	docker pull hexlet/hexlet-java
	docker pull hexlet/hexlet-javascript
	docker pull hexlet/hexlet-php

create-config:
	cp -n bitbucket.config.env.example bitbucket.config.env || true

build-downloader: create-config
	docker build -t $(DOWNLOADER_IMAGE_NAME):latest \
		--build-arg UNAME=$(UNAME) \
		--build-arg UID=$(UID) \
		./repo_downloader || true

clone: build-downloader
	docker run --rm -it --name hexlet_downloader \
		-v $(SSH_KEYS_PATH):/home/$(UNAME)/.ssh \
		-v $(CURDIR):/repos \
		--env-file ./bitbucket.config.env \
		$(DOWNLOADER_IMAGE_NAME):latest $(DOWNLOADER_FLAG)

rebase:
	make clone DOWNLOADER_FLAG=--update

.PHONY: clone
