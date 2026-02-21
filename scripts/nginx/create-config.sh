#!/bin/bash

MINIKUBE_IP=$(minikube ip)

NODEPORT=$(
  kubectl -n ingress-nginx get svc ingress-nginx-controller \
    -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}'
)

echo "Minikube IP: $MINIKUBE_IP"
echo "Ingress HTTP NodePort: $NODEPORT"

sudo tee /etc/nginx/sites-available/minikube-ingress <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://$MINIKUBE_IP:$NODEPORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF