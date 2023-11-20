import yaml from 'js-yaml';

export default (data) => {
  const parsedData = yaml.load(data);

  return parsedData;
};
