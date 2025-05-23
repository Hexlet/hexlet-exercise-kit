DOWNLOADER_HOME=/home/tirion
SSH_KEYS_PATH?=$(HOME)/.ssh
UID := $(shell id -u)
GID := $(shell id -g)
HEXLETHQ=hexlethq
LOCALE ?=
REGISTRY := cr.yandex/crpa5i79t7oiqnj0ap8g

setup: create-config prepare-dirs # pull
	# make -C import-documentation all
	# npm ci

prepare-dirs:
	mkdir -p exercises
	mkdir -p courses
	mkdir -p projects
	mkdir -p programs
	mkdir -p boilerplates
	mkdir -p help
	# ln -s $(CURDIR) $(CURDIR)/hexlethq

pull:
	docker pull $(REGISTRY)/hexlet-python
	docker pull $(REGISTRY)/hexlet-java
	docker pull $(REGISTRY)/hexlet-javascript
	docker pull $(REGISTRY)/hexlet-php
	docker pull $(REGISTRY)/hexlet-go
	docker pull ghcr.io/hexlet/languagetool-cli

create-config:
	touch gitlab.token

copy-from-cb:
	make -C packages/code-basics-synchronizer

downloader-run:
		ghorg clone --config .ghorg.conf.yaml --path $(CURDIR) $(HEXLETHQ)/$(FILTER)$(if $(LOCALE),/$(LOCALE))

clone: clone-courses clone-exercises clone-projects clone-boilerplates clone-help

clone-help:
	git clone git@github.com:Hexlet/hexlet.github.io.git help

clone-courses:
	make downloader-run FILTER=courses

clone-exercises:
	make downloader-run FILTER=exercises

clone-projects:
	make downloader-run FILTER=projects

clone-boilerplates:
	make downloader-run FILTER=boilerplates

update-hexlet-linter:
	docker pull $(REGISTRY)/common-${L}
	docker volume rm -f hexlet-linter-${L}
	docker run --rm -v hexlet-linter-${L}:/linter $(REGISTRY)/common-${L} echo > /dev/null

update-hexlet-linters:
	make update-hexlet-linter L=eslint
	make update-hexlet-linter L=python-flake8
	make update-hexlet-linter L=phpcs
	make update-hexlet-linter L=checkstyle
	make update-hexlet-linter L=sqlint
	make update-hexlet-linter L=rubocop
	make update-hexlet-linter L=multi-language
	make update-hexlet-linter=golangci-lint

create-localizer-config:
	cp -n content-localizer/.env.template content-localizer/.env || echo 'already exists'

build-localizer: create-localizer-config
	docker build -t hexlet/content-localizer \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		./content-localizer

macos-prepare:
	brew install gabrie30/utils/ghorg
