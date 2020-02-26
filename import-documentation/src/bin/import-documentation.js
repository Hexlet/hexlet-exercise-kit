#!/usr/bin/env node

import program from 'commander';

import importDoc from '../src/index.js';

program
  .option('-o, --out-dir <path>', 'Folder for generated docs')
  .arguments('<filesOrDirectories...>')
  .action((items) => importDoc(program.outDir, items))
  .parse(process.argv);
