import fse from 'fs-extra'
import path from 'path'
import { fdir } from 'fdir'
import { readYamlFile } from './utils'
import {
  ragFilesDir,
  coursesDir,
  exercisesDir,
  projectsDir,
  helpDir,
} from './config'

export default async function prepare() {
  await fse.remove(ragFilesDir)
  await fse.ensureDir(ragFilesDir)
  console.log(`Dest: ${ragFilesDir}`)

  const helpOutputPath = path.join(ragFilesDir, 'all_help.md')
  const helpStream = fse.createWriteStream(helpOutputPath, { encoding: 'utf-8' })
  await writeHelpToStream(helpDir, helpStream)
  helpStream.end()
  console.log(`Written: ${helpOutputPath}`)

  const lessonsOutputPath = path.join(ragFilesDir, 'all_lessons.md')
  const lessonsStream = fse.createWriteStream(lessonsOutputPath, { encoding: 'utf-8' })
  await writeLessonsToStream(coursesDir, lessonsStream)
  lessonsStream.end()
  console.log(`Written: ${lessonsOutputPath}`)

  const exercisesOutputPath = path.join(ragFilesDir, 'all_exercises.md')
  const exercisesStream = fse.createWriteStream(exercisesOutputPath, { encoding: 'utf-8' })
  await writeExercisesToStream(exercisesDir, exercisesStream)
  exercisesStream.end()
  console.log(`Written: ${exercisesOutputPath}`)

  const projectsOutputPath = path.join(ragFilesDir, 'all_projects.md')
  const projectsStream = fse.createWriteStream(projectsOutputPath, { encoding: 'utf-8' })
  await writeProjectsToStream(projectsDir, projectsStream)
  projectsStream.end()
  console.log(`Written: ${projectsOutputPath}`)
}

const isValidLessonDir = (name: string): boolean => /^\d+-[\w_]+$/i.test(name)

async function writeLessonsToStream(baseDir: string, stream: fse.WriteStream) {
  const courseDirs = await fse.readdir(baseDir, { withFileTypes: true })

  for (const courseDir of courseDirs) {
    if (!courseDir.isDirectory()) continue
    const coursePath = path.join(baseDir, courseDir.name)
    const courseSpecPath = path.join(coursePath, 'spec.yml')
    const courseSpec = await readYamlFile<{ course: { name: string } }>(courseSpecPath)

    const lessonDirs = await fse.readdir(coursePath, { withFileTypes: true })
    for (const lessonDir of lessonDirs) {
      if (!lessonDir.isDirectory() || !isValidLessonDir(lessonDir.name)) continue

      const lessonPath = path.join(coursePath, lessonDir.name)
      const readmePath = await findReadmePath(lessonPath)
      if (!readmePath) continue

      const content = await fse.readFile(readmePath, 'utf-8')
      const lessonSpecPath = path.join(lessonPath, 'spec.yml')
      const lessonSpec = await readYamlFile<{ lesson: { name: string } }>(lessonSpecPath)

      stream.write(`# Урок: ${lessonSpec.lesson.name}. Курс: ${courseSpec.course.name}\n\n`)
      stream.write(content.trim())
      stream.write('\n\n')

      const questionsPath = path.join(lessonPath, 'questions.yml')
      if (await fse.pathExists(questionsPath)) {
        const questionsContent = await fse.readFile(questionsPath, 'utf-8')
        stream.write('## Вопросы (Тесты/Квиз) (questions.yml)\n\n')
        stream.write('```yaml\n')
        stream.write(questionsContent.trim())
        stream.write('\n```\n\n')
      }

      stream.write('---\n\n')
    }
  }
}

