package com.ssg.ccoe.demo.azure.springai.service;

import com.ssg.ccoe.demo.azure.springai.model.dto.ChatRequest;
import com.ssg.ccoe.demo.azure.springai.model.dto.ChatResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.azure.openai.AzureOpenAiChatModel;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ChatService {
    
    private static final Logger logger = LoggerFactory.getLogger(ChatService.class);
    
    private final AzureOpenAiChatModel chatModel;
    
    @Value("${spring.ai.azure.openai.chat.options.deployment-name:gpt-4o-mini}")
    private String deploymentName;
    
    public ChatService(AzureOpenAiChatModel chatModel) {
        this.chatModel = chatModel;
    }
    
    public com.ssg.ccoe.demo.azure.springai.model.dto.ChatResponse chat(ChatRequest request) {
        logger.info("Processing chat request with message: {}", request.message());
        
        try {
            Prompt prompt = new Prompt(new UserMessage(request.message()));
            org.springframework.ai.chat.model.ChatResponse response = chatModel.call(prompt);
            
            String responseText = response.getResult().getOutput().getContent();
            logger.info("Successfully generated response");
            
            return new com.ssg.ccoe.demo.azure.springai.model.dto.ChatResponse(
                responseText,
                deploymentName
            );
        } catch (Exception e) {
            logger.error("Error processing chat request", e);
            throw new RuntimeException("Failed to process chat request: " + e.getMessage(), e);
        }
    }
}
