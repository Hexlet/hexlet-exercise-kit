import path from 'node:path'

export const baseDir = path.join(import.meta.dirname, '../../..')
export const coursesDir = path.join(baseDir, 'courses/ru')
export const helpDir = path.join(baseDir, 'help/articles')
export const exercisesDir = path.join(baseDir, 'exercises/ru')
export const projectsDir = path.join(baseDir, 'projects/ru')
export const ragFilesDir = path.join(baseDir, 'rag_files')

export const coursesStoreId = 'vs_67fa998a38148191a3625c2faf2e89e8'

// export const storeIds = {
//   javascript: 'vs_67d63d7f17b08191b48891045f2f2cb1',
//   java: 'vs_67e355d6a524819192f3912b3f67730f',
//   php: 'vs_67e35570b11c8191a664ec2f288fe542',
//   python: 'vs_67e357e119d08191952a941301d64233',
//   go: 'vs_67e357f6067881919b0c7d0c23b79b9d',
//   html: 'vs_67e357feadcc819198cb725c22925742',
//   css: 'vs_67e358062b1881918449740b4fa81023',
//   csharp: 'vs_67e3580afe808191a4f78312e7034843',
//   clang: 'vs_67e3583ab8dc81919c7aeefe5825032b',
//   typescript: 'vs_67e3584448788191ac4e28d8e4f852ae',
//   racket: 'vs_67e3584d7eb481919ceda4e93fc9807b',
//   ruby: 'vs_67e358571e1081919600798472b0d9c6',
//   elixir: 'vs_67e3585f60ac8191815ae65d5725b570',
//   clojure: 'vs_67e3586a5a5c8191a459bf4aec5fc91e',
// } as const
//
// export type ProgramSlug = keyof typeof storeIds
