#!/usr/bin/env bash

echo "Deleting Applications..."
tilt down -f applications/development/Tiltfile

echo "Deleting Postgresql DB & Redis..."
kubectl delete -f services

echo "Stopping minikube context..."
minikube stop --profile bookshop

echo "Done."