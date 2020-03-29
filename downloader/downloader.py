#! /usr/bin/env python3

import base64
import json
import math
import os
import sys
import time

import requests

import git


def make_request(url, creds, pagelen=1, page=1):
    headers = {
        'authorization': 'Basic {}'.format(creds),
    }
    querystring = {
        "pagelen": pagelen,
        "page": page,
    }
    return requests.get(url, headers=headers, params=querystring)


def get_repos_quantity(url, creds):
    return make_request(url, creds).json()['size']


def get_repos_data(url, creds):
    pagesize = 100
    pages = math.ceil(get_repos_quantity(url, creds) / pagesize)

    def get_type(name):
        if 'exercise' in name:
            return 'exercise'
        if 'challenge' in name:
            return 'challenge'
        if 'course' in name:
            return 'course'
        return ''

    repos = []

    for page in range(1, pages + 1):
        repos_info = make_request(url, creds, pagesize, page).json()['values']
        for repo in repos_info:
            dir_name = repo['project']['name']  # parent dir
            repo_name = repo['name']
            repo_type = get_type(repo_name)
            clone_links = repo['links']['clone']
            ssh_link = list(filter(
                lambda link: link['name'] == 'ssh', clone_links))[0]['href']

            repos.append({
                'dir': dir_name,
                'name': repo_name,
                'type': repo_type,
                'link': ssh_link,
            })

    return repos


def clone(repo, paths):
    if repo['type']:
        parent_dir = paths[repo['type']]
        path = '{}/{}/{}'.format(parent_dir, repo['dir'], repo['name'])
        if not os.path.exists(path):
            os.makedirs(path, exist_ok=True)
            print('Cloning {}'.format(repo['name']))
            git.Repo.clone_from(
                repo['link'],
                path,
                env={
                    'GIT_SSH_COMMAND': 'ssh -o StrictHostKeyChecking=no',
                    'GIT_SSH_COMMAND': 'ssh -o UserKnownHostsFile=/dev/null',
                    'GIT_SSH_COMMAND': 'ssh -i /.ssh/id_rsa',
                },
            )
            print('Done')
            return time.sleep(1)
        # print('Already exists')


def pull(repo, paths):
    if repo['type']:
        parent_dir = paths[repo['type']]
        path = '{}/{}/{}'.format(parent_dir, repo['dir'], repo['name'])
        if os.path.exists(path):
            local_repo = git.Repo(path)
            changed_files = local_repo.index.diff(None)
            if changed_files:
                return '{} — has changes'.format(path)

            print('Pulling {}'.format(repo['name']))
            try:
                local_repo.remotes.origin.pull('--rebase')
                print('Done')
            except Exception:
                return '{} — failed'.format(path)


def main(config, params=None):
    url = '{}{}'.format(config['api_url'], config['team_name'])
    cred_bytes = ('{}:{}'.format(
        config['username'],
        config['password'],
    ).encode('utf-8'))
    credentials = str(base64.b64encode(cred_bytes), 'utf-8')
    paths = {
        'exercise': '{}courses'.format(os.environ['HEXLET_EXERCISE_KIT_DIR']),
        'course': os.environ['HEXLET_EXERCISE_KIT_DIR'],
        'challenge': '{}challenges'.format(
            os.environ['HEXLET_EXERCISE_KIT_DIR'],
        ),
    }

    if '--update' in params:
        not_updated = []
        for repo in get_repos_data(url, credentials):
            # TODO: fixme
            result = pull(repo, paths)
            not_updated.append(result)
        print(
            'There is the list of not updated repositories:\n{}'.format(
                '\n'.join(list(filter(None, not_updated))),
            ),
        )
    else:
        for repo in get_repos_data(url, credentials):
            clone(repo, paths)


if __name__ == '__main__':
    try:
        options = sys.argv[1]
    except IndexError:
        options = ''
    with open('.hexdownloader') as config:
        main(json.load(config), params=options)
