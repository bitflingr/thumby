FROM alpine
MAINTAINER Jarrett Irons <jarrett@gravity.com>

ENV BUILD_PACKAGES bash curl-dev ruby-dev build-base imagemagick
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler
ENV PORT 9090

# Update and install all of the required packages.
# At the end, remove the apk cache
RUN apk update && \
    apk upgrade && \
    apk add $BUILD_PACKAGES && \
    apk add $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

RUN mkdir /usr/app
WORKDIR /usr/app

COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN bundle install

COPY . /usr/app

EXPOSE $PORT

CMD bundle exec puma -e development -p $PORT -s ./tmp/puma.state -t 4:40 -w 4
