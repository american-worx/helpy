# Helpy Ninja - Technical Context

## Technology Stack Overview

### Backend Architecture
**Current Phase**: Spring Boot 3.x monolith for rapid development and debugging
**Target Phase**: AWS Serverless microservices for production scale
**Migration Strategy**: Gradual service extraction maintaining backward compatibility

### Core Technologies

#### Application Framework
- **Spring Boot 3.x**: Core application framework with auto-configuration
- **Java 21**: Latest LTS with virtual threads for improved concurrency
- **Maven**: Dependency management and build automation
- **Spring Security**: Authentication, authorization, and security
- **Spring WebSocket**: Real-time bidirectional communication

#### Database & Storage
- **DynamoDB**: Primary NoSQL database for user data, conversations, messages
- **Redis**: Distributed caching layer for sessions, prompts, and responses
- **S3**: Static content storage for models, images, and documents
- **Single-Table Design**: DynamoDB optimized for access patterns and cost

#### LLM Integration
- **Multi-Provider Strategy**: Claude 3.5 Sonnet, GPT-4o, Gemini 1.5 Pro, local models
- **LangChain4j**: Java framework for LLM orchestration and chaining
- **Provider Abstraction**: Interface-based design for easy provider switching
- **Circuit Breakers**: Resilience4j for fault tolerance and fallback mechanisms

#### Real-Time Communication
- **WebSocket (STOMP)**: For group sessions and live collaboration
- **Server-Sent Events**: For streaming AI responses
- **Redis Pub/Sub**: For WebSocket scaling across multiple instances
- **Session Management**: Distributed session storage with Redis

#### Monitoring & Observability
- **Micrometer**: Application metrics collection
- **Spring Boot Actuator**: Health checks and operational endpoints
- **CloudWatch**: AWS-native monitoring and alerting
- **Structured Logging**: JSON-based logs for better searchability

## Development Environment

### Local Development Setup
```yaml
Docker Compose Services:
  - Application: Spring Boot app with hot reload
  - Redis: For caching and session storage
  - DynamoDB Local: For database operations
  - LocalStack: For AWS service mocking (S3, Cognito)
  
IDE Configuration:
  - IntelliJ IDEA/Eclipse with Spring Tools
  - Lombok plugin for boilerplate reduction
  - AWS Toolkit for cloud integration
  - Docker plugin for container management
```

### Development Tools
- **Spring Boot DevTools**: Hot reload for rapid iteration
- **Testcontainers**: Integration testing with real dependencies
- **WireMock**: API mocking for external services
- **JMeter**: Load testing and performance validation
- **Postman/Insomnia**: API testing and documentation

## Architecture Decisions

### Database Strategy
**DynamoDB Single-Table Design**
```
Rationale:
✅ Cost-effective at scale (pay per request)
✅ Serverless-native with automatic scaling
✅ Built-in global replication
✅ Consistent with AWS serverless strategy

Trade-offs:
❌ Complex querying compared to SQL
❌ Learning curve for relational developers
❌ Local development requires emulation
```

**Redis for Caching**
```
Use Cases:
- User session storage (JWT tokens, preferences)
- Compiled prompt caching (expensive to regenerate)
- LLM response caching (avoid duplicate API calls)
- WebSocket connection management
- Rate limiting counters
```

### LLM Provider Strategy
**Multi-Provider Approach**
```java
Provider Selection Logic:
- Simple queries → Cached responses (Cost: $0)
- Basic questions → Local models (Cost: ~$0.001)
- Complex problems → Claude/GPT-4 (Cost: $0.01-0.03)
- Subject expertise → Fine-tuned models (Cost: Variable)

Fallback Chain:
Primary Provider → Secondary Provider → Cached Response → Template Response
```

### Concurrency Model
**Virtual Threads (Java 21)**
```java
Benefits:
✅ Lightweight threads (millions possible)
✅ Simplified async programming
✅ Better resource utilization
✅ Reduced complexity vs reactive programming

Implementation:
@EnableAsync
@Configuration
public class AsyncConfig {
    @Bean
    public Executor taskExecutor() {
        return Executors.newVirtualThreadPerTaskExecutor();
    }
}
```

## Security Architecture

### Authentication & Authorization
```yaml
JWT Strategy:
  - Access Token: 15-minute expiration, contains user claims
  - Refresh Token: 7-day expiration, stored securely in Redis
  - Token Rotation: New refresh token issued on each use
  - Revocation: Redis blacklist for immediate token invalidation

AWS Cognito Integration:
  - User pool management
  - Social login (Google, Facebook, Apple)
  - Multi-factor authentication
  - Password policies and recovery
```

### Data Protection
```yaml
Encryption:
  - At Rest: DynamoDB encryption with AWS KMS
  - In Transit: TLS 1.3 for all API communication
  - Application Level: Sensitive fields encrypted with field-level encryption

Privacy:
  - PII Anonymization: Automatic anonymization for analytics
  - Data Retention: Automatic deletion based on retention policies
  - Consent Management: Granular permissions for data usage
  - GDPR Compliance: Right to deletion and data portability
```

### Rate Limiting & Abuse Prevention
```java
Multi-Level Rate Limiting:
  - Global: 1000 requests/hour per IP
  - User: 60 requests/minute per authenticated user
  - LLM: 10 AI requests/minute for free tier
  - WebSocket: 100 messages/minute per connection

Implementation:
@Component
public class RateLimitingFilter {
    // Token bucket algorithm with Redis backing
    // Different limits per endpoint and user tier
    // Graceful degradation on limit exceeded
}
```

## Performance Optimization

