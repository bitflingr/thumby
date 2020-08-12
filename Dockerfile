#FROM alpine
FROM ruby:2.5
MAINTAINER Jarrett Irons <jarrett.irons@gmail.com>

#ENV BUILD_PACKAGES bash curl-dev ruby-dev build-base imagemagick
#ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler
ENV PORT 9090

RUN mkdir /usr/app
WORKDIR /usr/app
COPY . /usr/app
COPY Gemfile /usr/app/

# Update and install all of the required packages.
# At the end, remove the apk cache
#RUN apk update \
    #&& apk upgrade \
    #&& apk add $BUILD_PACKAGES \
    #&& apk add $RUBY_PACKAGES \
    #&& rm -rf /var/cache/apk/* \
    #&& rm Gemfile.lock \
    #&& bundle install --without development test 
RUN rm Gemfile.lock && bundle install --without development test

EXPOSE $PORT

CMD bundle exec puma -e development -p $PORT -s ./tmp/puma.state -t 4:40 -w 4
