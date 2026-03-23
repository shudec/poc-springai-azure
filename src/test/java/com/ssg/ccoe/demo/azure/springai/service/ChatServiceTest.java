package com.ssg.ccoe.demo.azure.springai.service;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import static org.mockito.ArgumentMatchers.any;
import org.mockito.Mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.ai.azure.openai.AzureOpenAiChatModel;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.model.Generation;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.test.util.ReflectionTestUtils;

import com.ssg.ccoe.demo.azure.springai.model.dto.ChatRequest;

@ExtendWith(MockitoExtension.class)
class ChatServiceTest {
    
    @Mock
    private AzureOpenAiChatModel chatModel;
    
    private ChatService chatService;
    
    @BeforeEach
    void setUp() {
        chatService = new ChatService(chatModel);
        ReflectionTestUtils.setField(chatService, "deploymentName", "gpt-4o-mini");
    }
    
    @Test
    void testChat_Success() {
        // Arrange
        ChatRequest request = new ChatRequest("Hello, AI!");
        String expectedResponse = "Hello! How can I help you today?";
        
        Generation generation = new Generation(new AssistantMessage(expectedResponse));
        org.springframework.ai.chat.model.ChatResponse mockChatResponse = 
            new org.springframework.ai.chat.model.ChatResponse(List.of(generation));
        
        when(chatModel.call(any(Prompt.class))).thenReturn(mockChatResponse);
        
        // Act
        com.ssg.ccoe.demo.azure.springai.model.dto.ChatResponse response = chatService.chat(request);
        
        // Assert
        assertNotNull(response);
        assertEquals(expectedResponse, response.response());
        assertEquals("gpt-4o-mini", response.model());
        assertNotNull(response.timestamp());
        
        verify(chatModel, times(1)).call(any(Prompt.class));
    }
    
    @Test
    void testChat_ThrowsException() {
        // Arrange
        ChatRequest request = new ChatRequest("Hello, AI!");
        when(chatModel.call(any(Prompt.class))).thenThrow(new RuntimeException("AI service error"));
        
        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            chatService.chat(request);
        });
        
        assertTrue(exception.getMessage().contains("Failed to process chat request"));
        verify(chatModel, times(1)).call(any(Prompt.class));
    }
}
