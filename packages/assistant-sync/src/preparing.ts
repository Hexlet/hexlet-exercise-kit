import fse from 'fs-extra'
import path from 'path'
import { fdir } from 'fdir'
import { readYamlFile } from './utils'
import { ragFilesDir, coursesDir, exercisesDir } from './config'

export default async function prepare() {
  await fse.remove(ragFilesDir)
  await fse.ensureDir(ragFilesDir)
  console.log(`Dest: ${ragFilesDir}`)

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
}

const isValidLessonDir = (name: string): boolean => /^\d+-[\w_]+$/i.test(name)

async function writeLessonsToStream(baseDir: string, stream: fse.WriteStream) {
  const courseDirs = await fse.readdir(baseDir, { withFileTypes: true })

  for (const courseDir of courseDirs) {
    if (!courseDir.isDirectory()) continue
    const coursePath = path.join(baseDir, courseDir.name)

    const lessonDirs = await fse.readdir(coursePath, { withFileTypes: true })
    for (const lessonDir of lessonDirs) {
      if (!lessonDir.isDirectory() || !isValidLessonDir(lessonDir.name)) continue

      const lessonPath = path.join(coursePath, lessonDir.name)
      const readmePath = await findReadmePath(lessonPath)
      if (!readmePath) continue

      const content = await fse.readFile(readmePath, 'utf-8')
      const specPath = path.join(lessonPath, 'spec.yml')
      const spec = await readYamlFile<{ lesson: { name: string } }>(specPath)

      stream.write(`# ${spec.lesson.name} (${lessonDir.name})\n\n`)
      stream.write(content.trim())
      stream.write('\n\n---\n\n')
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
