api-build:
	cd api && cargo build

api-run:
	cd api && cargo run

start:
  invoker start invoker.ini

deploy:
  git push heroku master
