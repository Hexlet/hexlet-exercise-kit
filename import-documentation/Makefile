all: install build

install:
	npm install
	npx flow-typed install

build:
	rm -rf dist
	npm run build

test:
	npm test

lint:
	npx eslint .

publish:
	npm publish

.PHONY: test
