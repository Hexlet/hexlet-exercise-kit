ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ci-check:
	docker compose -f docker-compose.yml build
	docker compose -f docker-compose.yml up --abort-on-container-exit

compose-build:
	docker compose build

compose-setup:
	docker compose run --rm project make setup

compose-install:
	docker compose run --rm project make install

compose-bash:
	docker compose run --rm --service-ports project bash

compose-test:
	docker compose run --rm project make test

compose-lint:
	docker compose run --rm project make lint

compose-check-current:
	docker compose run --rm project make check-current ASSIGNMENT=${ASSIGNMENT}

compose:
	docker compose up

compose-down:
	docker compose down -v --remove-orphans

presentation-export-pdf:
	npx slidev export

presentation-export-pdf-with-clicks:
	npx slidev export --with-clicks

presentation-export-png:
	npx slidev export --format png

presentation-export-png-with-clicks:
	npx slidev export --with-clicks --format png

presentation-build:
	npx slidev build

presentation:
	npx slidev --open

assignment-pdf:
	npx @marp-team/marp-cli --allow-local-files assignment_data/presentation.md --pdf

assignment-presentation:
	npx @marp-team/marp-cli -w assignment_data/presentation.md
	open presentation.html

run-translation:
	@mkdir -p .localize_data
	@docker run --rm -it \
		-v $(CURDIR):/root/source \
		-v $(CURDIR)/.localize_data/data:/root/data \
		-v $(CURDIR)/.localize_data/db:/root/db \
		-v $(CURDIR)/.localize_data/ts:/root/ts \
		-v $(CURDIR)/.localize_data/dist:/root/dist \
		--env-file ../../../content-localizer/.env \
		--env SRC_LANG=ru \
		--env DEST_LANG=en \
		--env SMARTCAT_PROJECT_ID=${PROJECT_ID} \
		hexlet/content-localizer $(ACTION)

translations-prepare:
	@make run-translation ACTION=prepare-to-translate

translations-send:
	@if [ -z "${PROJECT_ID}" ]; then echo "Please set PROJECT_ID=<smartcat-project-id>"; exit 1; fi
	@make run-translation ACTION=send-to-translate

translations-get:
	@if [ -z "${PROJECT_ID}" ]; then echo "Please set PROJECT_ID=<smartcat-project-id>"; exit 1; fi
	@make run-translation ACTION=get-translations

translations-write:
	@if [ -z "${COURSE_PATH}" ]; then echo "Please set COURSE_PATH=<full-path-to-result-course>"; exit 1; fi
	@mkdir -p ${COURSE_PATH}
	@make run-translation ACTION=build-translations
	@cp -r .localize_data/dist/. ${COURSE_PATH}
	@rm -rf .localize_data/dist/*
	@echo "------------------------------------------"
	@echo "Traslated files have copied to course path"
	@echo "------------------------------------------"
	@echo ${COURSE_PATH}

markdown-lint:
	npx markdownlint -c ../../../.markdownlint.json ${CURDIR}

lint:
	npx eslint -c ${ROOT_DIR}/eslint.config.js ${CURDIR}

markdown-lint-fix:
	npx markdownlint -f -c ../../../.markdownlint.json ${CURDIR}

lint-fix:
	npx eslint -c ${ROOT_DIR}/eslint.config.js ${CURDIR} --fix

spellcheck:
	docker run --rm -v ./:/content ghcr.io/hexlet/languagetool-cli node ./bin/run.js check /content/**/*.md

print-course-table:
	@bash $(ROOT_DIR)scripts/print-course-table
