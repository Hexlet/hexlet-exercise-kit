# bitbucket_repo_downloader
Download all repositories from bitbucket account

## Install
```
poetry install
```

## Configure
1. Change paths to your hexlet-exerise-kit dir in the config.json.example
2. Rename this file to config.json

## Usage
### Downloading
If you want to download all repositories with courses, exercises and challenges, run:
```
poetry run python3 downloader.py
```
Existing repos will be unchanged

### Updating
If you want to pull updates from repositories to your machine, run:
```
poetry run python3 downloader.py --update
```
