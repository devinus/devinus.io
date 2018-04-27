FROM alpine:latest
LABEL maintainer="Devin Alexander Torres <d@devinus.io>"

RUN apk add --no-cache tar curl

ARG HUGO_VERSION
ENV HUGO_VERSION "${HUGO_VERSION}"
RUN curl -fsSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz" | tar -xzC /usr/local/bin hugo

FROM alpine:latest

COPY --from=0 /usr/local/bin/hugo /usr/local/bin

RUN mkdir -p /usr/src/web
WORKDIR /usr/src/web

COPY . .

EXPOSE 1313
CMD ["hugo", "server", "--bind=0.0.0.0", "-D"]
