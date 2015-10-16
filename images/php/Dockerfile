FROM hexlet/hexlet-base

RUN add-apt-repository ppa:ondrej/php5-5.6
RUN apt-install php5 php5-dev php5-xdebug php5-readline

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
RUN composer global require "phpunit/phpunit=4.7.*"
