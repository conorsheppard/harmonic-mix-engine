import com.conorsheppard.engine.HarmonicKeyMatcher;

System.out.println("=== Harmonic Key Matcher Demo ===");
System.out.println();

System.out.println("parseKey(\"Bb\") => " + HarmonicKeyMatcher.parseKey("Bb"));
System.out.println();

System.out.println("compatibleKeyStrings(\"A minor\") =>");
System.out.println(HarmonicKeyMatcher.compatibleKeyStrings("A minor"));
System.out.println();

System.out.println("compatibleKeyStrings(\"Bb\") =>");
System.out.println(HarmonicKeyMatcher.compatibleKeyStrings("Bb"));
System.out.println();

System.out.println("compatibleKeyStrings(\"F# major\") =>");
System.out.println(HarmonicKeyMatcher.compatibleKeyStrings("F# major"));
