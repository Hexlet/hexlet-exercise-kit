DOWNLOADER_IMAGE_NAME=hexlet/gitlab-downloader
SSH_KEYS_PATH?=$(HOME)/.ssh
UID := $(shell id -u)
GID := $(shell id -g)

setup: create-config pull build-downloader
	mkdir -p exercises
	mkdir -p courses
	mkdir -p projects
	mkdir -p programs
	mkdir -p boilerplates
	make -C import-documentation all
	npm ci

pull:
	docker pull hexlet/hexlet-python
	docker pull hexlet/hexlet-java
	docker pull hexlet/hexlet-javascript
	docker pull hexlet/hexlet-php

create-config:
	cp -n repo-downloader/.env.template .env || echo 'already exists'

build-downloader: create-config
	docker build -t $(DOWNLOADER_IMAGE_NAME):latest \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		./repo-downloader

clone: downloader-run

copy-from-cb:
	make -C code-basics-synchronizer

downloader-run:
	docker run -it --rm \
		--name hexlet-exercise-kit-repo-downloader \
		-v $(CURDIR):/home/tirion/project \
		-v /home/tirion/project/.git \
		-v $(SSH_KEYS_PATH):/home/tirion/.ssh \
		--env-file ./.env \
		--env FILTER \
		--env UPDATE \
		$(DOWNLOADER_IMAGE_NAME):latest $(C)

downloader-bash:
	make downloader-run C=bash

downloader-lint:
	docker run --rm \
		-v $(CURDIR):/home/tirion/project \
		$(DOWNLOADER_IMAGE_NAME):latest \
		make lint

clone-courses:
	make clone FILTER=courses

clone-exercises:
	make clone FILTER=exercises

clone-projects:
	make clone FILTER=projects

clone-boilerplates:
	make clone FILTER=boilerplates

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
	make update-hexlet-linter L=multi-language

create-localizer-config:
	cp -n content-localizer/.env.template content-localizer/.env || echo 'already exists'

build-localizer: create-localizer-config
	docker build -t hexlet/content-localizer \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		./content-localizer

spellcheck-courses:
	docker run -v ./courses:/content hexlet/languagetool-cli

.PHONY: clone
