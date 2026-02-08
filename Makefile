SHELL := /bin/bash

default: run

compile:
	javac HarmonicKeyMatcher.java

run:
	jbang harmonic.jsh

jbang-run:
	jbang HarmonicKeyMatcher.java

java-run:
	java HarmonicKeyMatcher

.SILENT:
.PHONY: default compile run
