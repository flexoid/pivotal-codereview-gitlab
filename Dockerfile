FROM elixir:1.4.2
MAINTAINER Egor Lynko <flexoid@gmail.com>

ENV MIX_ENV prod

WORKDIR /app
ADD . /app

RUN mix local.hex --force && \
  mix local.rebar --force && \
  mix deps.get

RUN mix compile

CMD mix run --no-halt
