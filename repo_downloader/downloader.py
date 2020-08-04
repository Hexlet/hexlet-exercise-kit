#! /usr/bin/env python3

import base64
import logging
import math
import os
import sys

import git
import requests


if not os.path.exists('/repos/download.log'):
    with open('/repos/download.log', 'w'):
        pass


logging.basicConfig(
    filename='/repos/download.log',
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s',
)

logger = logging.getLogger()
sys.tracebacklimit = 0


def make_request(url, creds, pagelen=1, page=1):
    headers = {
        'authorization': 'Basic {}'.format(creds),
    }
    querystring = {
        "pagelen": pagelen,
        "page": page,
    }
    response = requests.get(url, headers=headers, params=querystring)
    if response.status_code != 200:
        raise ConnectionError("Check your credentials!\n")
    return response


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
            try:
                repo = git.Repo.clone_from(
                    repo['link'],
                    path,
                )
                print(f'Cloned from {repo.remotes.origin.url} to {repo.working_dir}')
                return True
            except Exception as error:
                logger.error(error)
                return False
        else:
            logger.warning(f'{path} already exists. Repository was skipped')
            return True
    else:
        logger.warning(f"{repo['link']} is not valid type of repo")
        return True


def pull(repo, paths):
    if repo['type']:
        parent_dir = paths[repo['type']]
        path = '{}/{}/{}'.format(parent_dir, repo['dir'], repo['name'])
        if os.path.exists(path):
            try:
                local_repo = git.Repo(path)
            except Exception as error:
                logger.error(f"Couldn't create a repo object in {path}\n{error}")
                return False

            changed_files = local_repo.index.diff(None)
            if changed_files:
                logger.warning(f'{path} has changes. This repo was not updated')
                return False

            if not local_repo.branches:
                logger.warning(f'{path} has no branches. This repo was skipped')
                return False

            branch_name = local_repo.active_branch.name
            if 'master' not in branch_name:
                logger.warning(f'{path} is not in master branch. This repo was not updated')
                return False

            print(f"Updating {repo['name']}")
            try:
                local_repo.remotes.origin.pull('--rebase')
                print(f'{repo["name"]} was updated')
                return True
            except Exception as error:
                logger.error(f"Couldn\'t update {path}\n{error}")
                return False
    else:
        logger.warning(f"{repo['link']} is not valid type of repo")
        return True


def main(params=None):
    url = '{}{}'.format(os.environ['BITBUCKET_API_URL'], os.environ['BITBUCKET_TEAM_NAME'])
    cur_dir = '/repos'
    cred_bytes = ('{}:{}'.format(
        os.environ['BITBUCKET_USERNAME'],
        os.environ['BITBUCKET_APP_PASSWORD'],
    ).encode('utf-8'))
    credentials = str(base64.b64encode(cred_bytes), 'utf-8')
    paths = {
        'exercise': '{}/courses'.format(cur_dir),
        'course': cur_dir,
        'challenge': '{}/challenges'.format(cur_dir),
    }

    if '--update' in params:
        for repo in get_repos_data(url, credentials):
            if not pull(repo, paths):
                print(f'An error occured with {repo["name"]}. See the log file for more details')

    else:
        for repo in get_repos_data(url, credentials):
            if not clone(repo, paths):
                print("An error occured. See the log file for more details")
                break


if __name__ == '__main__':
    try:
        options = sys.argv[1]
    except IndexError:
        options = ''
    main(params=options)
