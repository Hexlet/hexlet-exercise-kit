import { glob } from 'glob';
import fs from 'fs/promises';
import path from 'path';
import Listr from 'listr';
import yaml from 'yaml';

const language = 'ru';

const startOffset = 110;
const multiplier = 10;

const getLessonData = async (filepath) => {
  const meta = yaml.parse(await fs.readFile(filepath, 'utf-8'));
  const dirnameLesson = path.dirname(filepath);
  const lessonContentFilePath = path.resolve(dirnameLesson, 'README.md');
  const content = await fs.readFile(lessonContentFilePath, 'utf-8');
  return {
    meta,
    dirnameLesson,
    content,
  };
};

const getCbLessons = async (coursePath) => {
  const lessons = await glob(`${coursePath}/**/${language}/data.yml`);
  const parsedLessons = await Promise.all(lessons.map(getLessonData));
  return parsedLessons;
};

const generateLessonName = (dirnameLesson, counter) => {
  const data = dirnameLesson.split('/');
  const subNameData = data.at(-2).split('-');
  subNameData[0] = counter * multiplier + startOffset;
  return subNameData.join('-');
};

const generateHexletSpecLesson = (meta) => {
  const specData = {
    lesson: {
      name: meta.name,
      goal: '',
    },
  };
  return yaml.stringify(specData);
};

const calculateCbLessonNumber = (dirPath) => {
  const data = dirPath.split('/').slice(-4).join('/');
  const regex = /\d+/g;
  const found = data.match(regex);
  return {
    group: parseInt(found[0], 10),
    lesson: parseInt(found[1], 10),
  }
}

const sortCbLessons = (lesson1, lesson2) => {
  const countData1 = calculateCbLessonNumber(lesson1.dirnameLesson);
  const countData2 = calculateCbLessonNumber(lesson2.dirnameLesson);

  if (countData1.group === countData2.group) {
    return countData1.lesson > countData2.lesson ? 1 : -1;
  }

  return countData1.group > countData2.group ? 1 : -1;
};

export default async (inputPath, outputPath) => {
  const cbPath = path.resolve(process.cwd(), inputPath)
  const hexletPath = path.resolve(process.cwd(), outputPath)

  const cbLessons = await getCbLessons(cbPath);

  const filteredTasks = cbLessons.filter((item) => item.meta.name);
  filteredTasks.sort(sortCbLessons);

  const tasks = filteredTasks.reduce((acc, cbLesson) => {
    const lessonName = generateLessonName(cbLesson.dirnameLesson, acc.length);
    const hexletLessonPath = path.resolve(hexletPath, lessonName);
    
    const hexletLessonSpecPath = path.resolve(hexletLessonPath, 'spec.yml');
    const hexletLessonContentPath = path.resolve(hexletLessonPath, 'README.md');

    const hexletSpec = generateHexletSpecLesson(cbLesson.meta);
    const task = async () => {
      await fs.mkdir(hexletLessonPath, { recursive: true });

      return Promise.all([
        fs.writeFile(hexletLessonSpecPath, hexletSpec, 'utf-8'),
        fs.writeFile(hexletLessonContentPath, cbLesson.content, 'utf-8'),
      ]);
    };

    return [...acc, {
      title: lessonName,
      task,
    }];
  }, []);

  const listr = new Listr(tasks, { concurrent: true, exitOnError: false });
  return listr.run();
};
