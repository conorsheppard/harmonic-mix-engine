package com.conorsheppard.controller;

import com.conorsheppard.service.HarmonicMixService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(produces = MediaType.APPLICATION_JSON_VALUE)
@Slf4j
public class HarmonicMixController {
    private final HarmonicMixService harmonicMixService;

    @Autowired
    public HarmonicMixController(HarmonicMixService service) {
        harmonicMixService = service;
    }

    @GetMapping(path = "/songs")
    public List<String> findMixingOptions(
            @RequestParam(name = "key", required = false) String originKey,
            @RequestParam(name = "limit", defaultValue = "1000") int limit
    ) {
        return harmonicMixService.getMixingOptions(originKey);
    }

    @ExceptionHandler({IllegalArgumentException.class, IllegalStateException.class})
    public ResponseEntity<String> handleExpectedErrors(Exception ex) {
        return ResponseEntity
                .badRequest()
                .body(ex.getMessage());
    }

    @ExceptionHandler(Throwable.class)
    public ResponseEntity<String> handleUnexpectedErrors(Throwable t) {
        log.error("Unexpected error", t);

        return ResponseEntity
                .internalServerError()
                .body("");
    }
}
