FROM golang:1.25-bookworm AS builder

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
    ca-certificates fuse openssh-client tzdata jq bash-completion && \
    rm -rf /var/lib/apt/lists/*

# Copy the built binary from the builder stage
COPY --from=builder /go/src/github.com/restic/restic/restic /usr/bin

RUN mkdir -p /etc/bash_completion.d && \
    restic generate --bash-completion /etc/bash_completion.d/restic

RUN echo '. /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc

# Set restic as the container entrypoint
ENTRYPOINT ["/usr/bin/restic"]
