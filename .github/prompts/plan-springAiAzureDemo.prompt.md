# Plan: Spring AI Azure Demo - Complete Infrastructure & Deployment

Projet Maven Spring Boot 3.x (Java 21) avec Spring AI Azure OpenAI (gpt-4o-mini), package `com.ssg.ccoe.demo.azure.springai`, authentification dual (API key dev + Managed Identity prod), rate limiting, Application Insights monitoring, tests complets, Terraform avec RBAC automatique et state local, GitHub Actions vers App Service et Container Apps via ACR.

## Steps

1. Créer [pom.xml](pom.xml) avec dependencies : spring-boot-starter-web, spring-ai-azure-openai, azure-identity, applicationinsights-spring-boot-starter, bucket4j-spring-boot-starter (rate limiting), spring-boot-starter-test, spring-ai-azure-openai-spring-boot-starter, et plugins spring-boot-maven-plugin, jib-maven-plugin (ACR target), maven-surefire-plugin, maven-failsafe-plugin

2. Structurer packages Java dans [src/main/java/com/ssg/ccoe/demo/azure/springai/](src/main/java/com/ssg/ccoe/demo/azure/springai/) : `SpringAiApplication.java`, `controller/ChatController.java` (POST /api/chat avec @RateLimiter), `service/ChatService.java` (logique AI), `config/AzureOpenAiConfig.java` (beans dual-auth), `config/RateLimitConfig.java` (Bucket4j 10 req/min), `model/dto/` (ChatRequest, ChatResponse), `exception/GlobalExceptionHandler.java` (gestion erreurs rate limit et AI)

3. Créer configurations Spring : [application.yml](src/main/resources/application.yml) (server.port, logging, Application Insights connection string via env var), [application-dev.yml](src/main/resources/application-dev.yml) (profile apikey), [application-prod.yml](src/main/resources/application-prod.yml) (profile managedidentity)

4. Créer tests dans [src/test/java/com/ssg/ccoe/demo/azure/springai/](src/test/java/com/ssg/ccoe/demo/azure/springai/) : `service/ChatServiceTest.java` (unit test avec Mockito mockant AzureOpenAiChatModel), `controller/ChatControllerIntegrationTest.java` (integration test @SpringBootTest avec MockWebServer simulant Azure OpenAI), `RateLimitIntegrationTest.java` (validation 10 req/min)

5. Développer module Terraform [terraform/modules/openai/](terraform/modules/openai/) : `azurerm_cognitive_account` (OpenAI S0), `azurerm_cognitive_deployment` (gpt-4o-mini capacity=10), `azurerm_role_assignment` (Cognitive Services OpenAI User vers managed identity variable)

6. Développer module Terraform [terraform/modules/shared/](terraform/modules/shared/) : `azurerm_container_registry` (Basic), `azurerm_log_analytics_workspace`, `azurerm_application_insights` (workspace_id référencé), `azurerm_user_assigned_identity`, `azurerm_role_assignment` (AcrPull + Monitoring Metrics Publisher)

7. Développer module Terraform [terraform/modules/app-service/](terraform/modules/app-service/) : `azurerm_service_plan` (P1v2), `azurerm_linux_web_app` (Java 21, identity managed, app_settings AZURE_OPENAI_*, APPLICATIONINSIGHTS_CONNECTION_STRING, SPRING_PROFILES_ACTIVE)

8. Développer module Terraform [terraform/modules/container-apps/](terraform/modules/container-apps/) : `azurerm_container_app_environment` (Log Analytics linked), `azurerm_container_app` (ACR image, managed identity, env vars OpenAI + App Insights)

9. Créer fichiers Terraform racine : [terraform/main.tf](terraform/main.tf) (module calls + data azurerm_client_config), [terraform/variables.tf](terraform/variables.tf) (location default="westeurope", environment, rate_limit_rpm default=10), [terraform/outputs.tf](terraform/outputs.tf) (endpoint, api-key, deployment-name, acr_login_server, app_insights_connection_string, github_secrets map), [terraform/backend.tf](terraform/backend.tf) (backend local)

10. Créer workflows GitHub Actions : [.github/workflows/deploy-appservice.yml](.github/workflows/deploy-appservice.yml) (Java 21 setup, Maven test+package, Azure login, webapps-deploy avec secrets), [.github/workflows/deploy-containerapp.yml](.github/workflows/deploy-containerapp.yml) (Maven build, Jib push ACR, container-apps-deploy-action)

11. Créer [Dockerfile](Dockerfile) multi-stage (eclipse-temurin:21-jdk build, eclipse-temurin:21-jre-alpine runtime, expose 8080, ENTRYPOINT avec SPRING_PROFILES_ACTIVE variable)

12. Créer [README.md](README.md) : architecture diagram ASCII, prérequis, guide déploiement Terraform (commandes terraform init/plan/apply), script bash extraction outputs vers GitHub secrets, instructions test local (mvn test, mvn spring-boot:run), guide utilisation API (/api/chat curl example), monitoring App Insights queries

## Further Considerations

1. **Rate limit scope**: Limiter par IP client ou globalement? Par IP nécessite Redis/cache distribué, global plus simple avec in-memory Bucket4j

2. **App Insights sampling**: Configurer sampling à 100% (dev) ou 10-20% (prod) pour réduire coûts? Variable Terraform `app_insights_sampling_percentage`

3. **CI/CD trigger**: Workflows déclenchés sur push main uniquement ou aussi sur pull requests pour validation? Ajouter workflow `test-only.yml` sur PR?

4. **Terraform workspace**: Utiliser workspaces Terraform (dev/prod) ou suffixes de noms de ressources pour multi-environnement? Workspaces non compatibles avec backend local

## Technical Decisions Summary

- **Build Tool**: Maven
- **Java Version**: 21 LTS
- **Azure Compute**: App Service + Container Apps (both options)
- **CI/CD**: GitHub Actions (free for public repos)
- **Azure AI**: AI Foundry / Azure OpenAI Service
- **AI Model**: gpt-4o-mini (lowest cost)
- **Authentication**: Dual support (API Key for dev, Managed Identity for prod)
- **Terraform State**: Local (demo purposes)
- **Package**: com.ssg.ccoe.demo.azure.springai
- **RBAC**: Automatic role assignment via Terraform
- **API Endpoints**: /api/chat (simple prompt/response)
- **Container Registry**: Azure Container Registry (ACR)
- **Tests**: Unit + Integration tests with Mockito and MockWebServer
- **Monitoring**: Application Insights integration
- **Security**: Public API (no authentication)
- **Rate Limiting**: Yes, Bucket4j (10 req/min default)
