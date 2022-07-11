DOWNLOADER_IMAGE_NAME=hexlet/gitlab-downloader
SSH_KEYS_PATH?=$(HOME)/.ssh
UID := $(shell id -u)
GID := $(shell id -g)

setup: pull build-downloader install-linters
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

clone: build-downloader
	docker run --rm -it \
		-v $(CURDIR)/repo-downloader:/home/tirion/app \
		-v $(CURDIR):/home/tirion/repos \
		-v $(HOME)/.ssh:/home/tirion/.ssh \
		--env-file ./.env \
		--env UPDATE=$(UPDATE) \
		$(DOWNLOADER_IMAGE_NAME):latest

# TODO: implement it
clone-courses:
clone-exercises:
clone-projects:

rebase:
	make clone UPDATE=true

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
