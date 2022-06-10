ci-check:
	docker compose -f docker-compose.yml build
	docker compose -f docker-compose.yml up --abort-on-container-exit

compose-setup: compose-build compose-install

compose-build:
	docker compose build

compose-install:
	docker compose run --rm assignments make install

compose-bash:
	docker compose run --rm --service-ports assignments bash

compose-test:
	docker compose run --rm assignments make test

compose-lint:
	docker compose run --rm assignments make lint

compose:
	docker compose up

compose-down:
	docker compose down -v --remove-orphans
