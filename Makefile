DOWNLOADER_IMAGE_NAME=hexlet/gitlab_downloader
SSH_KEYS_PATH?=$(HOME)/.ssh
DOWNLOADER_FLAG?=
UNAME=$(shell whoami)
UID=$(shell id -u)

setup: pull build-downloader install-linters
	mkdir -p exercises
	mkdir -p courses
	mkdir -p projects
	mkdir -p programs
	make -C import-documentation all

pull:
	docker pull hexlet/hexlet-python
	docker pull hexlet/hexlet-java
	docker pull hexlet/hexlet-javascript
	docker pull hexlet/hexlet-php

create-config:
	cp -n config.env.example config.env || true

build-downloader: create-config
	docker build -t $(DOWNLOADER_IMAGE_NAME):latest \
		--build-arg UNAME=$(UNAME) \
		--build-arg UID=$(UID) \
		./repo_downloader || true

clone: build-downloader
	docker run --rm -it --name hexlet_downloader \
		-v $(SSH_KEYS_PATH):/home/$(UNAME)/.ssh \
		-v $(CURDIR):/repos \
		--env-file ./config.env \
		$(DOWNLOADER_IMAGE_NAME):latest $(DOWNLOADER_FLAG)

rebase:
	make clone DOWNLOADER_FLAG=--update

install-linters:
	npm i eslint
	npm i eslint-config-airbnb
	npm i eslint-plugin-react
	npm i babel-eslint
	npm i eslint-plugin-jsx-a11y
	npm i eslint-plugin-jest
	npm i eslint-plugin-import
	npm i eslint-plugin-testing-library
	npm i eslint-plugin-jest-dom
	npm i jest
	npm i react
	npm i prettier-eslint

.PHONY: clone
