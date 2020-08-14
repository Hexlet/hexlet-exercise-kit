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

config:
	echo "BITBUCKET_USERNAME=$(NICKNAME)\n\
	BITBUCKET_APP_PASSWORD=$(APPPASS)\n\
	BITBUCKET_TEAM_NAME=hexlet\n\
	BITBUCKET_API_URL=https://api.bitbucket.org/2.0/repositories/" > bitbucket.config.env

clone:
ifneq ($(shell test -f bitbucket.config.env && echo true), true)
	@ echo "Please, run 'make config NICKNAME=username APPPASS=paSsw0rd', see README for details" >&2; exit 1;
else
	make build_downloader
	docker run --rm -it --name hexlet_downloader \
		-v $(SSH_KEYS_PATH):/home/$(UNAME)/.ssh \
		-v $(CURDIR):/repos \
		--env-file ./bitbucket.config.env \
		$(DOWNLOADER_IMAGE_NAME):latest $(DOWNLOADER_FLAG)
endif

rebase:
	make clone DOWNLOADER_FLAG=--update
