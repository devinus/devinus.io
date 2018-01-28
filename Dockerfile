FROM alpine:latest
LABEL maintainer="Devin Alexander Torres <d@devinus.io>"

RUN apk add --no-cache tar curl

ARG HUGO_VERSION
ENV HUGO_VERSION "${HUGO_VERSION}"
RUN curl -sSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz" | tar -xzC /usr/local/bin hugo

RUN mkdir /usr/src
RUN addgroup -S web
RUN adduser -Sh /usr/src/web web
USER web
WORKDIR /usr/src/web

COPY --chown=web:web . .

EXPOSE 1313
CMD ["hugo", "server", "--bind=0.0.0.0", "-D"]
