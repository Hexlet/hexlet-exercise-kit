CURRENT_USER=$(shell id -u):$(shell id -g)
SSH_KEY_PATH?=$(HOME)/.ssh/id_rsa
UPDATE_FLAG?=

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

clone:
	docker run --rm -it --name hexlet/bitbucket-downloader \
		-u $(CURRENT_USER) \
		-v /etc/passwd:/etc/passwd:ro \
		-v $(SSH_KEY_PATH):/downloader/.ssh/id_rsa \
		-v $(CURDIR):/repos \
		--env-file ./bitbucket.config.env \
		docker.pkg.github.com/melodyn/bitbucket_repo_downloader/bitbucket_downloader:latest $(UPDATE_FLAG)

rebase:
	make clone UPDATE_FLAG=--update
