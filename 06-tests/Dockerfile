# build stage
FROM golang:1.14 as builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY main.go .

# Set compilation variable in case someone is building this on a Mac.
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o hello

# final stage
FROM alpine:3.11

WORKDIR /app
COPY --from=builder /app/hello .
ENTRYPOINT ["/app/hello"]