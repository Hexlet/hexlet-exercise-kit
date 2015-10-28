FROM hexlet/hexlet-base

RUN add-apt-repository ppa:ondrej/php5-5.6
RUN apt-install php5 php5-dev php5-xdebug php5-readline

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

ENV COMPOSER_HOME /usr/local/lib/php5
RUN composer global require "phpunit/phpunit=5.0.*"

ENV PATH /usr/local/lib/php5/vendor/bin:$PATH
