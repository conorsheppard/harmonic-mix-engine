## Harmonic Mix Engine

A Spring Boot service packaged as a Docker image and runnable locally on Kubernetes via Minikube.

### Prerequisites
- Minikube
- kubectl
- Docker
- Java 21 (optional)
- Gradle (optional)
- Make (optional - without make you will have to copy/paste the targets and run them yourself)

### Running the Application

```shell
make
```

This will run the default `make` target `k8s-init` which runs the `kubes-init.sh` script in `scripts/k8s/`.  
You will see output from minikube and once it's ready, you can execute the following command to hit the application's
harmonic mixing endpoint.

```shell
curl http://localhost:8080/songs?key=C
```
