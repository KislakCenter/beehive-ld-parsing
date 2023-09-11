#!/usr/bin/env bash

script_dir=$(dirname $0)

source ${script_dir}/.env

rm -rf ${script_dir}/jena

tdbloader --loc ${script_dir}/jena "${1}"