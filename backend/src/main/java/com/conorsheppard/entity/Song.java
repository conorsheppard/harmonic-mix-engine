package com.conorsheppard.entity;

import com.conorsheppard.service.HarmonicKeyMatcher;

public class Song {
    private String fileName;
    private String title;
    private String artist;
    private String coverArt;
    private HarmonicKeyMatcher.Key nativeKey;
    private double nativeBPM;
    private HarmonicKeyMatcher.Key currentKey;
    private double currentBPM;

    public Song() {}

    public void shiftKey(int shiftBySemitones) {
        currentKey = new HarmonicKeyMatcher().pitchKey(currentKey, shiftBySemitones);
        currentBPM = currentBPM * playbackRatePercent(shiftBySemitones);
    }

    public static double playbackRatePercent(int semitones) {
        return Math.pow(2.0, semitones / 12.0) * 100.0;
    }
}
