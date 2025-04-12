import * as git from 'isomorphic-git'
import fse from 'fs-extra'
import fsp from 'fs/promises'
import fs from 'fs'
import { pipeline } from 'stream/promises'
import os from 'node:os'
import path from 'node:path'
import http from 'isomorphic-git/http/node/index.js'
import { Course } from '../types'
import { readYamlFile } from './utils'
import OpenAI from 'openai'
import PQueue from 'p-queue'
import { ProgramSlug, storeIds } from './config'
import { PassThrough, Readable } from 'node:stream'

async function cloneOrPull(lang: string): Promise<string> {
  const repositoryName = `/hexlet-basics/exercises-${lang}` // Change to your repository
  const repositoryUrl = `https://github.com/${repositoryName}`
  const dest = path.join(os.tmpdir(), repositoryName)

  console.log(`Repository: ${repositoryUrl}`)
  console.log(`Clone to: ${dest}`)

  if (!(await fse.pathExists(dest))) {
    console.log('Cloning repository...')
    await git.clone({
      fs: fse,
      http,
      dir: dest,
      url: repositoryUrl,
      singleBranch: true,
      depth: 1,
    })
    console.log('Repository cloned')
  }
  else {
    console.log('Repository exists. Resetting to HEAD...')
    await git.checkout({
      fs: fse,
      dir: dest,
      ref: 'main', // Change if your default branch is different
    })

    await git.resetIndex({
      fs: fse,
      dir: dest,
      filepath: '.', // Reset all files
    })
  }

  return dest
}

async function readCourse(courseSlug: ProgramSlug, courseDir: string): Promise<Course> {
  const courseDescriptionPath = path.join(courseDir, 'description.ru.yml')
  const courseMetadata = await readYamlFile<{ header: string, description: string }>(
    courseDescriptionPath,
  )

  const courseSpecPath = path.join(courseDir, 'spec.yml')
  const courseSpec = await readYamlFile<{
    language: {
      exercise_filename: string
      exercise_test_filename: string
    }
  }>(
    courseSpecPath,
  )

  const modulesPath = path.join(courseDir, 'modules')
  const moduleDirs = await fsp.readdir(modulesPath)

  const filteredModuleDirs = moduleDirs.filter(dir => /^\d+-/.test(dir))
  const sortedModuleDirs = filteredModuleDirs.sort(
    (a, b) => Number(a.split('-')[0]) - Number(b.split('-')[0]),
  )
  // console.log(sortedModuleDirs)

  const modulePromises = sortedModuleDirs.map(async (moduleSlug) => {
    const modulePath = path.join(modulesPath, moduleSlug)
    const moduleDescriptionPath = path.join(modulePath, 'description.ru.yml')

    const moduleMetadata = await readYamlFile<{ name: string, description: string }>(
      moduleDescriptionPath,
    )

    const lessonDirs = await fsp.readdir(modulePath)
    const filteredLessonDirs = lessonDirs.filter(dir => /^\d+-/.test(dir))
    const sortedLessonDirs = filteredLessonDirs.sort(
      (a, b) => Number(a.split('-')[0]) - Number(b.split('-')[0]),
    )
    // console.log(sortedLessonDirs)

    const lessonPromises = sortedLessonDirs.map(async (lessonSlug) => {
      const lessonPath = path.join(modulePath, lessonSlug)
      const lessonRuPath = path.join(lessonPath, 'ru')

      const readmePath = path.join(lessonRuPath, 'README.md')
      const exercisePath = path.join(lessonRuPath, 'EXERCISE.md')
      const codePath = path.join(lessonPath, courseSpec.language.exercise_filename)
      const testPath = path.join(lessonPath, courseSpec.language.exercise_test_filename)
      const lessonMetaDataPath = path.join(lessonRuPath, 'data.yml')

      const lessonMetaData = await readYamlFile<{ name: string }>(
        lessonMetaDataPath,
      )

      return {
        slug: lessonSlug,
        name: lessonMetaData.name,
        readmePath,
        exercisePath,
        codePath,
        testPath,
      }
      // const readme = fsp.readFile(readmePath, 'utf-8')
      // const exercise = fsp.readFile(exercisePath, 'utf-8')
      // const code = fsp.readFile(codePath, 'utf-8')
      // const test = fsp.readFile(testPath, 'utf-8')

      // const [readmeContent, exerciseContent, codeContent, testContent] = await Promise.all([
      //   readme,
      //   exercise,
      //   code,
      //   test,
      // ])

      // return {
      //   readme: readmeContent.trim(),
      //   exercise: exerciseContent.trim(),
      //   code: codeContent.trim(),
      //   test: testContent.trim(),
      // }
    })

    const lessons = await Promise.all(lessonPromises)

    return {
      slug: moduleSlug,
      name: moduleMetadata.name,
      description: moduleMetadata.description,
      lessons,
    }
  })

  const modules = await Promise.all(modulePromises)

  return {
    name: courseMetadata.header,
    slug: courseSlug,
    description: courseMetadata.description,
    modules,
  }
}

export async function load(courseSlug: ProgramSlug) {
  const courseDir = await cloneOrPull(courseSlug)
  const course = await readCourse(courseSlug, courseDir)

  // OPENAI_API_KEY
  const client = new OpenAI()

  // TODO: retrieve list of stores, find one by name and use it
  // the stores's names should be standartize (ex. exercises-javascript)
  const storeId = storeIds[courseSlug]
  // const store = await client.vectorStores.retrieve(storeId)
  const storeFiles = await client.vectorStores.files.list(storeId)
  // console.log(storeFiles.data)
  for (const storeFile of storeFiles.data) {
    await client.vectorStores.files.del(storeId, storeFile.id)
  }

  const tmpDir = os.tmpdir()
  console.log(`Directory for prepared files: ${tmpDir}`)

  for (const module of course.modules) {
    const queue = new PQueue({ concurrency: 5 })
    const promises = module.lessons.map((lesson) => {
      return async () => {
        const filename = `${course.slug}-${module.slug}-${lesson.slug}.txt`
        const tempFilePath = path.join(tmpDir, filename)
        const writeStream = fs.createWriteStream(tempFilePath)
        const pass = new PassThrough()

        const inputChunks = [
          Readable.from([`\n\n# ${lesson.name}\n\n`]),
          Readable.from(['\n\n## Теория урока\n\n']),
          fs.createReadStream(lesson.readmePath),
          Readable.from(['\n\n## Задание (Практика) урока\n\n']),
          fs.createReadStream(lesson.exercisePath),
          Readable.from(['\n\n## Реализация задания (то что должен написать студент)\n\n']),
          fs.createReadStream(lesson.codePath),
          Readable.from(['\n\n## Тесты задания (по которым проверяется код студента и реализация\n\n']),
          fs.createReadStream(lesson.testPath),
        ]

        const pushStreams = async () => {
          for (const stream of inputChunks) {
            for await (const chunk of stream) {
              pass.write(chunk)
            }
          }
          pass.end()
        }

        await Promise.all([
          pushStreams(),
          pipeline(pass, writeStream),
        ])

        await client.vectorStores.files.uploadAndPoll(
          storeId,
          fs.createReadStream(tempFilePath),
        )
        console.log(filename)
      }
    })
    await queue.addAll(promises)
  }

  // console.log(JSON.stringify(data, null, 2))
  // const { text } = await generateText({
  //   model: openai('o3-mini'),
  //   prompt: 'What is love?',
  // })
}
