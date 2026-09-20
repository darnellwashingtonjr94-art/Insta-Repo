# Build stage
FROM rust:1.76-alpine AS builder

WORKDIR /usr/src/insta-repo

# Copy project files
COPY . .

# Build with cache mounts to speed up dependency resolution
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/usr/src/insta-repo/target \
    cargo build --release && \
    cp target/release/insta-repo /insta-repo-bin

# Final runtime stage
FROM alpine:latest

# Copy the compiled binary from the builder stage
COPY --from=builder /insta-repo-bin /usr/local/bin/insta-repo

# Set the binary as the entrypoint
ENTRYPOINT ["/usr/local/bin/insta-repo"]
