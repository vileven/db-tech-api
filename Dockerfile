FROM ubuntu:16.04

MAINTAINER s.volodin

# Обвновление списка пакетов
RUN apt-get -y update && apt-get install -y net-tools

#
# Установка postgresql
#
ENV PGVER 9.5
RUN apt-get install -y postgresql-$PGVER

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-$PGVER`` package when it was ``apt-get installed``
USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -E UTF8 -T template0 -O docker docker &&\
    /etc/init.d/postgresql stop

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/$PGVER/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/$PGVER/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/$PGVER/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Back to the root user
USER root

#
# Сборка проекта
#
# basics
RUN apt-get install -y nginx openssh-server git-core openssh-client curl
RUN apt-get install -y nano
RUN apt-get install -y build-essential
RUN apt-get install -y openssl libreadline6 libreadline6-dev curl zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -

RUN curl -L https://get.rvm.io | bash -s stable


# install RVM, Ruby, and Bundler
ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.3.3"

RUN /bin/bash -l -c "rvm reload"
CMD source /etc/profile
CMD source /usr/local/rvm/scripts/rvm
#RUN apt-get install -y nodejs npm
#RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN /bin/bash -l -c "rvm 2.3.3"
RUN /bin/bash -l -c "rvm use 2.3.3 --default"
RUN /bin/bash -l -c -s "rvm all do gem install bundler --no-ri --no-rdoc"

RUN ["/bin/bash", "-l", "-c", "gem list"]

ENV APP_HOME /usr/app
ENV HOME /root

RUN mkdir -p $APP_HOME

WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/

RUN apt-get -y install libpq-dev
RUN /bin/bash -l -c -s "bundle install"

ADD . $APP_HOME

#ENV DATABASE_URL 'postgresql://localhost/docker?user=docker&password=docker'


# Start server
ENV DATABASE_URL 'postgresql://docker:docker@localhost/docker

ENV PORT 5000
EXPOSE 5000
CMD ["/bin/bash", "-l", "-c", "service postgresql start && ruby app.rb"]
