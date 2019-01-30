FROM openfalcon/makegcc-golang:1.10-alpine as builder
LABEL maintainer laiwei.ustc@gmail.com
USER root

RUN  apk add --no-cache ca-certificates bash git supervisor

WORKDIR /go

# Start
CMD ["/bin/bash"]
