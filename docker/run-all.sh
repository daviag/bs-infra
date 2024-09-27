#!/usr/bin/env bash

echo "Creating network..."
docker network create catalog-network

echo "Running DB..."
docker run -d \
  --name bs_postgres \
  --net catalog-network \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=bsdb_catalog \
  -p 5432:5432 \
  postgres:16-alpine

#cd ../../bs-book-catalog-service
#
#echo "Building catalog-service..."
#docker build -t catalog-service .

echo "Running config-service..."
docker run -d \
  --name config-service \
  --net catalog-network \
  -p 8888:8888 \
  -e SPRING_CLOUD_CONFIG_SERVER_GIT_URI=https://github.com/daviag/bs-config-repo.git \
  config-service

echo "Running catalog-service..."
docker run -d \
  --name catalog-service \
  --net catalog-network \
  -p 9001:9001 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://bs_postgres:5432/bsdb_catalog \
  -e SPRING_PROFILES_ACTIVE=testdata \
  catalog-service

echo "Done."