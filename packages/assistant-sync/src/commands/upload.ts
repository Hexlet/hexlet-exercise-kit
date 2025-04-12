import { Command } from '@oclif/core'
import upload from '../uploading'

export default class Prepare extends Command {
  // static override args = {
  //   program: Args.string({ description: 'program slug' }),
  // }

  // static override description = 'describe the command here'
  static override examples = [
    '<%= config.bin %> <%= command.id %>',
  ]

  // static override flags = {
  //   // flag with no value (-f, --force)
  //   force: Flags.boolean({ char: 'f' }),
  //   // flag with a value (-n, --name=VALUE)
  //   name: Flags.string({ char: 'n', description: 'name to print' }),
  // }

  public async run(): Promise<void> {
    await upload()
    // const { args } = await this.parse(Load)
    // if (args.program && isProgramSlug(args.program)) {
    //   await load(args.program)
    // }
    // else {
    //   this.error(`Unsupported program: ${args.program}`)
    // }
    // const name = flags.name ?? 'world'
    // this.log(`hello ${name} from /Users/mokevnin/projects/hexlet-basics-assistant/src/commands/load.ts`)
    // if (args.file && flags.force) {
    //   this.log(`you input --force and --file: ${args.file}`)
    // }
  }
}

