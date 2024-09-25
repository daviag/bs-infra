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

cd ../../bs-book-catalog-service
pwd
echo "Building catalog-service..."
docker build -t catalog-service .

echo "Running catalog-service..."
docker run -d \
  --name catalog-service \
  --net catalog-network \
  -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://bs_postgres:5432/bsdb_catalog \
  -e SPRING_PROFILES_ACTIVE=testdata \
  catalog-service

echo "Done."