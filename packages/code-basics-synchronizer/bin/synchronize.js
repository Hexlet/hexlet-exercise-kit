#!/usr/bin/env node

import { program } from 'commander';
import _ from 'lodash';

import synchronizer from '../src/index.js';

program
  .option('-o, --out-dir <path>', 'Hexlet course')
  .arguments('<code-basic course>', '<hexlet course>')
  .action(async (inputPath, outputPath) => {
    try {
      const result = await synchronizer(inputPath, outputPath);
      console.log(result);
    } catch(e) {
      _.noop(e);
    }
  })
  .parse(process.argv);
