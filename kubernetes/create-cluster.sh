#!/usr/bin/env bash

echo "\n📦 Initializing Kubernetes cluster...\n"

minikube start --cpus 2 --memory 4g --driver docker --profile bookshop

echo "\n🔌 Enabling NGINX Ingress Controller...\n"

minikube addons enable ingress --profile bookshop

sleep 30

echo "\n📦 Deploying Keycloak..."

kubectl apply -f services/keycloak-config.yml
kubectl apply -f services/keycloak.yml

sleep 5

echo "\n⌛ Waiting for Keycloak to be deployed..."

while [ $(kubectl get pod -l app=bookshop-keycloak | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for Keycloak to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=bookshop-keycloak \
  --timeout=600s

echo "\n⌛ Ensuring Keycloak Ingress is created..."

kubectl apply -f services/keycloak.yml

echo "\n📦 Deploying PostgreSQL..."

kubectl apply -f services/postgresql.yml

sleep 5

echo "\n⌛ Waiting for PostgreSQL to be deployed..."

while [ $(kubectl get pod -l db=bookshop-postgres | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for PostgreSQL to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=bookshop-postgres \
  --timeout=180s

echo "\n📦 Deploying Redis..."

kubectl apply -f services/redis.yml

sleep 5

echo "\n⌛ Waiting for Redis to be deployed..."

while [ $(kubectl get pod -l db=bookshop-redis | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for Redis to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=bookshop-redis \
  --timeout=180s

echo "\n📦 Deploying RabbitMQ..."

kubectl apply -f services/rabbitmq.yml

sleep 5

echo "\n⌛ Waiting for RabbitMQ to be deployed..."

while [ $(kubectl get pod -l db=bookshop-rabbitmq | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for RabbitMQ to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=bookshop-rabbitmq \
  --timeout=180s

echo "\n📦 Deploying Polar UI..."

kubectl apply -f services/bookshop-ui.yml

sleep 5

echo "\n⌛ Waiting for Polar UI to be deployed..."

while [ $(kubectl get pod -l app=bookshop-ui | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for Polar UI to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=bookshop-ui \
  --timeout=180s

echo "\n⛵ Happy Sailing!\n"

#minikube tunnel --profile bookshop
#minikube dashboard --profile bookshop