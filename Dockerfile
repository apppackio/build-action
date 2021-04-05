FROM alpine:3.13

RUN apk add --no-cache python3 aws-cli curl jq yj bash docker git && ln -s /usr/bin/python3 /usr/bin/python
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
