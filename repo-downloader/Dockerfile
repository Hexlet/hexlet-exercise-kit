FROM ruby:3.1.2-slim

ENV PATH_TO_REPOS=/home/tirion/app

RUN apt-get update \
  && apt-get install -yq git make gcc

ARG UID
ARG GID

RUN groupadd -g $GID tirion || true
RUN useradd -u $UID -g $GID -m tirion

USER tirion

RUN mkdir $PATH_TO_REPOS
WORKDIR $PATH_TO_REPOS

COPY --chown=tirion ["Gemfile*", "*.gemspec", "./"]

RUN bundle

CMD ["make", "run"]
