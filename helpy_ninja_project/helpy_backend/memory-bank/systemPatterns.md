# Helpy Ninja - System Patterns & Architecture

## Overall Architecture Philosophy

### Clean Architecture Principles
The system follows Clean Architecture with clear separation of concerns:
- **Presentation Layer**: Controllers, WebSocket handlers, DTOs
- **Application Layer**: Services, use cases, business logic coordination
- **Domain Layer**: Entities, value objects, domain services, repository interfaces
- **Infrastructure Layer**: Repository implementations, external service integrations

### Hybrid Architecture Strategy
**Development Phase**: Spring Boot monolith for rapid iteration and debugging
**Production Phase**: Gradual migration to AWS serverless microservices
**Migration Path**: Service-by-service extraction maintaining compatibility

## Core Architectural Patterns

### Multi-Agent Coordination Pattern
```
UserMessage → LLMOrchestrator → ModelRouter → PromptGenerator
                ↓
MultiAgentCoordinator → ResponseCoordinator → ConflictResolver
                ↓
ScheduledResponseDispatcher → WebSocketManager → ClientDelivery
```

**Key Components:**
- **ModelRouter**: Selects optimal LLM based on complexity and cost
- **MultiAgentCoordinator**: Manages multiple AI responses to prevent chaos
- **ResponseCoordinator**: Ensures meaningful, non-redundant AI contributions
- **ConflictResolver**: Handles disagreements between AI personalities gracefully

### Repository Pattern with Multi-Storage
```java
interface ConversationRepository {
    // Standard CRUD operations
    Optional<Conversation> findById(String id);
    List<Conversation> findByUserId(String userId);
    
    // Domain-specific queries
    List<Conversation> findActiveGroupSessions();
    List<Message> findRecentMessages(String conversationId, int limit);
}

// Implementations
@Repository
class DynamoDBConversationRepository implements ConversationRepository

@Repository 
class RedisConversationRepository implements ConversationRepository // For caching
```

### Event-Driven Communication
```
MessageReceived → EventBus → [
    MessagePersistenceHandler,
    AIResponseTrigger,
    PresenceUpdater,
    AnalyticsCollector,
    ParentNotificationHandler
]
```

## Data Access Patterns

### DynamoDB Single-Table Design
```
PK (Partition Key) | SK (Sort Key) | Entity Type | Attributes
USER#{userId} | PROFILE | User | email, username, role, subscription
USER#{userId} | STUDENT#{studentId} | StudentProfile | name, age, subjects, helpyId
CONV#{convId} | METADATA | Conversation | type, participants, subject
CONV#{convId} | MSG#{timestamp}#{msgId} | Message | senderId, content, reactions
HELPY#{helpyId} | CONFIG | Helpy | name, personality, memories, stats
HELPY#{helpyId} | MEMORY#{timestamp} | Memory | content, importance, context
PROGRESS#{userId}#{subject} | CURRENT | Progress | level, completed, strengths
SESSION#{sessionId} | METADATA | GroupSession | participants, helpys, metrics
```

### Multi-Level Caching Strategy
```java
@Service
public class CacheService {
    // L1: Application-level cache (in-memory)
    @Cacheable(value = "prompts", key = "#userId + ':' + #helpyId")
    public String getCompiledPrompt(String userId, String helpyId);
    
    // L2: Redis distributed cache
    @Cacheable(value = "responses", key = "#promptHash", unless = "#result.length() > 1000")
    public String getCachedResponse(String promptHash);
    
    // L3: CloudFront CDN (for static content)
    // Configured via infrastructure, serves models, images, static content
}
```

## Service Integration Patterns

### LLM Provider Abstraction
```java
public interface LLMProvider {
    CompletableFuture<LLMResponse> generateResponse(LLMRequest request);
    Flux<String> streamResponse(LLMRequest request);
    boolean isAvailable();
    LLMUsageStats getUsageStats();
}

// Provider implementations
@Component("anthropic")
public class AnthropicProvider implements LLMProvider

@Component("openai") 
public class OpenAIProvider implements LLMProvider

@Component("local")
public class LocalModelProvider implements LLMProvider

// Factory pattern for provider selection
@Service
public class LLMProviderFactory {
    public LLMProvider getProvider(String providerName, LLMRequest request) {
        // Route based on complexity, cost, availability
    }
}
```

### Circuit Breaker Pattern for Resilience
```java
@Service
public class ResilientLLMService {
    
    @CircuitBreaker(name = "anthropic", fallbackMethod = "fallbackToLocalModel")
    @Retry(name = "anthropic")
    @TimeLimiter(name = "anthropic")
    public CompletableFuture<String> generateWithAnthropic(LLMRequest request) {
        return anthropicProvider.generateResponse(request);
    }
    
    public CompletableFuture<String> fallbackToLocalModel(LLMRequest request, Exception ex) {
        return localModelProvider.generateResponse(request);
    }
}
```

## Real-Time Communication Patterns

