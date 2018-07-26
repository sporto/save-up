#!/bin/bash
# Build everything and deploy this app to Heroku

# Build
docker build \
  -f Dockerfile.release \
  -t kic-api .

docker run -it \
  -v $PWD:/volume \
  -v cargo-cache:/root/.cargo \
  kic-api \
  cargo build -Z unstable-options --release --out-dir /volume/bin

rm bin/build-script-build
rm bin/build-script-main

DATE=`date +%Y-%m-%d-%H:%M`

aws deploy push \
  --application-name KicApi \
  --description "Update" \
  --s3-location s3://kic-api-deploys/kic-$DATE.zip \
  --source bin
