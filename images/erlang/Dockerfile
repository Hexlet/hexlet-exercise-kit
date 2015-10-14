FROM hexlet/hexlet-base

COPY rebar.config rebar.config
RUN curl -k -o /usr/local/bin/rebar3 https://s3.amazonaws.com/rebar3/rebar3 && chmod +x /usr/local/bin/rebar3
RUN apt-install libwxbase2.8 libwxgtk2.8-dev libqt4-opengl-dev
RUN curl -o erlang.deb http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_18.0-1~ubuntu~precise_amd64.deb && dpkg -i erlang.deb && rm -rf erlang.deb
RUN rebar3 get-deps
