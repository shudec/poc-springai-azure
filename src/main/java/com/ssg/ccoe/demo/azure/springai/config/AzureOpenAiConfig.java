package com.ssg.ccoe.demo.azure.springai.config;

import com.azure.ai.openai.OpenAIClient;
import com.azure.ai.openai.OpenAIClientBuilder;
import com.azure.core.credential.AzureKeyCredential;
import com.azure.identity.DefaultAzureCredentialBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
public class AzureOpenAiConfig {
    
    private static final Logger logger = LoggerFactory.getLogger(AzureOpenAiConfig.class);
    
    @Value("${spring.ai.azure.openai.endpoint}")
    private String endpoint;
    
    @Value("${spring.ai.azure.openai.api-key:}")
    private String apiKey;
    
    @Bean
    @Profile("dev")
    public OpenAIClient openAIClientWithApiKey() {
        logger.info("Configuring Azure OpenAI client with API Key authentication for dev profile");
        return new OpenAIClientBuilder()
            .endpoint(endpoint)
            .credential(new AzureKeyCredential(apiKey))
            .buildClient();
    }
    
    @Bean
    @Profile("prod")
    public OpenAIClient openAIClientWithManagedIdentity() {
        logger.info("Configuring Azure OpenAI client with Managed Identity authentication for prod profile");
        return new OpenAIClientBuilder()
            .endpoint(endpoint)
            .credential(new DefaultAzureCredentialBuilder().build())
            .buildClient();
    }
}
