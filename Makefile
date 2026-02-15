SHELL := /bin/bash

default: run

SRC_DIR := app/src/main/java
PKG_DIR := com/conorsheppard/engine
MAIN    := com.conorsheppard.engine.HarmonicKeyMatcher
OUT_DIR := build/classes

run:
	jbang --cp=$(OUT_DIR) scripts/jsh/harmonic.jsh

compile:
	mkdir -p $(OUT_DIR)
	javac -d $(OUT_DIR) $(SRC_DIR)/$(PKG_DIR)/HarmonicKeyMatcher.java

java-run: compile
	java -cp $(OUT_DIR) $(MAIN)

jbang-run:
	jbang $(SRC_DIR)/$(PKG_DIR)/HarmonicKeyMatcher.java

.SILENT:
.PHONY: default compile run jbang-run java-run
