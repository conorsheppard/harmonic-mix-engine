#!/bin/bash

minikube start

kubectl apply -f k8s/

kubectl port-forward svc/harmonic-mix-engine 8080:8080
