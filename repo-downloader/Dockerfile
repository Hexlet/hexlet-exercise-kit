# NOTE:
FROM ghcr.io/gabrie30/ghorg:master-c66a7af

ENV GHORG_CONFIG_DIR=$HOME/.config/ghorg
ENV GHORG_CONFIG=$GHORG_CONFIG_DIR/conf.yaml
ARG USER=tirion
ARG GROUP=tirion
ARG UID
ARG GID

USER root

RUN addgroup --gid $GID $GROUP && adduser -D -H --gecos "" --ingroup "$GROUP" --uid "$UID" "$USER"

USER $USER

WORKDIR $HOME/data/hexlethq
RUN mkdir -p data/hexlethq

COPY config/conf.yaml $GHORG_CONFIG_DIR/conf.yaml
