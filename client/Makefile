build-client-web:
	yarn ts-node ./node_modules/.bin/webpack --config webpack.prod.ts
	cp -a dist/. netlify/
	cp -a ../web/public/. netlify/
