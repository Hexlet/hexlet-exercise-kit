import fs from 'fs/promises'
import yaml from 'yaml'

export async function readYamlFile<T>(filePath: string): Promise<T> {
  const fileContent = await fs.readFile(filePath, 'utf-8')
  return yaml.parse(fileContent) as T
}
