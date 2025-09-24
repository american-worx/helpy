# Helpy Ninja - Backend Technical Documentation (Spring Boot)

## 1. Project Structure

```
helpy-ninja-backend/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── helpyninja/
│   │   │           ├── HelpyNinjaApplication.java
│   │   │           ├── config/
│   │   │           │   ├── WebSocketConfig.java
│   │   │           │   ├── SecurityConfig.java
│   │   │           │   ├── DynamoDBConfig.java
│   │   │           │   ├── RedisConfig.java
│   │   │           │   ├── AsyncConfig.java
│   │   │           │   ├── CorsConfig.java
│   │   │           │   └── LLMConfig.java
│   │   │           │
│   │   │           ├── controller/
│   │   │           │   ├── AuthController.java
│   │   │           │   ├── UserController.java
│   │   │           │   ├── StudentController.java
│   │   │           │   ├── HelpyController.java
│   │   │           │   ├── ChatController.java
│   │   │           │   ├── GroupController.java
│   │   │           │   ├── LLMController.java
│   │   │           │   ├── LearningController.java
│   │   │           │   └── SubscriptionController.java
│   │   │           │
│   │   │           ├── websocket/
│   │   │           │   ├── WebSocketHandler.java
│   │   │           │   ├── WebSocketSessionManager.java
│   │   │           │   ├── MessageHandler.java
│   │   │           │   ├── GroupChatHandler.java
│   │   │           │   └── PresenceHandler.java
│   │   │           │
│   │   │           ├── service/
│   │   │           │   ├── auth/
│   │   │           │   │   ├── AuthService.java
│   │   │           │   │   ├── JwtService.java
│   │   │           │   │   └── CognitoService.java
│   │   │           │   ├── user/
│   │   │           │   │   ├── UserService.java
│   │   │           │   │   ├── StudentService.java
│   │   │           │   │   └── ProfileService.java
│   │   │           │   ├── helpy/
│   │   │           │   │   ├── HelpyService.java
│   │   │           │   │   ├── PersonalityService.java
│   │   │           │   │   └── MemoryService.java
│   │   │           │   ├── chat/
│   │   │           │   │   ├── ChatService.java
│   │   │           │   │   ├── MessageService.java
│   │   │           │   │   └── ConversationService.java
│   │   │           │   ├── group/
│   │   │           │   │   ├── GroupSessionService.java
│   │   │           │   │   ├── ParticipantService.java
│   │   │           │   │   └── MultiAgentCoordinator.java
│   │   │           │   ├── llm/
│   │   │           │   │   ├── LLMOrchestrator.java
│   │   │           │   │   ├── ModelRouter.java
│   │   │           │   │   ├── PromptGenerator.java
│   │   │           │   │   ├── ResponseCoordinator.java
│   │   │           │   │   └── providers/
│   │   │           │   │       ├── AnthropicProvider.java
│   │   │           │   │       ├── OpenAIProvider.java
│   │   │           │   │       ├── GeminiProvider.java
│   │   │           │   │       ├── BedrockProvider.java
│   │   │           │   │       └── LocalModelProvider.java
│   │   │           │   ├── learning/
│   │   │           │   │   ├── SubjectService.java
│   │   │           │   │   ├── ProgressService.java
│   │   │           │   │   ├── AssessmentService.java
│   │   │           │   │   └── CurriculumService.java
│   │   │           │   ├── cache/
│   │   │           │   │   ├── CacheService.java
│   │   │           │   │   ├── PromptCacheService.java
│   │   │           │   │   └── ResponseCacheService.java
│   │   │           │   └── data/
│   │   │           │       ├── InteractionCollector.java
│   │   │           │       ├── SocialSignalExtractor.java
│   │   │           │       └── DataAnonymizer.java
│   │   │           │
│   │   │           ├── repository/
│   │   │           │   ├── dynamodb/
│   │   │           │   │   ├── UserRepository.java
│   │   │           │   │   ├── StudentProfileRepository.java
│   │   │           │   │   ├── HelpyRepository.java
│   │   │           │   │   ├── ConversationRepository.java
│   │   │           │   │   ├── MessageRepository.java
│   │   │           │   │   ├── GroupSessionRepository.java
│   │   │           │   │   ├── ProgressRepository.java
│   │   │           │   │   ├── PromptRepository.java
│   │   │           │   │   └── InteractionLogRepository.java
│   │   │           │   ├── redis/
│   │   │           │   │   ├── SessionRepository.java
│   │   │           │   │   ├── CacheRepository.java
│   │   │           │   │   └── PresenceRepository.java
│   │   │           │   └── s3/
│   │   │           │       ├── ContentRepository.java
│   │   │           │       └── ModelRepository.java
│   │   │           │
│   │   │           ├── model/
│   │   │           │   ├── entity/
│   │   │           │   │   ├── User.java
│   │   │           │   │   ├── StudentProfile.java
│   │   │           │   │   ├── Helpy.java
│   │   │           │   │   ├── Conversation.java
│   │   │           │   │   ├── Message.java
│   │   │           │   │   ├── GroupSession.java
│   │   │           │   │   ├── Progress.java
│   │   │           │   │   └── Prompt.java
│   │   │           │   ├── dto/
│   │   │           │   │   ├── request/
│   │   │           │   │   │   ├── LoginRequest.java
│   │   │           │   │   │   ├── RegisterRequest.java
│   │   │           │   │   │   ├── MessageRequest.java
│   │   │           │   │   │   ├── LLMRequest.java
│   │   │           │   │   │   └── GroupJoinRequest.java
│   │   │           │   │   └── response/
│   │   │           │   │       ├── AuthResponse.java
│   │   │           │   │       ├── UserResponse.java
│   │   │           │   │       ├── HelpyResponse.java
│   │   │           │   │       ├── MessageResponse.java
│   │   │           │   │       └── ProgressResponse.java
│   │   │           │   └── enums/
│   │   │           │       ├── Role.java
│   │   │           │       ├── MessageType.java
│   │   │           │       ├── LLMModel.java
│   │   │           │       └── Subject.java
│   │   │           │
│   │   │           ├── exception/
│   │   │           │   ├── GlobalExceptionHandler.java
│   │   │           │   ├── NotFoundException.java
│   │   │           │   ├── UnauthorizedException.java
│   │   │           │   ├── LLMException.java
│   │   │           │   └── WebSocketException.java
│   │   │           │
│   │   │           ├── security/
│   │   │           │   ├── JwtAuthenticationFilter.java
│   │   │           │   ├── UserDetailsServiceImpl.java
│   │   │           │   └── SecurityUtils.java
│   │   │           │
│   │   │           ├── util/
│   │   │           │   ├── PromptBuilder.java
│   │   │           │   ├── MessageValidator.java
│   │   │           │   ├── CostCalculator.java
│   │   │           │   └── MetricsCollector.java
│   │   │           │
│   │   │           └── scheduled/
│   │   │               ├── DataSyncJob.java
│   │   │               ├── CacheCleanupJob.java
│   │   │               ├── ProgressCalculationJob.java
│   │   │               └── ModelUpdateJob.java
│   │   │
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-staging.yml
│   │       ├── application-prod.yml
│   │       ├── logback-spring.xml
│   │       └── prompts/
│   │           ├── base-prompts.json
│   │           └── subject-prompts.json
│   │
│   └── test/
│       └── java/
│           └── com/helpyninja/
│               ├── unit/
│               ├── integration/
│               └── e2e/
│
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── docker-compose.dev.yml
│
├── scripts/
│   ├── deploy.sh
│   ├── migrate-to-serverless.sh
│   └── local-setup.sh
│
├── pom.xml
└── README.md
```

