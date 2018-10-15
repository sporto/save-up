FROM rust:1.29 as base

WORKDIR /volume

RUN cargo install cargo-build-deps

# create a new empty shell project
RUN USER=root cargo init

COPY Cargo.toml Cargo.lock ./
RUN cargo build-deps --release

COPY src ./src
COPY ./templates ./templates

RUN cargo build  --release