async function writeExercisesToStream(baseDir: string, stream: fse.WriteStream) {
  const courseDirs = await fse.readdir(baseDir, { withFileTypes: true })

  for (const courseDir of courseDirs) {
    if (!courseDir.isDirectory()) continue
    const courseExercisesPath = path.join(baseDir, courseDir.name)

    const exerciseDirs = await fse.readdir(courseExercisesPath, { withFileTypes: true })
    for (const exerciseDir of exerciseDirs) {
      if (!exerciseDir.isDirectory()) continue

      const exercisePath = path.join(courseExercisesPath, exerciseDir.name)
      const readmePath = await findReadmePath(exercisePath)
      if (!readmePath) continue

      const content = await fse.readFile(readmePath, 'utf-8')

      stream.write(`# ${exerciseDir.name}\n\n`)
      stream.write(content.trim())
      stream.write('\n\n')

      const testFiles = await findTestFilePaths(exercisePath)
      for (const filePath of testFiles) {
        const relative = path.relative(exercisePath, filePath)
        const testContent = await fse.readFile(filePath, 'utf-8')

        stream.write(`## Тесты: ${relative}\n\n`)
        stream.write('```js\n')
        stream.write(testContent.trim())
        stream.write('\n```\n\n')
      }

      stream.write('---\n\n')
    }
  }
}

async function writeProjectsToStream(baseDir: string, stream: fse.WriteStream) {
  const projects = await fse.readdir(baseDir, { withFileTypes: true })

  for (const project of projects) {
    if (!project.isDirectory()) continue
    const projectPath = path.join(baseDir, project.name)
    const dataPath = path.join(projectPath, '__data__')

    const specPath = path.join(dataPath, 'spec.yml')
    if (!(await fse.pathExists(specPath))) continue

    const spec = await readYamlFile<{
      project: { name: string, language: string, summary?: string, link?: string }
    }>(specPath)

    stream.write(`# ${spec.project.name} (${spec.project.language})\n\n`)
    if (spec.project.link) stream.write(`**Ссылка**: ${spec.project.link}\n\n`)
    if (spec.project.summary) stream.write(`${spec.project.summary.trim()}\n\n`)

    // README.md
    const readmePath = path.join(dataPath, 'README.md')
    if (await fse.pathExists(readmePath)) {
      const content = await fse.readFile(readmePath, 'utf-8')
      stream.write(`${content.trim()}\n\n`)
    }

    // checklist.md
    const checklistPath = path.join(dataPath, 'checklist.md')
    if (await fse.pathExists(checklistPath)) {
      const content = await fse.readFile(checklistPath, 'utf-8')
      stream.write(`${content.trim()}\n\n`)
    }

    // steps/*.md
    const stepsDir = path.join(dataPath, 'steps')
    if (await fse.pathExists(stepsDir)) {
      const stepFiles = (await fse.readdir(stepsDir))
        .filter(f => /^\d+-.+\.md$/.test(f))
        .sort((a, b) => parseInt(a) - parseInt(b)) // по номеру

      for (const stepFile of stepFiles) {
        const stepPath = path.join(stepsDir, stepFile)
        const content = await fse.readFile(stepPath, 'utf-8')
        // const title = stepFile.replace(/^\d+-/, '')
        //   .replace(/\.md$/, '')
        stream.write(`${content.trim()}\n\n`)
      }
    }

    stream.write('---\n\n')
  }
}

async function findReadmePath(dir: string): Promise<string | null> {
  const mdPath = path.join(dir, 'README.md')
  if (await fse.pathExists(mdPath)) return mdPath

  const adocPath = path.join(dir, 'README.adoc')
  if (await fse.pathExists(adocPath)) return adocPath

  return null
}

async function findTestFilePaths(baseDir: string): Promise<string[]> {
  const filepaths = await new fdir()
    .withFullPaths()
    .filter(filePath => /test/i.test(path.basename(filePath)))
    .crawl(baseDir)
    .withPromise()

  return filepaths
}

async function writeHelpToStream(baseDir: string, stream: fse.WriteStream) {
  const sections = await fse.readdir(baseDir, { withFileTypes: true })

  for (const section of sections) {
    if (!section.isDirectory()) continue
    const sectionPath = path.join(baseDir, section.name)

    const topics = await fse.readdir(sectionPath, { withFileTypes: true })

    for (const topic of topics) {
      if (!topic.isFile() || !topic.name.endsWith('.md')) continue

      const filePath = path.join(sectionPath, topic.name)
      const content = await fse.readFile(filePath, 'utf-8')

      stream.write(`${content.trim()}\n\n`)
      stream.write('---\n\n')
    }
  }
}
