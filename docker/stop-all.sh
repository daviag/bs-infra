#!/usr/bin/env bash

echo "Stopping and removing containers..."
docker rm -f catalog-service bs_postgres
echo "Done."