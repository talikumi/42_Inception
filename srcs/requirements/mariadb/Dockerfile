FROM alpine:3.17

RUN apk update && apk upgrade && apk add --no-cache mysql mysql-client

COPY setup/config.sh /tmp/config.sh

ENTRYPOINT [ "sh" , "/tmp/config.sh" ]