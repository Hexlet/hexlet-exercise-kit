DOWNLOADER_IMAGE_NAME=hexlet/bitbucket_downloader
SSH_KEYS_PATH?=$(HOME)/.ssh
DOWNLOADER_FLAG?=
UNAME=$(shell whoami)
UID=$(shell id -u)

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
		--build-arg UNAME=$(UNAME) \
		--build-arg UID=$(UID) \
		./repo_downloader || true

bitbucket.config.env:
	echo "BITBUCKET_USERNAME=$(NICKNAME)\n\
	BITBUCKET_APP_PASSWORD=$(APPPASS)\n\
	BITBUCKET_TEAM_NAME=hexlet\n\
	BITBUCKET_API_URL=https://api.bitbucket.org/2.0/repositories/" > bitbucket.config.env

clone: bitbucket.config.env build_downloader
	docker run --rm -it --name hexlet_downloader \
		-v $(SSH_KEYS_PATH):/home/$(UNAME)/.ssh \
		-v $(CURDIR):/repos \
		--env-file ./bitbucket.config.env \
		$(DOWNLOADER_IMAGE_NAME):latest $(DOWNLOADER_FLAG)

rebase:
	make clone DOWNLOADER_FLAG=--update

.PHONY: clone