### WebSocket Session Management
```java
@Component
public class WebSocketSessionManager {
    private final Map<String, WebSocketSession> userSessions = new ConcurrentHashMap<>();
    private final Map<String, Set<String>> groupSessions = new ConcurrentHashMap<>();
    
    public void addUserSession(String userId, WebSocketSession session) {
        userSessions.put(userId, session);
        updatePresence(userId, PresenceStatus.ONLINE);
    }
    
    public void broadcastToGroup(String groupId, Object message) {
        Set<String> participants = groupSessions.get(groupId);
        participants.parallelStream()
            .map(userSessions::get)
            .filter(Objects::nonNull)
            .forEach(session -> sendMessage(session, message));
    }
}
```

### Message Ordering and Coordination
```java
@Service
public class MessageCoordinator {
    
    public void coordinateGroupResponse(GroupSession session, Message triggerMessage) {
        // 1. Identify which Helpys should respond
        List<Helpy> respondingHelpys = determineResponders(session, triggerMessage);
        
        // 2. Generate responses in parallel
        Map<String, CompletableFuture<String>> responses = respondingHelpys.parallelStream()
            .collect(Collectors.toMap(
                Helpy::getId,
                helpy -> generateResponse(helpy, triggerMessage, session.getContext())
            ));
        
        // 3. Wait for all responses and coordinate delivery
        CompletableFuture.allOf(responses.values().toArray(new CompletableFuture[0]))
            .thenRun(() -> scheduleCoordinatedDelivery(responses, session));
    }
    
    private void scheduleCoordinatedDelivery(Map<String, CompletableFuture<String>> responses, GroupSession session) {
        // Prevent AI response collision by scheduling with delays
        AtomicInteger delay = new AtomicInteger(0);
        responses.entrySet().stream()
            .sorted(Map.Entry.comparingByKey()) // Consistent ordering
            .forEach(entry -> {
                String helpyId = entry.getKey();
                CompletableFuture<String> responseFuture = entry.getValue();
                
                responseFuture.thenAccept(response -> {
                    CompletableFuture.delayedExecutor(delay.getAndAdd(2), TimeUnit.SECONDS)
                        .execute(() -> deliverResponse(helpyId, response, session));
                });
            });
    }
}
```

## Error Handling and Resilience Patterns

### Global Exception Handling
```java
@ControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(LLMException.class)
    public ResponseEntity<ErrorResponse> handleLLMException(LLMException e) {
        if (e.getCause() instanceof RateLimitException) {
            return ResponseEntity.status(429)
                .body(new ErrorResponse("RATE_LIMITED", "Please try again in a moment"));
        }
        
        // Fallback to cached response or simplified AI
        return ResponseEntity.ok(new ErrorResponse("DEGRADED_SERVICE", 
            "Experiencing high demand. Response may be delayed."));
    }
    
    @ExceptionHandler(WebSocketException.class)
    public void handleWebSocketException(WebSocketException e) {
        // Log error, attempt reconnection, notify client
        websocketReconnectionService.scheduleReconnection(e.getSessionId());
    }
}
```

### Graceful Degradation Strategy
```java
@Service
public class DegradationService {
    
    public String getResponseWithDegradation(LLMRequest request) {
        try {
            // Try primary LLM (Claude/GPT-4)
            return primaryLLMService.generateResponse(request);
        } catch (Exception e1) {
            try {
                // Fallback to secondary LLM (local model)
                return secondaryLLMService.generateResponse(request);
            } catch (Exception e2) {
                try {
                    // Fallback to cached similar response
                    return cacheService.findSimilarResponse(request.getPrompt());
                } catch (Exception e3) {
                    // Final fallback to templated response
                    return generateTemplateResponse(request);
                }
            }
        }
    }
}
```

## Security Patterns

### JWT Authentication with Refresh Tokens
```java
@Service
public class JwtService {
    
    public AuthTokens generateTokens(User user) {
        String accessToken = createAccessToken(user, Duration.ofMinutes(15));
        String refreshToken = createRefreshToken(user, Duration.ofDays(7));
        
        // Store refresh token hash in Redis with expiration
        redisTemplate.opsForValue().set(
            "refresh:" + user.getId(), 
            hashRefreshToken(refreshToken),
            Duration.ofDays(7)
        );
        
        return new AuthTokens(accessToken, refreshToken);
    }
    
    public AuthTokens refreshTokens(String refreshToken) {
        // Validate refresh token, rotate it, generate new access token
        Claims claims = validateAndExtractClaims(refreshToken);
        User user = userService.findById(claims.getSubject());
        
        // Invalidate old refresh token
        redisTemplate.delete("refresh:" + user.getId());
        
        return generateTokens(user);
    }
}
```

