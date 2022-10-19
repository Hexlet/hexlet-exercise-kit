# hexlet-exercise-kit

[![Hexlet chat](http://slack-ru.hexlet.io/badge.svg)](http://slack-ru.hexlet.io)

This is a complete kit for teachers who want to create exercises on the Hexlet platform.

## Setup

```bash
git clone https://gitlab.hexlet.io/hexlethq/hexlet-exercise-kit.git

cd hexlet-exercise-kit
make setup
```

If you have access to clone Hexlet repositories:

* create a personal access token on this page: [https://gitlab.hexlet.io/-/profile/personal_access_tokens](https://gitlab.hexlet.io/-/profile/personal_access_tokens)
* add created token to *.env* file

```
GITLAB_API_PRIVATE_TOKEN=<token>
GITLAB_API_ENDPOINT=https://gitlab.hexlet.io/api/v4
PARALLEL=8
```

```bash
make clone

# if your .ssh catalog has specific path:
make clone SSH_KEYS_PATH=/specific/path/to/your/.ssh
```

For pulling into cloned repos:

```bash
make rebase
```

## Using hexlet linters

```bash
# install/update all hexlet linters
make update-hexlet-linters
# install/update one hexlet linter. For example, eslint
make update-hexlet-linter L=eslint
```

## Run exercise

```bash
cd <path/to/exercise/catalog>
make build # build exercise container
make start # run exercise and listen port 80
make test # run tests
make lint-js # run linter
make lint-hexlet-js # check exercise with linter, as in production
```

For frontend exercise after `make start` open [http://localhost:80](http://localhost:80) in your browser.

```bash
make stop # stopped container
```

## New stuff

```bash
mkdir -p exercises/ru/course-<name>/<lesson-name>_exercise
```
