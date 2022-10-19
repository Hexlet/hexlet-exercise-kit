DOWNLOADER_IMAGE_NAME=hexlet/gitlab-downloader
SSH_KEYS_PATH?=$(HOME)/.ssh
UID := $(shell id -u)
GID := $(shell id -g)
FILTER?=all

setup: create-config pull build-downloader
	mkdir -p exercises
	mkdir -p courses
	mkdir -p projects
	mkdir -p programs
	make -C import-documentation all
	npm ci

pull:
	docker pull hexlet/hexlet-python
	docker pull hexlet/hexlet-java
	docker pull hexlet/hexlet-javascript
	docker pull hexlet/hexlet-php

create-config:
	cp -n repo-downloader/.env.template .env

build-downloader: create-config
	docker build -t $(DOWNLOADER_IMAGE_NAME):latest \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		./repo-downloader

clone: build-downloader downloader-run

downloader-run:
	docker run --rm -it \
		--name hexlet-exercise-kit-repo-downloader \
		-v $(CURDIR)/repo-downloader:/home/tirion/app \
		-v $(CURDIR):/home/tirion/repos \
		-v $(SSH_KEYS_PATH):/home/tirion/.ssh \
		--env-file ./.env \
		--env FILTER=$(FILTER) \
		--env UPDATE=$(UPDATE) \
		$(DOWNLOADER_IMAGE_NAME):latest \
		$(C)

downloader-bash:
	make downloader-run C=bash

downloader-lint:
	make downloader-run C='make lint'

# TODO: implement it
clone-courses:
	make clone FILTER=courses

clone-exercises:
	make clone FILTER=exercises

clone-projects:
	make clone FILTER=projects

rebase:
	make clone UPDATE=true

update-hexlet-linter:
	docker pull hexlet/common-${L}
	docker volume rm -f hexlet-linter-${L}
	docker run --rm -v hexlet-linter-${L}:/linter hexlet/common-${L} echo > /dev/null

update-hexlet-linters:
	make update-hexlet-linter L=eslint
	make update-hexlet-linter L=python-flake8
	make update-hexlet-linter L=phpcs
	make update-hexlet-linter L=checkstyle
	make update-hexlet-linter L=sqlint
	make update-hexlet-linter L=rubocop

.PHONY: clone
