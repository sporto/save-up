start:
	hivemind

graphiql:
	hivemind Procfile.graphiql

net-login:
	netlify login

deploy-client:
	just client/build
	netlify deploy --prod --dir=./client/dist

cypress:
	npx cypress open
