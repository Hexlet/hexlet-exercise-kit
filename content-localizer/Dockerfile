FROM smartcatcom/serge:v2

RUN apk add --update-cache bash make perl-utils perl-app-cpanminus gettext

RUN git clone https://github.com/corsicanec82/perl-loctools-markdown.git /usr/local/lib/perl-loctools-markdown
RUN cd /usr/local/lib/perl-loctools-markdown \
  && cpanm --installdeps . \
  && ./Build install

ARG UID
ARG GID
ENV UID=$UID
ENV GID=$GID

RUN addgroup -g $GID tirion || true
RUN adduser -u $UID -D -G `getent group $GID | cut -d: -f1` tirion || true

COPY scripts/* /usr/local/bin/
COPY config.serge /opt/config.serge

ENTRYPOINT ["entrypoint"]
