FROM alpine:3.14.6

RUN apk update
RUN apk add --no-cache ruby-full ruby-dev ruby-bundler build-base \
    && gem install bundler --version 1.17.3 --no-document

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/

RUN bundle update --bundler && bundle install
ADD . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
