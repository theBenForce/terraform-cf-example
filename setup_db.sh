#!/usr/bin/env bash

docker exec -it localstack apk add postgresql-contrib

export DATABASE_NAME=new_test

psql -U master -h localhost -p 4511 -c "CREATE EXTENSION pg_trgm;" $DATABASE_NAME
psql -U master -h localhost -p 4511 $DATABASE_NAME < ./init_db.sql