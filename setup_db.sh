#!/usr/bin/env bash


export DATABASE_NAME=testdb
export DATABASE_PORT=4511

psql -U master -h localhost -p $DATABASE_PORT $DATABASE_NAME < ./init_db.sql