FROM ubuntu
MAINTAINER hexlet

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
USER root

COPY scripts/apt-install /bin/apt-install
RUN chmod +x /bin/apt-install

RUN echo 'LC_ALL="en_US.UTF-8"' >> /etc/environment

RUN apt-install software-properties-common
RUN apt-install man make vim

RUN apt-install supervisor

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-install oracle-java8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN apt-install python-pip python-dev
RUN apt-install scala
RUN apt-install golang
RUN apt-install ghc
RUN apt-install perl
# RUN apt-install clojure1.4
RUN apt-install r-base

RUN apt-install racket
RUN raco pkg install --deps force --scope installation rackunit

RUN apt-install build-essential

ENV PHANTOM_JS phantomjs-1.9.8-linux-x86_64
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2 \
    && tar xvjf $PHANTOM_JS.tar.bz2 \
    && mv $PHANTOM_JS /usr/local/share \
    && ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin

# # RUN apt-install python-paramiko python-yaml python-jinja2 python-httplib2 python-setuptools sshpass
# # RUN apt-install cdbs debhelper dpkg-dev git-core reprepro python-support fakeroot asciidoc devscripts

# RUN useradd -ms /bin/bash user

RUN apt-install openssh-server curl
RUN pip install paramiko PyYAML Jinja2 httplib2

RUN apt-add-repository ppa:ansible/ansible
RUN apt-install ansible
COPY ansible.cfg /etc/ansible/ansible.cfg

RUN curl -sL https://deb.nodesource.com/setup_0.12 | bash -
# RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-install nodejs
# RUN ln -s /usr/bin/nodejs /usr/bin/node
ENV NODE_PATH /usr/lib/node_modules

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN add-apt-repository ppa:ondrej/php5-5.6
RUN apt-install php5 php5-dev php5-xdebug php5-readline

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
RUN composer global require "phpunit/phpunit=4.7.*"
# RUN mkdir /home/user/.npm
# RUN chown user:user /home/user/.npm
# VOLUME /home/user/.npm

# RUN apt-install bzip2 build-essential chrpath libssl-dev
# # libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev

# # NOTE: https://github.com/progrium/dokku/issues/280#issuecomment-36219930

RUN apt-install libwxbase2.8 libwxgtk2.8-dev libqt4-opengl-dev

RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-install ruby2.2 ruby2.2-dev
RUN gem install minitest wrong

RUN npm install -g mocha nightmare chai babel express morgan lodash && rm -rf /tmp/npm*

RUN wget -O erlang.deb http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_18.0-1~ubuntu~precise_amd64.deb && dpkg -i erlang.deb && rm -rf erlang.deb

VOLUME /tmp /var/tmp /usr/tmp

COPY supervisord.conf /etc/supervisor/supervisord.conf

WORKDIR /usr/src/app
CMD ["/usr/bin/supervisord", "-n"]

ONBUILD COPY services.conf /etc/supervisor/conf.d/services.conf
# ONBUILD ADD exercise /usr/src/app

ENV PYTHONDONTWRITEBYTECODE true
ENV HOME /root
