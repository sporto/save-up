FROM node:10.13-alpine as build

ENV TERM=dumb \
  LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/lib

RUN mkdir /esy
WORKDIR /esy

ENV NPM_CONFIG_PREFIX=/esy
RUN npm install -g --unsafe-perm esy@0.5.6

# Now that we have esy we need an ocaml runtime

FROM alpine:3.8 as esy

ENV TERM=dumb \
  LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/lib

WORKDIR /

COPY --from=build /esy /esy

RUN apk add --no-cache \
  ca-certificates wget \
  bash curl perl-utils \
  git patch gcc g++ musl-dev make m4 \
  postgresql-dev gmp-dev zlib-dev


RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk
RUN apk add --no-cache glibc-2.28-r0.apk

ENV PATH=/esy/bin:$PATH

RUN mkdir /app
WORKDIR /app
COPY esy.json esy.json
COPY esy.lock esy.lock

RUN esy fetch
RUN esy build-package @opam/conf-zlib@opam:1
# RUN esy build-package ocaml@4.07.0
RUN esy build-package @opam/ocamlbuild@opam:0.12.0
# RUN esy build-package @opam/ocamlfind@opam:1.8.0
# RUN esy build-package @opam/dune@opam:1.5.1
# RUN esy build-package @opam/result@opam:1.3
# RUN esy build-package @opam/base@opam:v0.11.1
# RUN esy build-package @opam/base64@opam:3.1.0
# RUN esy build-package @opam/ocaml-compiler-libs@opam:v0.11.0
# RUN esy build-package @opam/uri@opam:2.2.0
# RUN esy build-package @opam/lwt@opam:4.1.0
# RUN esy build-package @opam/cohttp@opam:2.0.0
# RUN esy build-package @opam/cohttp-lwt@opam:1.4.0
# RUN esy build-package @opam/cohttp-lwt-unix@opam:1.4.0
# RUN esy build-package @opam/postgresql@opam:4.4.1
COPY . .

# RUN esy b dune build src/main.exe --profile=docker

# RUN mv $(esy bash -c 'echo $cur__target_dir/default/src/main.exe') /app/main.exe
