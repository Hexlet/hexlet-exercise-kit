DOWNLOADER_HOME=/home/tirion
SSH_KEYS_PATH?=$(HOME)/.ssh
UID := $(shell id -u)
GID := $(shell id -g)
HEXLETHQ=hexlethq
LOCALE ?=

setup: create-config build-downloader pull prepare-dirs
	make -C import-documentation all
	npm ci

prepare-dirs:
	mkdir -p exercises
	mkdir -p courses
	mkdir -p projects
	mkdir -p programs
	mkdir -p boilerplates

pull:
	docker pull hexlet/hexlet-python
	docker pull hexlet/hexlet-java
	docker pull hexlet/hexlet-javascript
	docker pull hexlet/hexlet-php
	docker pull hexlet/languagetool-cli

create-config:
	touch gitlab.token

build-downloader:
	./scripts/download-downloader

copy-from-cb:
	make -C code-basics-synchronizer

downloader-run:
		./ghorg clone --config ghorg.conf.yaml $(HEXLETHQ)/$(FILTER)$(if $(LOCALE),/$(LOCALE))

clone: clone-courses clone-exercises clone-projects clone-boilerplates

clone-courses:
	make downloader-run FILTER=courses

clone-exercises:
	make downloader-run FILTER=exercises

clone-projects:
	make downloader-run FILTER=projects

clone-boilerplates:
	make downloader-run FILTER=boilerplates

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
