CURRENT_USER=$(shell id -u):$(shell id -g)
DOWNLOADER_FLAG?=

SSH_KEY_PATH?=$(HOME)/.ssh/id_rsa

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
	docker run --rm -it --name hexlet_downloader \
		-u $(CURRENT_USER) \
		-v /etc/passwd:/etc/passwd:ro \
		-v $(SSH_KEY_PATH):/downloader/.ssh/id_rsa \
		-v $(CURDIR):/repos \
		--env-file ./bitbucket.config.env \
		docker.pkg.github.com/kirill-chertkov/bitbucket_repo_downloader/bitbucket_downloader:latest $(DOWNLOADER_FLAG)

rebase:
	make clone DOWNLOADER_FLAG=--update
