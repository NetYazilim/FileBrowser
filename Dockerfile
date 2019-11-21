FROM netyazilim/alpine-base:3.10

ARG VERSION=v2.0.16

WORKDIR /tmp
RUN apk add --upgrade --no-cache ca-certificates  wget tar
RUN wget --no-cache --quiet https://github.com/filebrowser/filebrowser/releases/download/${VERSION}/linux-amd64-filebrowser.tar.gz && \
tar -xvzf  linux-amd64-filebrowser.tar.gz

#FROM netyazilim/alpine-base:3.10

FROM scratch
LABEL maintainer "Levent SAGIROGLU <LSagiroglu@gmail.com>"

EXPOSE 80 
ENV FB_ROOT "/shared" 
ENV FB_DATABASE "/fb.db" 
ENV FB_PORT "80"
VOLUME /shared 

COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=0 /tmp/filebrowser /filebrowser
COPY .filebrowser.json /.filebrowser.json
COPY README.md /shared/README.md 
ENTRYPOINT ["/filebrowser"]
