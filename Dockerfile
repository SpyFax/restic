FROM golang:1.23-bookworm AS builder

WORKDIR /go/src/github.com/restic/restic

# Copy and download Go module dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source code and build restic
COPY . .
RUN go run build.go

FROM debian:bookworm-slim AS restic

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates fuse openssh-client tzdata jq && \
    rm -rf /var/lib/apt/lists/*

# Copy the built binary from the builder stage
COPY --from=builder /go/src/github.com/restic/restic/restic /usr/bin

# Set restic as the container entrypoint
ENTRYPOINT ["/usr/bin/restic"]