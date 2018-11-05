FROM clux/muslrust:nightly as base	

WORKDIR /volume	

RUN cargo install cargo-build-deps	

# create a new empty shell project	
RUN USER=root cargo init	
COPY Cargo.toml Cargo.lock ./	

RUN cargo build-deps --release	

COPY src ./src	
COPY ./Rocket.toml ./
COPY ./templates ./templates	
COPY ./build.rs ./

RUN cargo build  --release

FROM scratch
COPY --from=base /volume/target/x86_64-unknown-linux-musl/release/api /api	
COPY ./Rocket.toml /
CMD ["/api"]
