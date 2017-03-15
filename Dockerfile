FROM ubuntu:16.04

MAINTAINER Volodin Sergey

# Обвновление списка пакетов
RUN apt-get -y update && apt-get install -y net-tools

# basics
RUN apt-get install -y nginx openssh-server git-core openssh-client curl
RUN apt-get install -y nano
RUN apt-get install -y build-essential
RUN apt-get install -y openssl libreadline6 libreadline6-dev curl zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config


RUN apt-get install -y postgresql postgresql-contrib postgresql-client libpq5 libpq-dev
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -

RUN curl -L https://get.rvm.io | bash -s stable

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# install RVM, Ruby, and Bundler
#RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.3.3"

RUN rvm reload
CMD source /etc/profile
CMD source /usr/local/rvm/scripts/rvm
RUN apt-get install -y nodejs npm
RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN /bin/bash -l -c "rvm 2.3.3"
RUN /bin/bash -l -c "rvm use 2.3.3 --default"
RUN /bin/bash -l -c "rvm all do gem install bundler --no-ri --no-rdoc"

RUN ["/bin/bash", "-l", "-c", "gem list"]

ENV APP_HOME /usr/app
ENV HOME /root

RUN mkdir -p $APP_HOME

WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/


RUN /bin/bash -l -c "bundle install"

ADD . $APP_HOME

# Start server
ENV PORT 5000
EXPOSE 5000
CMD ["/bin/bash", "-l", "-c", "ruby hello_world.rb"]
