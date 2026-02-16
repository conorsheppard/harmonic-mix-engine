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

run:
	./gradlew bootRun

.SILENT:
.PHONY: default jbang-run-script compile java-run jbang-run test run
