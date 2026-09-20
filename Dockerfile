# syntax=docker/dockerfile:1
FROM rust:1.76-alpine as builder

WORKDIR /usr/src/insta-repo
COPY . .

# Install tools required for vendored OpenSSL and static musl compilation
RUN apk add --no-cache musl-dev perl make gcc ca-certificates

# Build with cache mounts to speed up dependency resolution
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/usr/src/insta-repo/target \
    cargo build --release && \
    cp target/release/insta-repo /insta-repo-bin

FROM scratch

# Enable secure outbound HTTPS requests
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /insta-repo-bin /insta-repo

ENTRYPOINT ["/insta-repo"]
