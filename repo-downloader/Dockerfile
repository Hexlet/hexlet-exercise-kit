FROM ruby:3.1.2-slim

RUN apt-get update \
  && apt-get install -yq git make gcc

ARG UID
ARG GID

RUN groupadd -g $GID tirion || true
RUN useradd -u $UID -g $GID -m tirion

USER tirion

RUN mkdir /home/tirion/repos
WORKDIR /home/tirion/app

COPY --chown=tirion ["Gemfile*", "*.gemspec", "./"]

RUN bundle

ENV PATH_TO_REPOS=/home/tirion/repos

CMD ["make", "run"]
