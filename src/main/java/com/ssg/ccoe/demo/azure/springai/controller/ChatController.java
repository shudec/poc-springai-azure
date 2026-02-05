package com.ssg.ccoe.demo.azure.springai.controller;

import com.ssg.ccoe.demo.azure.springai.model.dto.ChatRequest;
import com.ssg.ccoe.demo.azure.springai.model.dto.ChatResponse;
import com.ssg.ccoe.demo.azure.springai.service.ChatService;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.ConsumptionProbe;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/chat")
public class ChatController {
    
    private static final Logger logger = LoggerFactory.getLogger(ChatController.class);
    
    private final ChatService chatService;
    private final Bucket rateLimitBucket;
    
    public ChatController(ChatService chatService, Bucket rateLimitBucket) {
        this.chatService = chatService;
        this.rateLimitBucket = rateLimitBucket;
    }
    
    @PostMapping
    public ResponseEntity<?> chat(@Valid @RequestBody ChatRequest request) {
        logger.info("Received chat request");
        
        // Check rate limit
        ConsumptionProbe probe = rateLimitBucket.tryConsumeAndReturnRemaining(1);
        if (!probe.isConsumed()) {
            logger.warn("Rate limit exceeded");
            long waitForRefill = probe.getNanosToWaitForRefill() / 1_000_000_000;
            return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS)
                .header("X-Rate-Limit-Retry-After-Seconds", String.valueOf(waitForRefill))
                .body("Rate limit exceeded. Try again in " + waitForRefill + " seconds.");
        }
        
        ChatResponse response = chatService.chat(request);
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Service is running");
    }
}
