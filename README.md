[![Hexlet chat](http://slack-ru.hexlet.io/badge.svg)](http://slack-ru.hexlet.io)

# hexlet-exercise-kit

This is a complete kit for teachers who want to create exercises on the Hexlet platform.

## Setup

```sh
$ git clone https://github.com/Hexlet/hexlet-exercise-kit.git

$ cd hexlet-exercise-kit
$ make setup
```


If your has access for a clone Hexlet repositories:
* create app password on this page: https://bitbucket.org/account/settings/app-passwords/ 
  in needed for access to bitbucket API
* use bitbucket username and app password for create config file

```sh
$ make bitbucket.config.env NICKNAME=username APPPASS=paSsw0rd
$ make clone

# if you .ssh catalog has specific path:
$ make clone SSH_KEYS_PATH=/specific/path/to/your/.ssh 
```

For pulling into cloned repos:
```sh
$ make rebase
```


## New stuff

```sh
$ mkdir -p exercises/course-<name>/<lesson-name>_exercise
$ mkdir -p exercises/challenge-<course-name>/<name>_challenge
```

