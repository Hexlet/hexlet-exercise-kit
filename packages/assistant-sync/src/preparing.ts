import fs from 'fs/promises'
import { courseRagFilesDir, coursesDir } from './config'
import path from 'path'
import { Dirent } from 'fs'
import { readYamlFile } from './utils'

export default async function prepare() {
  await fs.mkdir(courseRagFilesDir, { recursive: true })
  console.log(`Dest: ${courseRagFilesDir}`)

  const dirs = await fs.readdir(coursesDir, { withFileTypes: true })
  for (const dir of dirs) {
    if (!dir.isDirectory()) continue
    console.log(`Course: ${dir.name}`)
    const content = await prepareFileContent(dir)
    const filePath = path.join(courseRagFilesDir, dir.name)
    await fs.writeFile(filePath, content)
  }
}

const isValidLessonDir = (name: string): boolean => /^\d+-[\w_]+$/i.test(name)

async function prepareFileContent(dir: Dirent) {
  const repositoryPath = path.join(dir.parentPath, dir.name)
  const entries = await fs.readdir(repositoryPath, { withFileTypes: true })

  const readmes: string[] = []

  for (const entry of entries) {
    if (!isValidLessonDir(entry.name)) continue

    let fileStat
    let readmePath

    const lessonPath = path.join(repositoryPath, entry.name)
    try {
      readmePath = path.join(lessonPath, 'README.md')
      fileStat = await fs.stat(readmePath)
    }
    catch {
      readmePath = path.join(lessonPath, 'README.adoc')
      fileStat = await fs.stat(readmePath)
    }
    if (fileStat.isFile()) {
      const content = await fs.readFile(readmePath, 'utf-8')
      const spec = await readYamlFile<{ lesson: { name: string } }>(path.join(lessonPath, 'spec.yml'))
      readmes.push(`# ${spec.lesson.name} (${entry.name})\n\n${content}`)
    }
  }

  return readmes.join('\n\n---\n\n')
}
