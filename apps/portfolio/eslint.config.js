import js from '@eslint/js';
import tsParser from '@typescript-eslint/parser';
import solid from 'eslint-plugin-solid/configs/v2';

export default [
  {
    ignores: ['dist/**'],
  },
  js.configs.recommended,
  {
    ...solid,
    files: ['**/*.{ts,tsx}'],
    languageOptions: {
      ...solid.languageOptions,
      parser: tsParser,
      parserOptions: {
        ecmaFeatures: { jsx: true },
        sourceType: 'module',
      },
    },
    rules: {
      ...solid.rules,
      'no-undef': 'off',
      'no-unassigned-vars': 'off',
    },
  },
];
