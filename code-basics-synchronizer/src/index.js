import { glob } from 'glob';
import fs from 'fs/promises';
import path from 'path';
import Listr from 'listr';

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
};

export default async (inputPath, outputPath) => {
  const cbLessons = await getCbLessons(inputPath);
  const hexletLessons = await getHexletLessons(outputPath);
  const tasks = cbLessons.filter((item) => item.name).map((cbLesson) => {
    const task = async () => {
      const hexletLesson = hexletLessons.find((lesson) => lesson.name?.toLowerCase() === cbLesson.name.toLowerCase());
      if (!hexletLesson) {
        return Promise.reject(Error('Not found lesson on Hexlet'));
      }
      if (!cbLesson.theory) {
        return Promise.reject(Error('Not found content'));
      }
      return fs.writeFile(hexletLesson.readmePath, cbLesson.theory, 'utf-8');
    };

    return {
      title: cbLesson.name || '',
      task,
    };
  });

  const listr = new Listr(tasks, { concurrent: true, exitOnError: false });
  return listr.run();
};
