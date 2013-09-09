# DOCKER-VERSION 0.6.1

FROM ubuntu:12.10

RUN apt-get update
RUN apt-get -y install ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1 build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev libsqlite3-dev libpq-dev ruby-rack ruby-bundler
RUN update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400  --slave /usr/share/man/man1/ruby.1.gz ruby.1.gz /usr/share/man/man1/ruby1.9.1.1.gz  --slave /usr/bin/ri ri /usr/bin/ri1.9.1  --slave /usr/bin/irb irb /usr/bin/irb1.9.1  --slave /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1
RUN update-alternatives --config ruby
RUN update-alternatives --config gem

ADD . /src

RUN cd /src; bundle install

EXPOSE  8080
CMD cd /src && bundle exec rackup -p 8080
