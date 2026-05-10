#!/bin/bash

export GRADLE_OPTS="${GRADLE_OPTS:---enable-native-access=ALL-UNNAMED}"

./gradlew :backend:compileJava -q
gradle_cp="$(./gradlew :backend:printClasspath -q)"
backend_classes="backend/build/classes/java/main"

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    classpath="${gradle_cp};${backend_classes}"
else
    classpath="${gradle_cp}:${backend_classes}"
fi

jshell --class-path "$classpath" --startup scripts/jsh/init.jsh