### Rate Limiting and Quotas
```java
@Component
public class RateLimitingFilter implements Filter {
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {
        String userId = extractUserId(request);
        String endpoint = extractEndpoint(request);
        
        RateLimitResult result = rateLimitService.checkLimit(userId, endpoint);
        
        if (result.isAllowed()) {
            chain.doFilter(request, response);
        } else {
            sendRateLimitResponse(response, result);
        }
    }
}

@Service
public class RateLimitService {
    
    public RateLimitResult checkLimit(String userId, String endpoint) {
        String key = "rate_limit:" + userId + ":" + endpoint;
        
        // Token bucket algorithm implementation
        TokenBucket bucket = getOrCreateBucket(key);
        
        if (bucket.tryConsume(1)) {
            return RateLimitResult.allowed();
        } else {
            return RateLimitResult.denied(bucket.getRefillTime());
        }
    }
}
```

## Performance Optimization Patterns

### Async Processing with CompletableFuture
```java
@Service
public class AsyncLearningService {
    
    @Async("learningTaskExecutor")
    public CompletableFuture<ProgressUpdate> updateProgress(String userId, String subject, AssessmentResult result) {
        return CompletableFuture.supplyAsync(() -> {
            // Calculate new progress metrics
            Progress currentProgress = progressRepository.findByUserIdAndSubject(userId, subject);
            Progress updatedProgress = progressCalculator.calculate(currentProgress, result);
            
            // Save to database
            progressRepository.save(updatedProgress);
            
            // Trigger related updates in parallel
            CompletableFuture<Void> updateAchievements = achievementService.checkNewAchievements(userId, updatedProgress);
            CompletableFuture<Void> updateRecommendations = recommendationService.updateRecommendations(userId, updatedProgress);
            CompletableFuture<Void> notifyParents = parentNotificationService.sendProgressUpdate(userId, updatedProgress);
            
            // Wait for all parallel operations
            CompletableFuture.allOf(updateAchievements, updateRecommendations, notifyParents).join();
            
            return new ProgressUpdate(updatedProgress, result);
        });
    }
}
```

### Batch Processing for Efficiency
```java
@Service
public class BatchMessageProcessor {
    
    @EventListener
    @Async
    public void handleMessageBatch(List<Message> messages) {
        // Group messages by conversation for efficient processing
        Map<String, List<Message>> messagesByConversation = messages.stream()
            .collect(Collectors.groupingBy(Message::getConversationId));
        
        // Process each conversation's messages in parallel
        List<CompletableFuture<Void>> processingTasks = messagesByConversation.entrySet()
            .parallelStream()
            .map(entry -> processConversationMessages(entry.getKey(), entry.getValue()))
            .collect(Collectors.toList());
        
        // Wait for all conversations to be processed
        CompletableFuture.allOf(processingTasks.toArray(new CompletableFuture[0])).join();
    }
}
```

## Monitoring and Observability Patterns

### Custom Metrics Collection
```java
@Component
public class MetricsCollector {
    
    private final MeterRegistry meterRegistry;
    private final Counter messagesSent;
    private final Timer llmResponseTime;
    private final Gauge activeConnections;
    
    public MetricsCollector(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.messagesSent = Counter.builder("messages.sent")
            .tag("type", "total")
            .register(meterRegistry);
        this.llmResponseTime = Timer.builder("llm.response.time")
            .register(meterRegistry);
        this.activeConnections = Gauge.builder("websocket.connections.active")
            .register(meterRegistry, this, MetricsCollector::getActiveConnectionCount);
    }
    
    public void recordLLMResponse(String model, Duration duration, boolean fromCache) {
        llmResponseTime.record(duration);
        meterRegistry.counter("llm.responses", 
            "model", model, 
            "cached", String.valueOf(fromCache)).increment();
    }
    
    public void recordMessageSent(String messageType, String conversationType) {
        messagesSent.increment();
        meterRegistry.counter("messages.sent.detailed",
            "message_type", messageType,
            "conversation_type", conversationType).increment();
    }
}
```

### Health Checks and Circuit Breakers
```java
@Component
public class SystemHealthIndicator implements HealthIndicator {
    
    @Override
    public Health health() {
        Health.Builder builder = new Health.Builder();
        
        // Check critical dependencies
        boolean databaseHealthy = checkDatabaseHealth();
        boolean redisHealthy = checkRedisHealth();
        boolean llmProvidersHealthy = checkLLMProviders();
        
        if (databaseHealthy && redisHealthy && llmProvidersHealthy) {
            return builder.up()
                .withDetail("database", "UP")
                .withDetail("cache", "UP")
                .withDetail("llm_providers", "UP")
                .build();
        } else {
            return builder.down()
                .withDetail("database", databaseHealthy ? "UP" : "DOWN")
                .withDetail("cache", redisHealthy ? "UP" : "DOWN")
                .withDetail("llm_providers", llmProvidersHealthy ? "UP" : "DOWN")
                .build();
        }
    }
}
```

These patterns provide a robust foundation for the Helpy Ninja backend, ensuring scalability, reliability, and maintainability while supporting the unique multi-agent AI tutoring requirements.