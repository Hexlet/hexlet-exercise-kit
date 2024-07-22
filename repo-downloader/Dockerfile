FROM ghcr.io/gabrie30/ghorg:latest

ENV GHORG_CONFIG_DIR=$HOME/.config/ghorg
ENV GHORG_CONFIG=$GHORG_CONFIG_DIR/conf.yaml
ARG USER=tirion
ARG GROUP=tirion
ARG UID
ARG GID

USER root

RUN addgroup --gid $GID $GROUP || true \
  && adduser -D -H --gecos "" --ingroup `getent group $GID | cut -d: -f1` --uid "$UID" "$USER"

USER $USER

WORKDIR $HOME/data/hexlethq
RUN mkdir -p data/hexlethq

COPY config/conf.yaml $GHORG_CONFIG_DIR/conf.yaml
