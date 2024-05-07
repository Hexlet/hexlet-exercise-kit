# ==================================================
# Build image
# ==================================================
FROM golang:alpine AS build-image

# ENV GO111MODULE=on
ENV CGO_ENABLED=0

WORKDIR /go/src/github.com/gabrie30/ghorg

COPY . .

RUN go install github.com/gabrie30/ghorg@latest

# ==================================================
# Runtime image
# ==================================================
FROM alpine:latest AS runtime-image

ARG USER=ghorg
ARG GROUP=ghorg
ARG UID
ARG GID

ENV XDG_CONFIG_HOME=/config
ENV GHORG_CONFIG=/config/conf.yaml
ENV GHORG_RECLONE_PATH=/config/reclone.yaml

RUN apk add -U --no-cache ca-certificates openssh-client tzdata git \
    && mkdir -p /data $XDG_CONFIG_HOME \
    && addgroup --gid $GID $GROUP \
    && adduser -D -H --gecos "" \
                     --home "/home" \
                     --ingroup "$GROUP" \
                     --uid "$UID" \
                     "$USER" \
    && chown -R $USER:$GROUP /home /data $XDG_CONFIG_HOME \
    && rm -rf /tmp/* /var/{cache,log}/* /var/lib/apt/lists/*

USER ghorg

RUN mkdir -p /home/data/hexlethq
WORKDIR /home/data/hexlethq

COPY --from=build-image --chown=$USER:$GROUP /go/bin/ghorg /usr/local/bin
