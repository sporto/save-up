build-client-web:
	cd client && yarn ts-node ./node_modules/.bin/webpack --config webpack.prod.ts
	cp -a client/dist/. netlify/
	cp -a web/public/. netlify/
