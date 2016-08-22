#!/bin/bash
docker build --rm -t bentlema/centos6-puppet-nocm:latest .
docker build --rm -t bentlema/centos6-puppet-nocm:1.1 .

docker push bentlema/centos6-puppet-nocm:latest
docker push bentlema/centos6-puppet-nocm:1.1

