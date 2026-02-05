package com.ssg.ccoe.demo.azure.springai.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssg.ccoe.demo.azure.springai.model.dto.ChatRequest;
import com.ssg.ccoe.demo.azure.springai.model.dto.ChatResponse;
import com.ssg.ccoe.demo.azure.springai.service.ChatService;
import io.github.bucket4j.Bucket;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ChatControllerIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @MockBean
    private ChatService chatService;
    
    @MockBean
    private Bucket rateLimitBucket;
    
    @Test
    void testHealthEndpoint() throws Exception {
        mockMvc.perform(get("/api/chat/health"))
            .andExpect(status().isOk())
            .andExpect(content().string("Service is running"));
    }
    
    @Test
    void testChatEndpoint_Success() throws Exception {
        // Arrange
        ChatRequest request = new ChatRequest("Hello");
        ChatResponse response = new ChatResponse("Hello! How can I help?", "gpt-4o-mini");
        
        when(chatService.chat(any(ChatRequest.class))).thenReturn(response);
        when(rateLimitBucket.tryConsumeAndReturnRemaining(1))
            .thenReturn(io.github.bucket4j.ConsumptionProbe.consumed(9));
        
        // Act & Assert
        mockMvc.perform(post("/api/chat")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.response").value("Hello! How can I help?"))
            .andExpect(jsonPath("$.model").value("gpt-4o-mini"))
            .andExpect(jsonPath("$.timestamp").exists());
    }
    
    @Test
    void testChatEndpoint_ValidationError() throws Exception {
        // Arrange - empty message
        ChatRequest request = new ChatRequest("");
        
        // Act & Assert
        mockMvc.perform(post("/api/chat")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest());
    }
}
