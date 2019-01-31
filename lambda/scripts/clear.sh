#!/bin/bash

docker ps
docker rm -f lambda-web lambda-api lambda-postgres lambda-redis lambda-mongo  lambda-python-container
docker ps