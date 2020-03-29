# bitbucket_repo_downloader
Download all repositories from the Bitbucket account

## Requirements
Docker.

## Install
1. `make build`
2. `make register`

## Configure
1. Create an environment variable `HEXLET_EXERCISE_KIT_DIR` with your path to Hexlet exercise kit directory.
2. Move `.hexdownloader` to the home directory and add bitbucket credentials into it. For password you shouldn't use your actual password! You should generate an application password instead. Just create one at your profile's settings page.

## Usage
`hexdownloader` — download all repositories with courses, exercises and challenges
`hexdownloader --update` — pull updates from repositories to your machine