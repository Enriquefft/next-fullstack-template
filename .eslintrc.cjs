/* eslint-disable jsdoc/check-tag-names */
/* eslint-disable @typescript-eslint/no-magic-numbers */
/* eslint-disable @typescript-eslint/naming-convention */

/** @type {import('eslint').Linter.Config['rules']}*/
const jsdocRules = {
  "jsdoc/check-param-names": [
    "error",
    {
      checkRestProperty: true,
    },
  ],
};

/** @type {import('eslint').Linter.Config['rules']}*/
const reactRules = {
  "@typescript-eslint/naming-convention": [
    "error",
    {
      selector: "function",
      format: ["PascalCase", "camelCase"],
    },
  ],
  "react/jsx-filename-extension": ["error", { extensions: [".tsx"] }],

  "react/jsx-sort-props": "off",

  // Irrelevant for functional components
  "react/jsx-no-bind": "off",

  "react/jsx-no-literals": "off",
  "react/jsx-max-depth": ["warn", { max: 5 }],

  "react/require-default-props": "off",
};

/** @type {import("eslint").Linter.Config['rules']}*/
const jsRules = {
  "no-ternary": "off",
  "sort-keys": "off",

  "func-names": ["error", "as-needed"],

  // Allow function expressions and declarations
  "func-style": "off",

  "one-var": ["error", "never"],
  "id-length": [
    "error",
    {
      min: 3,
      exceptions: ["_", "__", "id", "db", "cn", "sm", "lg"],
    },
  ],
  "sort-imports": "off",

  // Console statements are allowed in some contexts (aws lambdas)
  "no-console": "off",

  // Prefer cyclomatic complexity
  "max-statements": "off",
  "max-lines-per-function": "off",

  "no-undefined": "off",

  // Comments can be of different lengths and have different purposes
  "no-inline-comments": "off",
  "line-comment-position": "off",

  "no-warning-comments": "warn",

  "new-cap": ["error", { capIsNew: false }],

  // Prefer @typescript-eslint/naming-convention
  camelcase: "off",
};

/** @type {import('eslint').Linter.Config['rules']}*/
const tsRules = {
  "@typescript-eslint/naming-convention": ["error"],

  // Return types are evil
  "@typescript-eslint/explicit-function-return-type": "off",
  "@typescript-eslint/explicit-module-boundary-types": "off",

  "@typescript-eslint/no-unused-vars": [
    "error",
    { varsIgnorePattern: "^_*$", argsIgnorePattern: "^_*$" },
  ],

  "@typescript-eslint/prefer-readonly-parameter-types": [
    "off",
    {
      ignoreInferredTypes: true,
    },
  ],

  "@typescript-eslint/sort-type-constituents": "off",

  "@typescript-eslint/no-magic-numbers": [
    "error",
    {
      enforceConst: true,
      ignoreEnums: true,
      ignore: [-1, 0, 1, 2],
      ignoreNumericLiteralTypes: true,
      ignoreReadonlyClassProperties: true,
    },
  ],

  // Prefer types over interfaces
  "@typescript-eslint/consistent-type-definitions": ["error", "type"],

  // Allow Nextjs server actions to be async without await
  "@typescript-eslint/require-await": "off",

  // Allow use of server actions in forms, onClick, etc
  "@typescript-eslint/no-misused-promises": [
    "error",
    {
      checksVoidReturn: {
        attributes: false,
      },
    },
  ],
};

/** @type {import("eslint").Linter.Config['parserOptions']}*/
const parserOptions = {
  ecmaVersion: "latest",
  sourceType: "module",
  project: true,
};

const defaultRules = Object.assign(jsRules, tsRules, jsdocRules);

/** @type {import("eslint").Linter.Config} */
const config = {
  ignorePatterns: [
    "**/old/**/*",
    "next-env.d.ts",
    "**/schema.gen*",
    "experimental",
  ],
  parserOptions,
  extends: [
    "eslint:all",
    "next",
    "next/core-web-vitals",
    "plugin:jsdoc/recommended-typescript-error",
    "plugin:@typescript-eslint/all",
    "prettier",
    "plugin:tailwindcss/recommended",
    "plugin:drizzle/all",
    "plugin:jsx-a11y/strict",
  ],
  rules: defaultRules,
  overrides: [
    {
      files: ["*.[jt]sx"],
      rules: Object.assign(defaultRules, reactRules),
    },
  ],
  globals: {
    React: "readonly",
    JSX: "readonly",
  },
};
module.exports = config;
