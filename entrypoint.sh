#!/usr/bin/env sh

git pull
nox --reuse-existing-virtualenvs --sessions test-3.12
