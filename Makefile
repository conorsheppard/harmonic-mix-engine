SHELL := /bin/bash

export GRADLE_OPTS := --enable-native-access=ALL-UNNAMED

SRC_DIR := scripts
PKG_DIR := jsh
MAIN    := HarmonicKeyMatcher
OUT_DIR := build/classes
BACKEND_CLASSES := backend/build/classes/java/main

default: k8s-init

gradle-compile:
	./gradlew :backend:compileJava -q

jbang-run-script: gradle-compile
	jbang --cp=$(BACKEND_CLASSES) scripts/jsh/harmonic.jsh

compile: gradle-compile
	mkdir -p $(OUT_DIR)
	javac -d $(OUT_DIR) -cp $(BACKEND_CLASSES) $(SRC_DIR)/$(PKG_DIR)/HarmonicKeyMatcher.java

java-run: compile
	cpsep=$$(uname -s | grep -qE 'MINGW|CYGWIN|MSYS' && echo ';' || echo ':') && \
	java -cp "$(OUT_DIR)$${cpsep}$(BACKEND_CLASSES)" $(MAIN)

java-single-file-mode: gradle-compile
	java -cp $(BACKEND_CLASSES) $(SRC_DIR)/$(PKG_DIR)/HarmonicKeyMatcher.java

jbang-run:
	jbang $(SRC_DIR)/$(PKG_DIR)/HarmonicKeyMatcher.java

jshell-init:
	./scripts/jsh/jshell-init.sh

test:
	./gradlew test

test-jbang-run-script:
	./scripts/test/test-jbang-run-script.sh

test-java-single-file-mode:
	./scripts/test/test-java-single-file-mode.sh

test-jbang-run:
	./scripts/test/test-jbang-run.sh

test-java-run:
	./scripts/test/test-java-run.sh

test-make-target-test-scripts: test-java-single-file-mode test-jbang-run-script test-jbang-run test-java-run
	
gradle-run:
	./gradlew bootRun

build:
	docker build --no-cache -f backend/Dockerfile -t conorsheppard/harmonic-mix-engine .

build-frontend:
	docker build --no-cache frontend/ -t conorsheppard/harmonic-mix-engine-frontend

npm-install:
	[ -d frontend ] && cd frontend && npm install || npm install

next-run:
	[ -d frontend ] && cd frontend && npm run dev || npm run dev

build-all: build build-frontend

k8s-init:
	./scripts/k8s/kubes-init.sh

azure-vm-up:
	./scripts/k8s/azure-vm-init.sh

cleanup:
	kubectl delete -f k8s/
	minikube stop

minikube-reset:
	minikube delete
	minikube start

write-classpath:
	./gradlew :backend:printClasspath -q | pbcopy
	unixify-path
	pbpaste > classpath.txt

.SILENT:
.PHONY: default jbang-run-script test-jbang-run-script compile java-run test-java-run jbang-run test-jbang-run java-single-file-mode test-java-single-file-mode test-make-target-test-scripts jshell-init test gradle-run build build-frontend npm-install next-run build-all k8s-init azure-vm-up cleanup minikube-reset write-classpath
