FROM ocaml/opam2:alpine as base

# RUN sudo apt-get update

RUN sudo apk add \
  m4 \
  postgresql-dev

RUN opam init -y && \
  opam install dune

COPY . .

# All files need to be owned by opam
# Otherwise the build fails
RUN sudo chown -R opam:nogroup .

# Install the most important deps in order to cache them
RUN opam install core \
  caqti \
  caqti-lwt \
  caqti-driver-postgresql \
  lwt \
  lwt_ppx \
  graphql \
  graphql-lwt

# Install all the other deps
# RUN eval `opam config env` && \
RUN opam install --deps-only .

# Build the binary
RUN eval `opam config env` && \
  dune build ./bin/main.exe


FROM alpine

RUN apk add \
  postgresql-dev

WORKDIR /root/
COPY --from=base /home/opam/opam-repository/_build/default/bin/main.exe ./main.exe
RUN ldd main.exe
CMD ./main.exe
