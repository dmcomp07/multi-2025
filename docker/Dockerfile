FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Final stage
FROM alpine:3.18

RUN apk --no-cache add ca-certificates curl

WORKDIR /root/

# Copy binary from builder
COPY --from=builder /app/main .

# Create non-root user
RUN adduser -D -g '' appuser
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health/live || exit 1

EXPOSE 8080 8081

CMD ["./main"]
