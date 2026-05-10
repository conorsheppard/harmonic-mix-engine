SHELL := /bin/bash

export GRADLE_OPTS := --enable-native-access=ALL-UNNAMED

SRC_DIR := scripts
PKG_DIR := jsh
MAIN    := HarmonicKeyMatcher
OUT_DIR := build/classes
BACKEND_CLASSES := backend/build/classes/java/main

# Java's classpath separator is ';' on Windows and ':' elsewhere.
# Check $(OS) and uname so this works whether make sees the env var or only the shell.
UNAME_S := $(shell uname -s 2>/dev/null)
ifeq ($(OS),Windows_NT)
  CPSEP := ;
else ifneq (,$(filter MINGW% CYGWIN% MSYS%,$(UNAME_S)))
  CPSEP := ;
else
  CPSEP := :
endif

default: k8s-init

gradle-compile:
	./gradlew :backend:compileJava -q

jbang-run-script: gradle-compile
	jbang --cp=$(BACKEND_CLASSES) scripts/jsh/harmonic.jsh

compile: gradle-compile
	mkdir -p $(OUT_DIR)
	javac -d $(OUT_DIR) -cp $(BACKEND_CLASSES) $(SRC_DIR)/$(PKG_DIR)/HarmonicKeyMatcher.java

java-run: compile
	java -cp "$(OUT_DIR)$(CPSEP)$(BACKEND_CLASSES)" $(MAIN)

jbang-run:
	jbang $(SRC_DIR)/$(PKG_DIR)/HarmonicKeyMatcher.java

jshell-init:
	./scripts/jsh/jshell-init.sh

test:
	./gradlew test

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
.PHONY: default jbang-run-script compile java-run jbang-run jshell-init test gradle-run build build-frontend npm-install next-run build-all k8s-init cleanup minikube-reset write-classpath
