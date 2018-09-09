FROM golang:1.11-alpine
ARG VERSION=1.10.0
ARG FE_VERSION=v1.5.0

RUN apk add --upgrade --no-cache ca-certificates openssl curl git yarn
RUN mkdir -p /go/src/github.com/filebrowser/filebrowser && \
    cd /go/src/github.com/filebrowser/filebrowser && \
	wget https://github.com/filebrowser/filebrowser/archive/v${VERSION}.tar.gz && \
	tar -xvf v${VERSION}.tar.gz --strip 1 && \
    mkdir -p /go/src/github.com/filebrowser/filebrowser/frontend && \
	cd /go/src/github.com/filebrowser/filebrowser/frontend && \
    wget https://github.com/filebrowser/frontend/archive/${FE_VERSION}.tar.gz && \
    tar -xvf ${FE_VERSION}.tar.gz --strip 1 && \
    go get github.com/GeertJohan/go.rice/rice && \
    curl -fsSL -o /go/bin/dep $( \
    curl -s https://api.github.com/repos/golang/dep/releases/latest \
    | grep "browser_download_url.*linux-amd64\"" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    ) && \
    chmod +x /go/bin/dep && \
    curl -sL https://git.io/goreleaser -o /go/bin/goreleaser && \
    chmod +x /go/bin/goreleaser && \
    cd /go/src/github.com/filebrowser/filebrowser/build && \
    ./build_assets.sh && \
	cd /go/src/github.com/filebrowser/filebrowser && \
	dep ensure -vendor-only && \
    cd /go/src/github.com/filebrowser/filebrowser/cmd/filebrowser && \
    CGO_ENABLED=0 go build -a -o filebrowser -ldflags "-X main.version=${VERSION}"
	
FROM netyazilim/alpine-base:3.8
LABEL maintainer "Levent SAGIROGLU <LSagiroglu@gmail.com>"

EXPOSE 80 
ENV FB_SCOPE "/shared/" 
ENV FB_DATABASE "/etc/fb.db" 
ENV FB_PORT "80"
VOLUME /shared 

COPY --from=filebrowser/dev /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=0 /go/src/github.com/filebrowser/filebrowser/cmd/filebrowser/filebrowser /bin/filebrowser
COPY entrypoint.sh /bin/entrypoint.sh 
COPY README.md /shared/README.md 
ENTRYPOINT ["/bin/entrypoint.sh"]
