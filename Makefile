DOWNLOADER_IMAGE_NAME=hexlet/gitlab-downloader
SSH_KEYS_PATH?=$(HOME)/.ssh
UID := $(shell id -u)
GID := $(shell id -g)
HEXLETHQ=hexlethq

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
	cp -n .env.example .env || echo 'already exists'

build-downloader: create-config
	docker build -t $(DOWNLOADER_IMAGE_NAME):latest \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		./repo-downloader

copy-from-cb:
	make -C code-basics-synchronizer

downloader-run:
	docker run -it --rm \
		--env-file ./.env \
		-v $(SSH_KEYS_PATH):/home/.ssh \
		-v $(CURDIR):/home/data/hexlethq \
		-v $(CURDIR)/repo-downloader/config:/config \
		$(DOWNLOADER_IMAGE_NAME) \
		ghorg clone $(FILTER)

clone: clone-courses clone-exercises clone-projects clone-boilerplates

clone-courses:
	make downloader-run FILTER=$(HEXLETHQ)/courses

clone-exercises:
	make downloader-run FILTER=$(HEXLETHQ)/exercises

clone-projects:
	make downloader-run FILTER=$(HEXLETHQ)/projects

clone-boilerplates:
	make downloader-run FILTER=$(HEXLETHQ)/boilerplates

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
