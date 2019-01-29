#!/usr/bin/env bash
set -e



# 先启动存储容器
docker run --name lambda-postgres -d -p  5432:5432  -e POSTGRES_PASSWORD=123456  postgres:9.6
docker run -d --name lambda-redis -p 6379:6379 redis
docker run -d --name lambda-mongo -p 27017:27017 mongo


# 初始化lambda-api表结构
FILE="https://zhouzhipeng.com/lambda/scripts/lamdb_api.sql"
curl -o tmp_lambda_api.sql $FILE
docker cp tmp_lambda_api.sql lambda-postgres:/tmp/api.sql
rm -rf tmp_lambda_api.sql

docker exec  postgres9.6  bash  -c 'createdb  -U  postgres lambda-api && \
psql  -U  postgres -f /tmp/api.sql  test && \
rm -rf /tmp/api.sql '



# 启动lambda-api
docker run -d  --name lambda-api \
    --link lambda-postgres:lambda-postgres \
    --link lambda-redis:lambda-redis \
    -e POSTGRES_URL="jdbc:postgresql://lambda-postgres:5432/lambda-api" \
    -e POSTGRES_USERNAME="postgres" \
    -e POSTGRES_PASSWORD="123456" \
    -e REDIS_HOST="lambda-redis"  \
    -e REDIS_PORT="6379"  \
    -v /data/logs:/data/logs \
    -v /var/run/docker.sock:/var/run/docker.sock\
    -p 8080:8080 \
    registry.cn-shanghai.aliyuncs.com/zhouzhipeng/lambda-api:product-1548402483-a5d447a


# 启动lambda-web
docker run -d --name lambda-web  \
    --link lambda-mongo:lambda-mongo \
    --link lambda-api:lambda-api \
    -e MONGO_HOST="lambda-mongo"  \
    -e MONGO_PORT=27017 \
    -e MONGO_DATABASE_NAME="lambda-web" \
    -e API_HOST="http://lambda-api:8080"   \
    -p 3000:3000 \
    registry.cn-shanghai.aliyuncs.com/zhouzhipeng/lambda-web:product-1548656271-6cbe234