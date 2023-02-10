# content-localizer

CLI utility for prepearing and translating content with smartcat.

## Requirements:

* docker
* make
* git

## Warnings:

* Be careful with PROJECT_ID variable!!!
* Don't rename files in the smartcat's project

## Using:

1. Build docker image and prepare *.env* file

```bash
make build-localizer
```

2. Fill environment variables in the *content-localizer/.env* file

3. Go to the directory with course is needed to translate

4. Create another git branch. It is not necessary, but recommended. Data will be abble to be changed until translations are ready.

```bash
git checkout -b translate-to-en
```

5. Create Makefile with content, if it doesn't exist

```bash
-include ../../../course.mk
```

6. Prepare files for translation

```bash
make translations-prepare
```

7. Create new project at the smartcat if doesn't exist

8. Send prepared files to smartcat and commit changes in the git repository

```bash
make translations-send PROJECT_ID=<smartcat-project-id>
git add .
git commit -m 'prepare data to translate'
git push origin translate-to-en
```

9. Get translated files from smartcat when translate is ready and add them to git repository

```bash
make translations-get PROJECT_ID=<smartcat-project-id>
git add .
git commit -m 'get translated files'
git push origin translate-to-en
```

10. Build translated files and copy them to new course directory. It will be created if doesn't exist

```bash
make translations-write COURSE_PATH=<full-path-to-result-course>
```

11. Do not forget to switch to the main branch.

```bash
git switch main
```

12. That's all. Repeat actions from 3 with another course.
