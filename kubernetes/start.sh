#!/usr/bin/env bash

echo "Starting minikube context..."
minikube start --profile bookshop

echo "Creating Postgresql DB & Redis..."
kubectl apply -f services

echo "Creating Applications..."
tilt up -f applications/development/Tiltfile

echo "Done."