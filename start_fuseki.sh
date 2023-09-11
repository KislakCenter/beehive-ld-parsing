#!/usr/bin/env bash

script_dir=$(dirname $0)

source ${script_dir}/.env

fuseki-server --config=${script_dir}/fuseki_config.ttl
