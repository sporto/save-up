start:
	hivemind

graphiql:
	hivemind Procfile.graphiql

net-login:
	netlifyctl login

net-deploy:
	just client/build
	netlifyctl deploy

cypress:
	npx cypress open
