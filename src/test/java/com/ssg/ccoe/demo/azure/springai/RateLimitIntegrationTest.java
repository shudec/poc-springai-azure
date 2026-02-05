package com.ssg.ccoe.demo.azure.springai;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssg.ccoe.demo.azure.springai.model.dto.ChatRequest;
import io.github.bucket4j.Bucket;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class RateLimitIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @MockBean
    private Bucket rateLimitBucket;
    
    @Test
    void testRateLimit_Exceeded() throws Exception {
        // Arrange
        ChatRequest request = new ChatRequest("Test message");
        
        // Simulate rate limit exceeded (0 remaining tokens, need to wait 30 seconds)
        when(rateLimitBucket.tryConsumeAndReturnRemaining(1))
            .thenReturn(io.github.bucket4j.ConsumptionProbe.rejected(0L, 0L, 30_000_000_000L));
        
        // Act & Assert
        mockMvc.perform(post("/api/chat")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isTooManyRequests())
            .andExpect(header().exists("X-Rate-Limit-Retry-After-Seconds"));
    }
    
    @Test
    void testRateLimit_WithinLimit() throws Exception {
        // Arrange
        ChatRequest request = new ChatRequest("Test message");
        
        // Simulate successful consumption (9 remaining tokens)
        when(rateLimitBucket.tryConsumeAndReturnRemaining(1))
            .thenReturn(io.github.bucket4j.ConsumptionProbe.consumed(9L, 9L));
        
        // Act & Assert - should not return rate limit error
        mockMvc.perform(post("/api/chat")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk());
    }
}
