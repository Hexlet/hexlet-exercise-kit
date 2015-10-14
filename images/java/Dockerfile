FROM hexlet/hexlet-base

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-install oracle-java8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
RUN add-apt-repository ppa:cwchien/gradle
RUN apt-install gradle

COPY build.gradle build.gradle
RUN gradle build copyToLib
