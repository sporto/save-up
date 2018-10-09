start:
	hivemind

graphiql:
	hivemind Procfile.graphiql

deploy:
	just api/deploy

net-login:
	netlifyctl login

net-deploy:
	netlifyctl deploy

cypress:
	npx cypress open
