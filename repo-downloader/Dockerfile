FROM ruby:3.0.1-slim

RUN apt-get update \
  && apt-get install -yq git make

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
ENV GITLAB_API_ENDPOINT=https://gitlab.com/api/v4

CMD ["make", "run"]
