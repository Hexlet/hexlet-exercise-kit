#!/bin/sh
docker run --rm \
-u $(id -u):$(id -g) \
-v "/etc/passwd:/etc/passwd:ro" \
-v "$HOME/.hexdownloader:/downloader/.hexdownloader:ro" \
-v "$HOME:$HOME" \
-v "$HOME/.ssh:/.ssh:ro" \
-e "HEXLET_EXERCISE_KIT_DIR=$HEXLET_EXERCISE_KIT_DIR" \
hexdownloader:latest $1