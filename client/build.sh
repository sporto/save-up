#!/bin/bash

# Used for Netlify
yarn ts-node ./node_modules/.bin/webpack --config webpack.prod.ts
cp -a ./dist-web/. ./dist/
