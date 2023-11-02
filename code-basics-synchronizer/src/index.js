import { glob } from 'glob';
import fs from 'fs/promises';
import path from 'path';

import parse from './parseCodeBasicExercise.js';

const getLessonData = async (filepath) => parse(await fs.readFile(filepath, 'utf-8'));

const getCbLessons = async (coursePath) => {
  const lessons = await glob(`${coursePath}/**/description.ru.yml`);
  const parsedLessons = await Promise.all(lessons.map(getLessonData));
  return parsedLessons;
};

const getHexletLessons = async (coursePath) => {
  const specPaths = await glob(`${coursePath}/**/spec.yml`);
  const parsedLessons = await Promise.all(specPaths.map(async (specPath) => {
    const specData = await getLessonData(specPath);
    const result = {
      specPath,
      name: specData.lesson?.name,
      readmePath: path.resolve(path.dirname(specPath), 'README.md'),
    };
    return result;
  }));
  return parsedLessons;
}

export default async (inputPath, outputPath) => {
  // const inputData = getData(inputPath);
  const cbLessons = await getCbLessons(inputPath);
  const hexletLessons = await getHexletLessons(outputPath);

  return Promise.all(cbLessons.map(async (cbLesson) => {
    const hexletLesson = hexletLessons.find((lesson) => lesson.name === cbLesson.name);
    if (!hexletLesson) {
      return Promise.resolve(`Урок ${cbLesson.name} не найден на Hexlet`);
    }
    await fs.writeFile(hexletLesson.readmePath, cbLesson.theory, 'utf-8');
    return `Урок ${cbLesson.name} обновлен`;
  }));
};
