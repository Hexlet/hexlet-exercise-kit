ci-check:
	docker compose -f docker-compose.yml build
	docker compose -f docker-compose.yml up --abort-on-container-exit

compose-setup: compose-build compose-install

compose-build:
	docker compose build

compose-install:
	docker compose run --rm course make setup

compose-bash:
	docker compose run --rm --service-ports course bash

compose-test:
	docker compose run --rm course make test

compose-lint:
	docker compose run --rm course make lint

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
