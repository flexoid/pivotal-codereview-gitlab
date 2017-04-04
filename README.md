[![Build Status](https://travis-ci.org/flexoid/pivotal-codereview-gitlab.svg?branch=master)](https://travis-ci.org/flexoid/pivotal-codereview-gitlab)

# Pivotal Tracker - Gitlab Code Review

**Code Review integration helper for Gitlab**

Set specified label (default `on_code_review` ) to Pivotal Tracker when merge request is opened, and remove tag when request is marged or closed.

Can be useful, as Pivotal Tracker stories cannot have any custom statuses between "started" and "finished", to mark that story are finished, but not merged in main branch yet.

## Installation

Firstly, prepare config:

```
cp config/prod.exs.example config/prod.exs
vim config/prod.exs
```

### Run on the local system

Install elixir lang package and run:

```
export MIX_ENV=prod

mix compile
mix run --no-halt
```

### Run as docker image

```
docker build -t flexoid/pivotal-codereview .
docker rm -f pivotal_codereview # in case of update
docker run -p 4002:4000 --restart=unless-stopped -d --name=pivotal_codereview flexoid/pivotal-codereview
```

In this example, `4002` port will be exposed from the docker. Can be changed to any free port.

## Connecting to GitLab

Add webhook URL on Integrations page in the GitLab project settings:

    http://example.com:4002/merge_request/12345678

where `example.com:4002` is your deployed service address, and `12345678` is a Pivotal Tracker project ID which you want to integrate with.
