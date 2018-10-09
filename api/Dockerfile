FROM clux/muslrust:stable as base

WORKDIR /volume

# create a new empty shell project
RUN USER=root cargo init
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# cache dependencies
RUN cargo build --release
RUN rm src/*.rs

COPY ./src ./src
COPY ./templates ./templates 
RUN cargo build --release

FROM scratch
COPY --from=base /volume/target/x86_64-unknown-linux-musl/release/api /api
CMD ["/api"]
