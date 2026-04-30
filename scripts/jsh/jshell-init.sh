#!/bin/bash

gradle_cp="$(./gradlew :backend:printClasspath -q)"

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    classpath="${gradle_cp};build\classes"
else
    classpath="${gradle_cp}:build/classes"
fi

jshell --class-path "$classpath" --startup scripts/jsh/init.jsh
