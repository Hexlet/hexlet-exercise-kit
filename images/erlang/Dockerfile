FROM hexlet/hexlet-base

RUN apt-install libwxbase2.8 libwxgtk2.8-dev libqt4-opengl-dev
RUN wget -O erlang.deb http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_18.1-1~ubuntu~precise_amd64.deb
RUN dpkg -i erlang.deb #&& rm -rf erlang.deb
RUN curl -k -o /usr/local/bin/rebar3 https://s3.amazonaws.com/rebar3/rebar3 && chmod +x /usr/local/bin/rebar3
COPY rebar.config rebar.config
RUN rebar3 compile
