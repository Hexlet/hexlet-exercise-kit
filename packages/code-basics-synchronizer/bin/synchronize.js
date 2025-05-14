#!/usr/bin/env node

import { program } from 'commander';
import _ from 'lodash';

import synchronizer from '../src/index.js';

program
  .option('-o, --out-dir <path>', 'Hexlet course')
  .arguments('<code-basic course>', '<hexlet course>')
  .action(async (inputPath, outputPath) => {
    try {
      await synchronizer(inputPath, outputPath);
    } catch(e) {
      console.error(e);
    }
  })
  .parse(process.argv);
