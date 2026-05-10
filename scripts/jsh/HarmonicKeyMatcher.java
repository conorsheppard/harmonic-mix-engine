///usr/bin/env jbang "$0" "$@" ; exit $?
//SOURCES ../../backend/src/main/java/com/conorsheppard/service/HarmonicKeyMatcher.java
//DEPS org.springframework.boot:spring-boot-dependencies:3.3.8@pom
//DEPS org.springframework.boot:spring-boot-starter-web

public class HarmonicKeyMatcher {
    public static void main(String[] args) {
        var matcher = new com.conorsheppard.service.HarmonicKeyMatcher();
        System.out.println(matcher.getCompatibleKeyStrings("Am"));
        System.out.println(matcher.getCompatibleKeyStrings("Bb"));
        System.out.println(matcher.getCompatibleKeyStrings("F# major"));
    }
}
