#!/usr/bin/env bash

CURRENT_DIR=$(pwd)
CATALOG_DIR=../../bs-book-catalog-service

VAR1="../../bs-config-service ../../bs-edge-service ../../bs-dispatcher-service ../../bs-book-catalog-service ../../bs-order-service"
VAR2="config-service edge-service dispatcher-service catalog-service order-service"

fun()
{
    set $VAR2
    for i in $VAR1; do
        echo "\n Building $1 image..."

        cd $i
        ./gradlew jibDockerBuild --image $1

        echo "\n Importing $1 image into minikube..."

        minikube image load $1 --profile bookshop

        echo "\n📦 Deploying $1..."
        kubectl apply -f k8s

        sleep 5

        echo "\n⌛ Waiting for $1 to be deployed..."

        while [ $(kubectl get pod -l app=$1 | wc -l) -eq 0 ] ; do
          sleep 5
        done

        echo "\n⌛ Waiting for $1 to be ready..."

        kubectl wait \
          --for=condition=ready pod \
          --selector=app=$1 \
          --timeout=180s

        cd $CURRENT_DIR

#        echo command "$i" "$1"
        shift
    done
}

fun
exit



echo "\n Building catalog image..."

cd $CATALOG_DIR
./gradlew jibDockerBuild --image catalog-service

echo "\n Importing catalog image into minikube..."

minikube image load catalog-service --profile bookshop

echo "\n📦 Deploying catalog-service..."
kubectl apply -f k8s

sleep 5

echo "\n⌛ Waiting for catalog-service to be deployed..."

while [ $(kubectl get pod -l app=catalog-service | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for catalog-service to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=catalog-service \
  --timeout=180s

cd $CURRENT_DIR

echo "\n🏴️ Started\n"