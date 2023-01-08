FROM golang:1.19-alpine3.17 as build

WORKDIR /
RUN apk add wget
RUN wget https://github.com/jgm/pandoc/releases/download/2.19.2/pandoc-2.19.2-1-amd64.deb

# Change current working directory, copy source dependency files, download dependencies using go modules,
# copy source code and build the binary with minimum size.
WORKDIR /go/src/doctor
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# RUN --mount=type=cache,target=/root/.cache/go-build \
#     CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -installsuffix cgo -ldflags="-w -s" -o /bin/doctor main.go
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -installsuffix cgo -ldflags="-w -s" -o /bin/doctor main.go


# Second stage is the runtime
FROM ubuntu:latest as runner

COPY --from=build /pandoc-2.19.2-1-amd64.deb ./

RUN \
    # Installing necessary packages for runtime
    apt update && \
    apt install -y \
        ripgrep && \
    dpkg -i pandoc-2.19.2-1-amd64.deb

# Copy the binary and static file of the project to proper path
COPY --from=build /bin/doctor /bin/doctor

COPY --from=build /go/src/doctor/entrypoint.sh /bin/entrypoint.sh

VOLUME [ "/projects", "/results" ]

ENTRYPOINT ["/bin/entrypoint.sh", "/projects"]
