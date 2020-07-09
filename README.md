[![Hexlet chat](http://slack-ru.hexlet.io/badge.svg)](http://slack-ru.hexlet.io)

# hexlet-exercise-kit

This is a complete kit for teachers who want to create exercises on the Hexlet platform.

## Setup

Set in *bitbucket.config.env* your auth data for download repositories.

```sh
$ git clone https://github.com/Hexlet/hexlet-exercise-kit.git

$ cd hexlet-exercise-kit
$ make setup

$ make clone_repos
# or make clone SSH_KEY_PATH=/specific/path/to/your/private_bitbucket_ssh_key # what's need for clone repos 
```

For pulling into cloned repos:
```sh
$ make pull_repos
```
 

## New stuff

```sh
$ mkdir -p exercises/course-<name>/<lesson-name>_exercise
$ mkdir -p exercises/challenge-<course-name>/<name>_challenge
```