### Caching Strategy
```yaml
Multi-Level Caching:
  L1 - Application Cache: 
    - In-memory caffeine cache for hot data
    - User preferences, system configuration
    - TTL: 5-15 minutes
  
  L2 - Distributed Cache (Redis):
    - Compiled prompts, LLM responses
    - Session data, temporary state
    - TTL: 30 minutes to 24 hours
  
  L3 - CDN (CloudFront):
    - Static content, model files
    - API responses for public endpoints
    - TTL: 1 hour to 1 year
```

### Database Optimization
```yaml
DynamoDB Access Patterns:
  - Hot Partition Prevention: Random suffixes for high-write items
  - GSI Strategy: Carefully designed for query requirements
  - Batch Operations: Use batch read/write where possible
  - Connection Pooling: Reuse DynamoDB client connections

Query Optimization:
  - Query instead of Scan operations
  - Projection expressions to limit data transfer
  - Pagination for large result sets
  - Conditional updates to prevent conflicts
```

### LLM Response Optimization
```java
Optimization Strategies:
  - Response Caching: Hash-based caching of similar prompts
  - Prompt Compression: Remove redundant context where possible
  - Streaming Responses: Start delivering content immediately
  - Parallel Generation: Multiple models for different parts
  - Model Selection: Route to optimal model based on complexity

Cost Management:
  - Token Counting: Track and limit token usage per user
  - Prompt Engineering: Efficient prompts that minimize tokens
  - Cache Hit Rate: Target >60% cache hit rate for common queries
  - Fallback Models: Use cheaper models when quality is sufficient
```

## Scalability Architecture

### Horizontal Scaling
```yaml
Spring Boot Application:
  - Stateless design for easy horizontal scaling
  - Load balancer with session affinity for WebSocket
  - Auto-scaling based on CPU and memory metrics
  - Blue-green deployment for zero-downtime updates

Database Scaling:
  - DynamoDB auto-scaling for read/write capacity
  - Global tables for multi-region deployment
  - Read replicas for read-heavy workloads
  - Connection pooling to prevent connection exhaustion
```

### WebSocket Scaling
```java
Multi-Instance WebSocket Management:
  - Redis Pub/Sub for cross-instance message broadcasting
  - Consistent hashing for session distribution
  - Connection draining for graceful shutdowns
  - Health checks to remove failed instances

@Configuration
public class WebSocketConfig implements WebSocketConfigurer {
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableStompBrokerRelay("/topic", "/queue")
              .setRelayHost("redis-cluster-endpoint")
              .setSystemLogin("admin")
              .setSystemPasscode("password");
    }
}
```

### Migration to Serverless
```yaml
Phase 1 - Hybrid Architecture:
  - Keep WebSocket service on ECS Fargate
  - Move auth endpoints to Lambda
  - Extract LLM processing to Lambda
  - Use SQS for async processing

Phase 2 - Service Extraction:
  - Chat service → Lambda + API Gateway
  - User service → Lambda functions
  - Learning service → Lambda + Step Functions
  - Keep WebSocket and real-time features on containers

Phase 3 - Full Serverless:
  - WebSocket API Gateway for real-time features
  - Step Functions for complex workflows
  - EventBridge for event routing
  - Lambda@Edge for global distribution
```

## Development Workflow

### CI/CD Pipeline
```yaml
GitHub Actions Workflow:
  1. Code Quality:
     - SonarQube code analysis
     - Security vulnerability scanning
     - Dependency checking

  2. Testing:
     - Unit tests with JUnit 5
     - Integration tests with Testcontainers
     - Load tests with JMeter
     - Security tests with OWASP ZAP

  3. Build & Package:
     - Maven build with tests
     - Docker image creation
     - Artifact storage in ECR

  4. Deployment:
     - Staging deployment with smoke tests
     - Production deployment with approval
     - Blue-green strategy with health checks
     - Automatic rollback on failure
```

### Code Quality Standards
```yaml
Code Standards:
  - Google Java Style Guide
  - SonarQube quality gates
  - >80% test coverage requirement
  - Mandatory code reviews

Architecture Standards:
  - Clean Architecture principles
  - SOLID design principles
  - Domain-driven design patterns
  - Consistent error handling

Documentation Standards:
  - JavaDoc for public APIs
  - OpenAPI specification for REST endpoints
  - Architecture decision records (ADRs)
  - Runbook documentation for operations
```

## Monitoring & Operations

### Application Monitoring
```java
Custom Metrics:
  - Business Metrics: User engagement, learning outcomes
  - Technical Metrics: Response times, error rates, throughput
  - Infrastructure Metrics: CPU, memory, database performance
  - Cost Metrics: LLM usage, infrastructure costs per user

@Component
public class CustomMetrics {
    @EventListener
    public void recordLLMUsage(LLMResponseEvent event) {
        meterRegistry.counter("llm.requests.total",
            "provider", event.getProvider(),
            "model", event.getModel(),
            "cached", String.valueOf(event.isCached())
        ).increment();
        
        meterRegistry.timer("llm.response.time",
            "provider", event.getProvider()
        ).record(event.getDuration());
    }
}
```

### Error Handling & Alerting
```yaml
Error Classification:
  - Critical: System down, data loss, security breach
  - High: Feature unavailable, significant user impact
  - Medium: Degraded performance, some users affected
  - Low: Minor issues, no user impact

Alert Thresholds:
  - Error Rate >1% → Critical alert
  - Response Time >2s → High alert
  - LLM Failures >5% → Medium alert
  - WebSocket Disconnections >10% → High alert

Response Procedures:
  - Automated remediation where possible
  - Escalation paths for human intervention
  - Post-incident reviews and improvements
  - Customer communication protocols
```

This technical context provides the foundation for building a scalable, reliable, and maintainable backend system that can evolve from a Spring Boot monolith to a fully serverless architecture while supporting the unique requirements of multi-agent AI tutoring.