import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class HarmonicKeyMatcher {

    private static final int OCTAVE = 12;

    // Compatibility scores
    private static final double SAME_KEY = 1.00;
    private static final double RELATIVE = 0.92;
    private static final double FIFTH = 0.85;
    private static final double PARALLEL = 0.75;

    public enum Mode { MAJOR, MINOR }

    public record Key(int keyNum, Mode mode, boolean preferFlats) {
        public String format() {
            String tonic = preferFlats ? PC_TO_FLAT[keyNum] : PC_TO_SHARP[keyNum];
            return tonic + " " + (mode == Mode.MAJOR ? "major" : "minor");
        }
    }

    // Canonical pitch class names (0=C, 1=C#/Db, ... 11=B)
    private static final String[] PC_TO_SHARP = {
            "C","C#","D","D#","E","F","F#","G","G#","A","A#","B"
    };
    private static final String[] PC_TO_FLAT = {
            "C","Db","D","Eb","E","F","Gb","G","Ab","A","Bb","B"
    };

    // Parse formats like:
    // "C", "C major", "Cmaj", "C#m", "F# minor", "Bb", "Bb min", "G#m"
    private static final Pattern KEY_PATTERN = Pattern.compile(
            "^\\s*([A-Ga-g])\\s*([#b♯♭])?\\s*(maj(or)?|min(or)?|m)?\\s*$"
    );

    private static final Map<String, Integer> NOTE_TO_PC = buildNoteToPc();

    // Pitch Class: https://en.wikipedia.org/wiki/Pitch_class
    private static Map<String, Integer> buildNoteToPc() {
        Map<String, Integer> m = new HashMap<>();

        // Sharps
        m.put("C", 0);
        m.put("C#", 1);
        m.put("D", 2);
        m.put("D#", 3);
        m.put("E", 4);
        m.put("F", 5);
        m.put("F#", 6);
        m.put("G", 7);
        m.put("G#", 8);
        m.put("A", 9);
        m.put("A#", 10);
        m.put("B", 11);

        // Flats (enharmonics)
        m.put("Db", 1);
        m.put("Eb", 3);
        m.put("Gb", 6);
        m.put("Ab", 8);
        m.put("Bb", 10);

        // Also accept unicode accidentals
        m.put("C♯", 1); m.put("D♯", 3); m.put("F♯", 6); m.put("G♯", 8); m.put("A♯", 10);
        m.put("D♭", 1); m.put("E♭", 3); m.put("G♭", 6); m.put("A♭", 8); m.put("B♭", 10);

        return m;
    }

    // Convenience
    public static List<String> compatibleKeyStrings(String inputKey) {
        Key key = parseKey(inputKey);
        List<String> res = new ArrayList<>();
        for (Key k : compatibleKeys(key)) {
            res.add(k.format());
        }
        return res;
    }

    public static Key parseKey(String input) {
        Matcher matcher = KEY_PATTERN.matcher(input);
        if (!matcher.matches()) {
            throw new IllegalArgumentException("Unrecognised key format: " + input);
        }

        String letter = matcher.group(1).toUpperCase(Locale.ROOT);
        String accidental = matcher.group(2);

        if (accidental == null) accidental = "";
        accidental = accidental.replace('♯', '#').replace('♭', 'b');

        String tonicName = letter + accidental;

        Integer pc = NOTE_TO_PC.get(tonicName);
        if (pc == null) {
            throw new IllegalArgumentException("Unsupported tonic: " + tonicName);
        }

        String modeRaw = matcher.group(3);
        Mode mode;
        if (modeRaw == null || modeRaw.isBlank() || modeRaw.equalsIgnoreCase("maj") || modeRaw.equalsIgnoreCase("major")) {
            // Default to major when not specified, like "C" or "Bb"
            mode = Mode.MAJOR;
        } else {
            mode = Mode.MINOR;
        }

        boolean preferFlats = tonicName.contains("b");
        return new Key(pc, mode, preferFlats);
    }

    public static List<Key> compatibleKeys(Key source) {
        List<Key> compatibleKeysList = new ArrayList<>();

        compatibleKeysList.add(source); // same key
        Key relative = getRelativeKey(source);
        compatibleKeysList.add(relative);

        Key dominant = pitchKey(source, +7);
        compatibleKeysList.add(dominant);
        Key dominantRelative = getRelativeKey(dominant);
        compatibleKeysList.add(dominantRelative);

        Key subdominant = pitchKey(source, -7);
        compatibleKeysList.add(subdominant);
        Key subdominantRelative = getRelativeKey(subdominant);
        compatibleKeysList.add(subdominantRelative);

        Key relativeUpASt = pitchKey(relative, 1); // up a semitone, for pitching down
        Key relativeDownASt = pitchKey(relative, -1); // down a semitone, for pitching up

        Key sourceUpASt = pitchKey(source, 1); // up a semitone, for pitching down
        Key sourceDownASt = pitchKey(source, -1); // down a semitone, for pitching up

        Key dominantUpASt = pitchKey(dominant, 1); // up a semitone, for pitching down
        Key dominantDownASt = pitchKey(dominant, -1); // down a semitone, for pitching up

        Key subdominantUpASt = pitchKey(subdominant, 1); // up a semitone, for pitching down
        Key subdominantDownASt = pitchKey(subdominant, -1); // down a semitone, for pitching up

        compatibleKeysList.addAll(
                List.of(sourceUpASt, sourceDownASt, relativeUpASt, relativeDownASt, dominantUpASt, dominantDownASt,
                        subdominantUpASt, subdominantDownASt));

        return compatibleKeysList;
    }

    private static Key pitchKey(Key source, int transposeBySemitones) {
        return new Key(transpose(source.keyNum, transposeBySemitones), source.mode, source.preferFlats);
    }

    private static Key getRelativeKey(Key source) {
        int relShift = (source.mode == Mode.MAJOR) ? -3 : +3;
        Mode relMode = (source.mode == Mode.MAJOR) ? Mode.MINOR : Mode.MAJOR;
        return new Key(transpose(source.keyNum, relShift), relMode, source.preferFlats);
    }

    private static int transpose(int keyNum, int transposeBySemitones) {
        int keyTransposed = (keyNum + transposeBySemitones) % OCTAVE;
        return keyTransposed < 0 ? keyTransposed + OCTAVE : keyTransposed; // pitch down guardrail
    }

    public static void main(String[] args) {
        System.out.println(compatibleKeyStrings("Am"));
        System.out.println(compatibleKeyStrings("Bb"));
        System.out.println(compatibleKeyStrings("F# major"));
    }
}
