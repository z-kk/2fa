# build stage
FROM nimlang/choosenim AS build
RUN choosenim update 2.0.0

RUN nimble update
RUN nimble install docopt
RUN nimble install db_connector
RUN nimble install libsha
RUN nimble install nauthy

ADD . /build
WORKDIR /build
RUN nimble install

# prod stage
FROM debian:stable-slim AS prod

RUN apt-get update \
    && apt-get install -y mariadb-client libmariadb-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /build/bin/tfa /usr/local/bin/
