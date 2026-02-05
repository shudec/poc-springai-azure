package com.ssg.ccoe.demo.azure.springai.model.dto;

import java.time.Instant;

public record ChatResponse(
    String response,
    Instant timestamp,
    String model
) {
    public ChatResponse(String response, String model) {
        this(response, Instant.now(), model);
    }
}
