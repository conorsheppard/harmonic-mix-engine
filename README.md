## Harmonic Mix Engine

A Spring Boot backend and Next.js frontend, packaged as Docker images and runnable locally on Kubernetes via Minikube.

### Prerequisites
- Minikube
- kubectl
- Docker
- Make

### Building

Build both Docker images:
```shell
make build-all
```

Or individually:
```shell
make build            # backend
make build-frontend   # frontend
```

### Running the Application

```shell
make
```

This deploys to Minikube and port-forwards both services:
- Backend: http://localhost:8080
- Frontend: http://localhost:3000

Hit the harmonic mixing endpoint:
```shell
curl http://localhost:8080/songs?key=C
```

### Cleanup

```shell
make cleanup
```
