// @flow

import os from 'os';
import fs from 'fs';
import path from 'path';
import importDoc from '../src';

test('test 1', async () => {
  const out = fs.mkdtempSync(path.join(os.tmpdir(), 'importer-'));
  const files = [`${__dirname}/fixtures/example.js`];
  await importDoc(out, files);
  const result = path.resolve(out, 'hexlet-pairs.md');
  expect(fs.lstatSync(result).isFile()).toBe(true);
  const result2 = path.resolve(out, 'hexlet-co.md');
  expect(fs.lstatSync(result2).isFile()).toBe(true);
});

test('test 2', async () => {
  const out = fs.mkdtempSync(path.join(os.tmpdir(), 'importer-'));
  const dir = [`${__dirname}/fixtures`];
  await importDoc(out, dir);
  const result = path.resolve(out, 'hexlet-pairs.md');
  expect(fs.lstatSync(result).isFile()).toBe(true);
  const result2 = path.resolve(out, 'hexlet-co.md');
  expect(fs.lstatSync(result2).isFile()).toBe(true);
});
