module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  moduleNameMapper: {
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
  transform: {
    '^.+\\.(ts|tsx)$': [
      'ts-jest',
      {
        isolatedModules: true,
        tsconfig: {
          jsx: 'react-jsx',
          esModuleInterop: true,
          moduleResolution: 'node',
          ignoreDeprecations: '6.0'
        },
      },
    ],
  },
};