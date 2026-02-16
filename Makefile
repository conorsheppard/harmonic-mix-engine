SHELL := /bin/bash

default: run

SRC_DIR := app/src/main/java
PKG_DIR := com/conorsheppard/engine
MAIN    := com.conorsheppard.engine.HarmonicKeyMatcher
OUT_DIR := build/classes

jbang-run-script:
	jbang --cp=$(OUT_DIR) scripts/jsh/harmonic.jsh

compile:
	mkdir -p $(OUT_DIR)
	javac -d $(OUT_DIR) $(SRC_DIR)/$(PKG_DIR)/HarmonicKeyMatcher.java

java-run: compile
	java -cp $(OUT_DIR) $(MAIN)

jbang-run:
	jbang $(SRC_DIR)/$(PKG_DIR)/HarmonicKeyMatcher.java

test:
	./gradlew test

gradle-run:
	./gradlew bootRun

build:
	docker build --no-cache . -t conorsheppard/harmonic-mix-engine

run:
	docker run --rm --name harmonic-mix-engine -p 8080:8080 conorsheppard/harmonic-mix-engine

k8s-init:
	./scripts/k8s/kubes-init.sh

.SILENT:
.PHONY: default jbang-run-script compile java-run jbang-run test gradle-run build run
