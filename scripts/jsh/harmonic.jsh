import com.conorsheppard.service.HarmonicKeyMatcher;

var matcher = new HarmonicKeyMatcher();

System.out.println("=== Harmonic Key Matcher Demo ===");
System.out.println();

System.out.println("parseKey(\"Bb\") => " + matcher.parseKey("Bb"));
System.out.println();

System.out.println("getCompatibleKeyStrings(\"A minor\") =>");
System.out.println(matcher.getCompatibleKeyStrings("A minor"));
System.out.println();

System.out.println("getCompatibleKeyStrings(\"Bb\") =>");
System.out.println(matcher.getCompatibleKeyStrings("Bb"));
System.out.println();

System.out.println("getCompatibleKeyStrings(\"F# major\") =>");
System.out.println(matcher.getCompatibleKeyStrings("F# major"));
