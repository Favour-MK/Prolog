FROM golang:1.26-alpine AS build
WORKDIR /go/src/proglog
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /go/bin/proglog ./cmd/server && \
    CGO_ENABLED=0 go build -o /go/bin/getservers ./cmd/getservers && \
    CGO_ENABLED=0 go install github.com/grpc-ecosystem/grpc-health-probe@v0.4.57

FROM gcr.io/distroless/static-debian12
COPY --from=build /go/bin/proglog /bin/proglog
COPY --from=build /go/bin/getservers /bin/getservers
COPY --from=build /go/bin/grpc-health-probe /bin/grpc_health_probe
ENTRYPOINT ["/bin/proglog"]
