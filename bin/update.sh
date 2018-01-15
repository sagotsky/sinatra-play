#!/usr/bin/env sh

git reset --hard HEAD && \
  git pull && \
  bundle && \
  touch tmp/restart.txt

