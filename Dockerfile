FROM golang:1.11-alpine
ARG VERSION=v1.9.0
RUN apk add --no-cache git 
RUN apk add --update openssl
WORKDIR /go/src/github.com/filebrowser/filebrowser
RUN wget https://github.com/filebrowser/filebrowser/archive/${VERSION}.tar.gz
RUN tar -xvf ${VERSION}.tar.gz --strip 1
RUN go get ./...
WORKDIR /go/src/github.com/filebrowser/filebrowser/cmd/filebrowser
RUN CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags "-X main.version=${VERSION}"
 
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
