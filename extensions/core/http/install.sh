#!/usr/bin/env bash

set -e

export EXTENSION=http
export DEPENDENCIES="php$PHP_VERSION-raphf"
phpenmod -v $PHP_VERSION raphf

../docker-install.sh