## 2. Maven Dependencies (pom.xml)

```xml
Key Dependencies:
  Spring Boot Starters:
    - spring-boot-starter-web
    - spring-boot-starter-websocket
    - spring-boot-starter-security
    - spring-boot-starter-validation
    - spring-boot-starter-actuator
    - spring-boot-starter-cache
    - spring-boot-starter-aop
  
  AWS SDK:
    - aws-java-sdk-dynamodb (or spring-data-dynamodb)
    - aws-java-sdk-s3
    - aws-java-sdk-cognitoidp
    - aws-java-sdk-secretsmanager
    - aws-java-sdk-bedrock
  
  Database/Cache:
    - spring-boot-starter-data-redis
    - lettuce-core
    - enhanced-dynamodb
  
  LLM Libraries:
    - anthropic-java-sdk
    - openai-java
    - google-cloud-vertexai
    - langchain4j-spring-boot-starter
  
  WebSocket:
    - spring-boot-starter-websocket
    - sockjs-client
    - stomp-websocket
  
  Utilities:
    - lombok
    - mapstruct
    - apache-commons-lang3
    - guava
    - resilience4j-spring-boot2
  
  Testing:
    - spring-boot-starter-test
    - mockito-core
    - testcontainers
    - rest-assured
```

## 3. Configuration Files

