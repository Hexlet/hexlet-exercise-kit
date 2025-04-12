import fsp from 'fs/promises'
import fs from 'fs'
import OpenAI from 'openai'
import PQueue from 'p-queue'
import { courseRagFilesDir, coursesStoreId } from './config'
import path from 'path'

export default async function upload() {
  // OPENAI_API_KEY
  const client = new OpenAI()

  const storeFiles = await client.vectorStores.files.list(coursesStoreId)
  // console.log(storeFiles.data)
  for (const storeFile of storeFiles.data) {
    await client.vectorStores.files.del(coursesStoreId, storeFile.id)
  }

  const files = await fsp.readdir(courseRagFilesDir, { withFileTypes: true })
  const queue = new PQueue({ concurrency: 5 })
  const promises = files.map((file) => {
    // if (!dir.isDirectory()) continue
    console.log(`Course: ${file.name}`)
    return () => client.vectorStores.files.uploadAndPoll(
      coursesStoreId,
      fs.createReadStream(path.join(file.parentPath, file.name)),
    )
  })

  await queue.addAll(promises)
}
