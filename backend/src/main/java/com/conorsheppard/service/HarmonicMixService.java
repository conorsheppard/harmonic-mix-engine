package com.conorsheppard.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class HarmonicMixService {
    private final HarmonicKeyMatcher harmonicKeyMatcher;

    @Autowired
    public HarmonicMixService(HarmonicKeyMatcher matcher) {
        harmonicKeyMatcher = matcher;
    }

    public List<String> getMixingOptions(String key) {
        return harmonicKeyMatcher.getCompatibleKeyStrings(key);
    }
}