### 3.1 application.yml

```yaml
server:
  port: 8080
  servlet:
    context-path: /api
  compression:
    enabled: true

spring:
  application:
    name: helpy-ninja-backend
  
  threads:
    virtual:
      enabled: true  # Java 21 virtual threads
  
  task:
    execution:
      pool:
        core-size: 10
        max-size: 50
        queue-capacity: 100
  
  cache:
    type: redis
    redis:
      time-to-live: 3600000
  
  websocket:
    message-broker:
      enabled: true
      relay-host: localhost
      relay-port: 61613

aws:
  region: us-east-1
  dynamodb:
    endpoint: ${AWS_DYNAMODB_ENDPOINT:}
    tables:
      users: ${ENV:dev}-users
      conversations: ${ENV:dev}-conversations
      messages: ${ENV:dev}-messages
  s3:
    bucket:
      content: helpy-ninja-content-${ENV:dev}
      models: helpy-ninja-models
  cognito:
    userPoolId: ${COGNITO_USER_POOL_ID}
    clientId: ${COGNITO_CLIENT_ID}

redis:
  host: ${REDIS_HOST:localhost}
  port: ${REDIS_PORT:6379}
  password: ${REDIS_PASSWORD:}
  ssl: ${REDIS_SSL:false}

llm:
  anthropic:
    apiKey: ${ANTHROPIC_API_KEY}
    model: claude-3-5-sonnet-20241022
    maxTokens: 4096
  openai:
    apiKey: ${OPENAI_API_KEY}
    model: gpt-4o
    maxTokens: 4096
  gemini:
    apiKey: ${GEMINI_API_KEY}
    model: gemini-1.5-pro
  local:
    enabled: ${LOCAL_MODEL_ENABLED:false}
    endpoint: ${LOCAL_MODEL_ENDPOINT:http://localhost:8000}

rate-limiting:
  enabled: true
  requests-per-minute: 60
  requests-per-hour: 1000

monitoring:
  metrics:
    enabled: true
    export:
      cloudwatch:
        enabled: true
        namespace: HelpyNinja
```

### 3.2 DynamoDB Configuration

```java
@Configuration
@EnableDynamoDBRepositories
public class DynamoDBConfig {
    
    @Value("${aws.region}")
    private String region;
    
    @Value("${aws.dynamodb.endpoint}")
    private String endpoint;
    
    @Bean
    public DynamoDbClient dynamoDbClient() {
        DynamoDbClientBuilder builder = DynamoDbClient.builder()
            .region(Region.of(region));
        
        if (StringUtils.isNotBlank(endpoint)) {
            builder.endpointOverride(URI.create(endpoint));
        }
        
        return builder.build();
    }
    
    @Bean
    public DynamoDbEnhancedClient dynamoDbEnhancedClient() {
        return DynamoDbEnhancedClient.builder()
            .dynamoDbClient(dynamoDbClient())
            .build();
    }
}
```

## 4. Core Services Implementation Structure

### 4.1 LLM Orchestrator Service

```java
@Service
@Slf4j
public class LLMOrchestrator {
    
    private final ModelRouter modelRouter;
    private final PromptGenerator promptGenerator;
    private final ResponseCoordinator responseCoordinator;
    private final CacheService cacheService;
    private final Map<LLMModel, LLMProvider> providers;
    
    @Async
    public CompletableFuture<LLMResponse> generateResponse(
            String userId, 
            String helpyId, 
            String message, 
            ConversationContext context) {
        
        // 1. Generate dynamic prompt
        // 2. Check cache
        // 3. Route to appropriate model
        // 4. Generate response
        // 5. Cache result
        // 6. Return response
    }
    
    public Flux<String> streamResponse(
            String userId,
            String helpyId,
            String message,
            ConversationContext context) {
        // Streaming implementation for real-time responses
    }
}
```

### 4.2 Multi-Agent Coordinator

```java
@Service
@Slf4j
public class MultiAgentCoordinator {
    
    private final HelpyService helpyService;
    private final LLMOrchestrator llmOrchestrator;
    private final ResponseCoordinator responseCoordinator;
    
    public MultiAgentResponse coordinateGroupResponse(
            GroupSession session,
            Message triggerMessage) {
        
        // 1. Identify all active Helpys
        // 2. Determine response order
        // 3. Generate responses in parallel
        // 4. Coordinate to avoid conflicts
        // 5. Schedule responses with delays
        // 6. Return coordinated response plan
    }
}
```

