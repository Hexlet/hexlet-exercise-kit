FROM java:openjdk-8-jdk
MAINTAINER hexlet

ENV DEBIAN_FRONTEND noninteractive

COPY scripts/apt-install /bin/apt-install
RUN chmod +x /bin/apt-install

RUN apt-install apt-utils

RUN apt-install locales && \
    dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

# Set default locale for the environment
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apt-install supervisor

RUN apt-install python-pip python-dev
RUN apt-install ruby ruby-dev
RUN apt-install erlang
RUN apt-install scala
RUN apt-install php5 php5-dev
RUN apt-install golang
RUN apt-install ghc
RUN apt-install perl
RUN apt-install clojure1.4
# RUN apt-install r-base

RUN useradd -ms /bin/bash user

RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-install nodejs
RUN mkdir /home/user/.npm
RUN chown user:user /home/user/.npm
VOLUME /home/user/.npm

RUN apt-install racket
RUN raco pkg install --deps force --scope installation rackunit

RUN apt-install bzip2
ENV PHANTOMJS_VERSION 1.9.7
RUN wget --no-check-certificate -q -O - https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 | tar xjC /opt
RUN ln -s /opt/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/bin/phantomjs /usr/bin/phantomjs

RUN apt-install make vim

VOLUME /tmp /var/tmp /usr/tmp

COPY supervisord.conf /etc/supervisor/supervisord.conf

WORKDIR /usr/src/app
CMD ["/usr/bin/supervisord", "-n"]

ONBUILD COPY services.conf /etc/supervisor/conf.d/services.conf
# ONBUILD ADD exercise /usr/src/app

ENV PYTHONDONTWRITEBYTECODE true

ENV TERM xterm
