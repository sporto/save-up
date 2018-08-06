api-build:
	just api/build

api:
	DATABASE_URL=$DATABASE_URL sam local start-api -p 4010 --skip-pull-image

start:
	invoker start invoker.ini