### 4.3 WebSocket Handler

```java
@Component
@Slf4j
public class WebSocketHandler extends TextWebSocketHandler {
    
    private final WebSocketSessionManager sessionManager;
    private final MessageHandler messageHandler;
    private final GroupChatHandler groupChatHandler;
    
    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        // Handle new connection
    }
    
    @Override
    protected void handleTextMessage(
            WebSocketSession session, 
            TextMessage message) {
        // Route message to appropriate handler
    }
    
    @Override
    public void afterConnectionClosed(
            WebSocketSession session, 
            CloseStatus status) {
        // Clean up connection
    }
}
```

## 5. Development vs Production Strategy

### 5.1 Development Phase (Spring Boot)

```yaml
Advantages:
  - Rapid development with familiar stack
  - Easy debugging and local testing
  - Integrated development environment
  - Single deployment unit
  - Simpler state management
  - Direct database access

Architecture:
  - Single Spring Boot application
  - Embedded Tomcat server
  - Local Redis for caching
  - DynamoDB Local for testing
  - Docker Compose for dependencies

Deployment:
  - EC2 instance (t3.large recommended)
  - RDS PostgreSQL for rapid prototyping
  - ElastiCache Redis
  - Application Load Balancer
  - Auto-scaling group (2-4 instances)
```

### 5.2 Migration Path to Serverless

```yaml
Phase 1 - Hybrid Approach:
  - Keep Spring Boot for WebSocket connections
  - Move CPU-intensive LLM calls to Lambda
  - Use SQS for async processing
  - Gradual migration of endpoints

Phase 2 - Service Extraction:
  - Extract auth service to Lambda
  - Move chat service to Lambda + API Gateway
  - Keep WebSocket on ECS Fargate
  - Migrate scheduled jobs to EventBridge

Phase 3 - Full Serverless:
  - Convert remaining services
  - Use Step Functions for orchestration
  - Implement Lambda@Edge for caching
  - Complete transition to managed services

Migration Tools:
  - AWS Application Migration Service
  - Spring Cloud Function for Lambda
  - Spring Native for GraalVM
  - Containerize for ECS migration
```

## 6. Local Development Setup

### 6.1 Docker Compose for Development

```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=dev
    depends_on:
      - redis
      - dynamodb-local
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
  
  dynamodb-local:
    image: amazon/dynamodb-local
    ports:
      - "8000:8000"
    command: "-jar DynamoDBLocal.jar -sharedDb -inMemory"
  
  localstack:
    image: localstack/localstack
    ports:
      - "4566:4566"
    environment:
      - SERVICES=s3,cognito,secretsmanager
      - DEBUG=1
```

### 6.2 Development Tools Integration

```yaml
IDE Setup:
  - IntelliJ IDEA / Eclipse
  - Spring Boot DevTools for hot reload
  - Lombok plugin
  - AWS Toolkit
  
Testing Tools:
  - Postman / Insomnia for API testing
  - WebSocket testing with wscat
  - JMeter for load testing
  - Mockito for unit tests
  
Monitoring:
  - Spring Boot Actuator endpoints
  - Micrometer for metrics
  - ELK stack for logging (dev)
  - Grafana for visualization
```

## 7. Database Access Patterns (Spring Data)

### 7.1 Repository Pattern

```java
@Repository
public class UserRepository {
    
    private final DynamoDbEnhancedClient enhancedClient;
    private final DynamoDbTable<User> userTable;
    
    public Optional<User> findById(String userId) {
        Key key = Key.builder()
            .partitionValue(userId)
            .sortValue("PROFILE")
            .build();
        
        return Optional.ofNullable(
            userTable.getItem(key)
        );
    }
    
    public List<User> findByRole(Role role) {
        QueryConditional queryConditional = QueryConditional
            .keyEqualTo(Key.builder()
                .partitionValue(role.toString())
                .build());
        
        return userTable.index("GSI-Role")
            .query(queryConditional)
            .stream()
            .flatMap(page -> page.items().stream())
            .collect(Collectors.toList());
    }
}
```

## 8. Caching Strategy

### 8.1 Multi-Level Caching

