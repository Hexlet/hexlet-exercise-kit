#! /usr/bin/env python3

import logging
import os
import sys

import git
import gitlab


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

def get_repos_data(url, token):
    gl = gitlab.Gitlab(url, private_token=token)
    repos = []

    # filter not Hexlet projects
    hexlet_projects = filter(
        lambda project: 'https://gitlab.com/hexlethq' in project.web_url,
        gl.projects.list(all=True, visibility='private', simple=True),
    )

    for project in hexlet_projects:
        # filter courses outside the en and ru directories. Now it's only course for tutors
        if ' en ' in project.name_with_namespace or ' ru ' in project.name_with_namespace:
            if "Hexlet Exercises" in project.name_with_namespace:
                repos.append({
                    'name': project.name,
                    'dir': '/'.join(project.path_with_namespace.rsplit('/')[-3:]),
                    'link': project.ssh_url_to_repo,
                    'type': 'exercise',
                })
            elif "Hexlet Courses" in project.name_with_namespace:
                repos.append({
                    'name': project.name,
                    'dir': '/'.join(project.path_with_namespace.rsplit('/')[-2:]),
                    'link': project.ssh_url_to_repo,
                    'type': 'course',
                })
        elif "Hexlet Projects" in project.name_with_namespace:
            repos.append({
                'name': project.name,
                'dir': project.path_with_namespace.rsplit('/')[-1],
                'link': project.ssh_url_to_repo,
                'type': 'project',
            })
    return repos


def clone(repo, paths):
    if repo['type']:
        parent_dir = paths[repo['type']]
        path = f"{parent_dir}/{repo['dir']}"
        if not os.path.exists(path):
            os.makedirs(path, exist_ok=True)
            print(f"Cloning {repo['name']}")
            try:
                repo = git.Repo.clone_from(
                    repo['link'],
                    path,
                )
                print(f"Cloned from {repo.remotes.origin.url} to {repo.working_dir}")
                return True
            except Exception as error:
                logger.error(error)
                return False
        else:
            logger.warning(f"{path} already exists. Repository was skipped")
            return True
    else:
        logger.warning(f"{repo['link']} is not valid type of repo")
        return True


def pull(repo, paths):
    if repo['type']:
        parent_dir = paths[repo['type']]
        path = f"{parent_dir}/{repo['dir']}"
        if os.path.exists(path):
            try:
                local_repo = git.Repo(path)
            except Exception as error:
                logger.error(f"Couldn't create a repo object in {path}\n{error}")
                return False

            changed_files = local_repo.index.diff(None)
            if changed_files:
                logger.warning(f"{path} has changes. This repo was not updated")
                return False

            if not local_repo.branches:
                logger.warning(f"{path} has no branches. This repo was skipped")
                return False

            branch_name = local_repo.active_branch.name
            if 'master' not in branch_name:
                logger.warning(f"{path} is not in master branch. This repo was not updated")
                return False

            print(f"Updating {repo['name']}")
            try:
                local_repo.remotes.origin.pull('--rebase')
                print(f"{repo['name']} was updated")
                return True
            except Exception as error:
                logger.error(f"Couldn\'t update {path}\n{error}")
                return False
    else:
        logger.warning(f"{repo['link']} is not valid type of repo")
        return True


def main(params=None):
    url = os.environ['GITLAB_URL']
    token = os.environ['GITLAB_TOKEN']
    cur_dir = '/repos'
    paths = {
        'exercise': f"{cur_dir}/exercises",
        'course': f"{cur_dir}/courses",
        'project': f"{cur_dir}/projects",
    }

    if '--update' in params:
        for repo in get_repos_data(url, token):
            if not pull(repo, paths):
                print(f"An error occured with {repo['name']}. See the log file for more details")

    else:
        for repo in get_repos_data(url, token):
            if not clone(repo, paths):
                print('An error occured. See the log file for more details')
                break


if __name__ == '__main__':
    try:
        options = sys.argv[1]
    except IndexError:
        options = ''
    main(params=options)
