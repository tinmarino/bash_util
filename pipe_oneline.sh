#!/usr/bin/env bash

while read line; do
  echo -ne "\r$line"
done < "${1:-/dev/stdin}"