```java
@Service
public class CacheService {
    
    @Cacheable(value = "prompts", key = "#userId + ':' + #helpyId")
    public String getCompiledPrompt(String userId, String helpyId) {
        // Generate if not cached
    }
    
    @Cacheable(value = "responses", key = "#promptHash")
    public String getCachedResponse(String promptHash) {
        // Return cached LLM response
    }
    
    @CacheEvict(value = "prompts", key = "#userId + ':' + #helpyId")
    public void invalidatePrompt(String userId, String helpyId) {
        // Clear cache when prompt updates
    }
}
```

## 9. Security Configuration

### 9.1 Spring Security Setup

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors().and()
            .csrf().disable()
            .sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeHttpRequests()
                .requestMatchers("/auth/**", "/ws/**").permitAll()
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            .and()
            .addFilterBefore(jwtAuthFilter(), UsernamePasswordAuthenticationFilter.class)
            .exceptionHandling()
                .authenticationEntryPoint(unauthorizedHandler());
        
        return http.build();
    }
}
```

## 10. Monitoring & Metrics

### 10.1 Actuator Endpoints

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  metrics:
    export:
      cloudwatch:
        enabled: true
    tags:
      application: helpy-ninja
      environment: ${ENV:dev}
```

### 10.2 Custom Metrics

```java
@Component
public class MetricsCollector {
    
    private final MeterRegistry meterRegistry;
    
    public void recordLLMLatency(String model, long duration) {
        meterRegistry.timer("llm.response.time", 
            "model", model).record(duration, TimeUnit.MILLISECONDS);
    }
    
    public void incrementMessageCount(String type) {
        meterRegistry.counter("messages.sent", 
            "type", type).increment();
    }
}
```

## 11. Deployment Options

### 11.1 AWS Deployment (Development)

```yaml
EC2 Deployment:
  Instance Type: t3.large (2 vCPU, 8 GB RAM)
  Storage: 100 GB EBS
  Java Version: 21 (with Virtual Threads)
  
Load Balancer:
  Type: Application Load Balancer
  Health Check: /actuator/health
  Sticky Sessions: Enabled for WebSocket
  
Auto Scaling:
  Min Instances: 2
  Max Instances: 10
  Target CPU: 70%
  
CI/CD:
  - GitHub Actions
  - AWS CodeDeploy
  - Blue/Green deployment
```

### 11.2 Container Deployment

```dockerfile
# Dockerfile
FROM eclipse-temurin:21-jre-alpine
COPY target/helpy-ninja-*.jar app.jar
ENTRYPOINT ["java", "--enable-preview", "-jar", "/app.jar"]
```

## 12. Cost Comparison

### Development Phase (Spring Boot on EC2)
```yaml
Monthly Costs (Estimated):
  - EC2 (2x t3.large): $120
  - RDS (db.t3.medium): $50
  - ElastiCache (cache.t3.micro): $25
  - ALB: $25
  - Data Transfer: $50
  - Total: ~$270/month

Benefits:
  - Predictable costs
  - Easier debugging
  - Faster development
  - Simpler architecture
```

### Production Phase (Serverless)
```yaml
Monthly Costs (At Scale - 10,000 users):
  - Lambda: $200-500
  - API Gateway: $100-200
  - DynamoDB: $200-400
  - Other Services: $200-300
  - Total: ~$700-1400/month

Benefits:
  - Auto-scaling
  - Pay per use
  - No server management
  - Higher availability
```

## 13. Migration Utilities

### 13.1 Spring Cloud Function (For Lambda Migration)

```java
@Configuration
public class FunctionConfig {
    
    @Bean
    public Function<Message, String> processMessage() {
        return message -> {
            // Lambda function logic
            return "processed";
        };
    }
    
    @Bean
    public Consumer<SQSEvent> handleSQSEvent() {
        return event -> {
            // Process SQS messages
        };
    }
}
```

## Summary

Using Spring Boot for development gives you:
1. **Faster iteration** - Single codebase, hot reload, familiar tooling
2. **Easier debugging** - Full stack traces, integrated debugging
3. **Lower initial costs** - Predictable EC2 costs vs per-request Lambda pricing
4. **Simpler architecture** - Monolithic during development, microservices later
5. **Gradual migration path** - Move to serverless component by component

The Spring Boot approach lets you validate your product quickly while maintaining a clear path to serverless architecture when you need to scale. The code structure I've provided supports both architectures, making migration straightforward when the time comes.