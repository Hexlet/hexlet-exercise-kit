DOWNLOADER_IMAGE_NAME=hexlet/bitbucket_downloader
CURRENT_USER=$(shell id -u):$(shell id -g)
SSH_KEYS_PATH?=$(HOME)/.ssh
DOWNLOADER_FLAG?=

setup: pull
	mkdir exercises
	mkdir courses
	mkdir projects
	make -C import-documentation all

pull:
	docker pull hexlet/hexlet-python
	docker pull hexlet/hexlet-java
	docker pull hexlet/hexlet-javascript
	docker pull hexlet/hexlet-php

build_downloader:
	docker build -t $(DOWNLOADER_IMAGE_NAME):latest \
		--build-arg UNAME=$(USERNAME) \
		--build-arg UID=$(shell id -u) \
		./repo_downloader || true

clone: build_downloader
	docker run --rm -it --name hexlet_downloader \
		-v $(SSH_KEYS_PATH):$(SSH_KEYS_PATH) \
		-v $(CURDIR):/repos \
		--env-file ./bitbucket.config.env \
		$(DOWNLOADER_IMAGE_NAME):latest $(DOWNLOADER_FLAG)

rebase: build_downloader
	make clone DOWNLOADER_FLAG=--update
