#!/bin/sh

set -e

cp config/prod.exs.example config/prod.exs

sed -i "s#PIVOTAL_TOKEN#$PIVOTALTRACKER_SECRET_TOKEN#" config/prod.exs
sed -i "s#on_code_review#$PIVOTALTRACKER_LABEL_NAME#" config/prod.exs

docker build -t flexoid/pivotal-codereview .
docker rm -f pivotal_codereview || true
docker run -p 4002:4000 --restart=unless-stopped -d --name=pivotal_codereview flexoid/pivotal-codereview
