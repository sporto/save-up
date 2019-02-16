start:
	hivemind

graphiql:
	hivemind Procfile.graphiql

# deploy:
	# now

net-login:
	netlifyctl login

net-deploy:
	netlifyctl deploy

cypress:
	npx cypress open
