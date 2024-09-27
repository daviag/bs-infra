#!/usr/bin/env bash

echo "Stopping and removing containers..."
docker rm -f catalog-service config-service bs_postgres
echo "Done."