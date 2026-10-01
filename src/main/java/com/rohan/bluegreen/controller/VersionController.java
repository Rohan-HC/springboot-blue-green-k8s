package com.rohan.bluegreen.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class VersionController {

    @Value("${app.version:1.0}")
    private String version;

    @Value("${app.environment:blue}")
    private String environment;

    @GetMapping("/version")
    public Map<String, String> getVersion() {
        return Map.of(
                "version", version,
                "environment", environment
        );
    }
}