FROM ruby:3.1.2-slim

RUN apt-get update \
  && apt-get install -yq git make gcc

ARG UID
ARG GID

RUN groupadd -g $GID tirion || true
RUN useradd -u $UID -g $GID -m tirion

USER tirion

WORKDIR /home/tirion/project/repo-downloader

COPY --chown=tirion ["Gemfile*", "*.gemspec", "./"]

RUN bundle

CMD ["make", "run"]
