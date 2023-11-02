#!/usr/bin/env node

import { program } from 'commander';

import synchronizer from '../src/index.js';

program
  .option('-o, --out-dir <path>', 'Hexlet course')
  .arguments('<code-basic course>', '<hexlet course>')
  .action(async (inputPath, outputPath) => {
    const result = await synchronizer(inputPath, outputPath);
    console.log(result);
  })
  .parse(process.argv);
