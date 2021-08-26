# hexlet-exercise-kit

[![Hexlet chat](http://slack-ru.hexlet.io/badge.svg)](http://slack-ru.hexlet.io)

This is a complete kit for teachers who want to create exercises on the Hexlet platform.

## Setup

```sh
git clone https://gitlab.com/hexlethq/hexlet-exercise-kit.git

cd hexlet-exercise-kit
make setup
```

If you have access to clone Hexlet repositories:

* create a personal access token on this page: [https://gitlab.com/-/profile/personal_access_tokens](https://gitlab.com/-/profile/personal_access_tokens)
* add created token to *config.env* file

```sh
make clone

# if your .ssh catalog has specific path:
make clone SSH_KEYS_PATH=/specific/path/to/your/.ssh 
```

For pulling into cloned repos:

```sh
make rebase
```

## Run exercise

```sh
cd <path/to/exercise/catalog>
make build # build exercise container
make start # run exercise and listen port 80
make test # run tests
make lint-js # run linter
```

For frontend exercise after `make start` open [http://localhost:80](http://localhost:80) in your browser.

```sh
make stop # stopped container
```

## New stuff

```sh
mkdir -p exercises/course-<name>/<lesson-name>_exercise
mkdir -p exercises/challenge-<course-name>/<name>_challenge
```
