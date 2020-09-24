// @ts-check

import { test, expect } from '@jest/globals';
import os from 'os';
import fs from 'fs';
import path from 'path';
import importDoc from '../index.js';

const getFixturePath = (filename = '') => path.join('__fixtures__', filename);

test('test 1', async () => {
  const out = fs.mkdtempSync(path.join(os.tmpdir(), 'importer-'));
  const filePaths = [getFixturePath('example.js')];
  await importDoc(out, filePaths);
  const result = path.resolve(out, '@hexlet-pairs.md');
  expect(fs.lstatSync(result).isFile()).toBe(true);
  const result2 = path.resolve(out, '@hexlet-co.md');
  expect(fs.lstatSync(result2).isFile()).toBe(true);
  const result3 = path.resolve(out, '@hexlet-tagged-types.md');
  expect(fs.lstatSync(result3).isFile()).toBe(true);
});

test('test 2', async () => {
  const out = fs.mkdtempSync(path.join(os.tmpdir(), 'importer-'));
  const dir = [getFixturePath()];
  await importDoc(out, dir);
  const result = path.resolve(out, '@hexlet-pairs.md');
  expect(fs.lstatSync(result).isFile()).toBe(true);
  const result2 = path.resolve(out, '@hexlet-co.md');
  expect(fs.lstatSync(result2).isFile()).toBe(true);
  const result3 = path.resolve(out, '@hexlet-tagged-types.md');
  expect(fs.lstatSync(result3).isFile()).toBe(true);
});
