FROM golang:1.11-alpine
ARG VERSION=v1.10.0
ARG FE_VERSION=v1.5.0
RUN apk add --update --no-cache openssl git yarn && \
    mkdir -p /go/src/github.com/filebrowser/filebrowser && \
    cd /go/src/github.com/filebrowser/filebrowser && \
    wget https://github.com/filebrowser/filebrowser/archive/${VERSION}.tar.gz && \
    tar -xvf ${VERSION}.tar.gz --strip 1 && \
    mkdir -p /go/src/github.com/filebrowser/filebrowser/frontend && \
	cd /go/src/github.com/filebrowser/filebrowser/frontend && \
    wget https://github.com/filebrowser/frontend/archive/${FE_VERSION}.tar.gz && \
    tar -xvf ${FE_VERSION}.tar.gz --strip 1 && \
    yarn install && \
    yarn build && \
    cd /go/src/github.com/filebrowser/filebrowser && \
    go get github.com/GeertJohan/go.rice/rice && \
    rice embed-go && \
    go get ./...  && \
    cd /go/src/github.com/filebrowser/filebrowser/cmd/filebrowser && \
    CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags "-X main.version=${VERSION}"
	
FROM netyazilim/alpine-base:3.8
LABEL maintainer "Levent SAGIROGLU <LSagiroglu@gmail.com>"

EXPOSE 80 
ENV FB_ROOT "/shared/" 
ENV FB_DB "/etc/fb.db" 
VOLUME /shared 

COPY entrypoint.sh /bin/entrypoint.sh 
COPY --from=0 /go/src/github.com/filebrowser/filebrowser/cmd/filebrowser/filebrowser /bin/filebrowser
COPY README.md /shared/README.md 
ENTRYPOINT ["/bin/entrypoint.sh"]
