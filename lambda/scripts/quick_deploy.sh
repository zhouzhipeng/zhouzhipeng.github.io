#!/usr/bin/env bash
set -e



# 先启动存储容器
docker run --name lambda-postgres -d -p  5432:5432  -e POSTGRES_PASSWORD=123456  postgres:9.6
docker run -d --name lambda-redis -p 6379:6379 redis:5
docker run -d --name lambda-mongo -p 27017:27017 mongo:4


# 初始化lambda-api表结构
# 等5秒钟让数据库运行起来先
sleep 5
FILE="https://zhouzhipeng.com/lambda/scripts/lamdb_api.sql"
curl -o tmp_lambda_api.sql $FILE
docker cp tmp_lambda_api.sql lambda-postgres:/tmp/api.sql
rm -rf tmp_lambda_api.sql

docker exec  lambda-postgres  bash  -c 'createdb  -U  postgres lambda-api && \
psql  -U  postgres -f /tmp/api.sql  lambda-api && \
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
    zhouzhipeng/lambda-api:1.0


# 启动lambda-web
docker run -d --name lambda-web  \
    --link lambda-mongo:lambda-mongo \
    --link lambda-api:lambda-api \
    -e MONGO_HOST="lambda-mongo"  \
    -e MONGO_PORT=27017 \
    -e MONGO_DATABASE_NAME="lambda-web" \
    -e ADMIN_ACCOUNT="admin@zhouzhipeng.com" \
    -e API_HOST="http://lambda-api:8080"   \
    -e CLOSE_REGISTER="true" \
    -p 3000:3000 \
    zhouzhipeng/lambda-web:1.0


# wait for running up!
sleep 3

echo "Congratulation! Running success! visit: http://localhost:3000 ,login with user: admin@zhouzhipeng.com and password: 123456"