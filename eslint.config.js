import stylistic from '@stylistic/eslint-plugin';
import globals from 'globals';
import pluginJs from '@eslint/js';
import markdown from '@eslint/markdown';

export default [
  pluginJs.configs.recommended,
  stylistic.configs['recommended-flat'],
  {
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.browser,
        ...globals.jest,
      },
    },
    plugins: {
      '@stylistic': stylistic,
    },
    rules: {
      '@stylistic/semi': ['error', 'always'],
    },
  },
  {
    files: ['**/*.md'],
    plugins: {
      markdown,
    },
    processor: 'markdown/markdown',
  },
];
