import fs from 'fs/promises'
import yaml from 'yaml'

export async function readYamlFile<T>(filePath: string): Promise<T> {
  const fileContent = await fs.readFile(filePath, 'utf-8')
  try {
    return yaml.parse(fileContent) as T
  }
  catch (e) {
    console.error(`Could not parse: ${filePath}`)
    throw e
  }
}
