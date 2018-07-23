build-client:
	cd client && yarn ts-node ./node_modules/.bin/webpack --config webpack.prod.ts
