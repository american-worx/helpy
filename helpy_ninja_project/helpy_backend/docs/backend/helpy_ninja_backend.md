# Helpy Ninja - Backend Technical Documentation (AWS)

## 1. Project Structure

```
helpy-ninja-backend/
├── infrastructure/                    # IaC (Terraform/CDK)
│   ├── terraform/
│   │   ├── environments/
│   │   │   ├── dev/
│   │   │   ├── staging/
│   │   │   └── production/
│   │   ├── modules/
│   │   │   ├── api_gateway/
│   │   │   ├── lambda/
│   │   │   ├── dynamodb/
│   │   │   ├── ecs/
│   │   │   ├── s3/
│   │   │   └── cognito/
│   │   └── main.tf
│   │
│   └── scripts/
│       ├── deploy.sh
│       └── destroy.sh
│
├── services/                          # Microservices
│   ├── auth-service/
│   │   ├── src/
│   │   │   ├── handlers/
│   │   │   │   ├── login.js
│   │   │   │   ├── register.js
│   │   │   │   └── refresh.js
│   │   │   ├── middleware/
│   │   │   ├── utils/
│   │   │   └── models/
│   │   ├── tests/
│   │   └── serverless.yml
│   │
│   ├── user-service/
│   │   ├── src/
│   │   │   ├── handlers/
│   │   │   │   ├── profile.js
│   │   │   │   ├── settings.js
│   │   │   │   └── subscription.js
│   │   │   └── repositories/
│   │   └── serverless.yml
│   │
│   ├── chat-service/
│   │   ├── src/
│   │   │   ├── handlers/
│   │   │   │   ├── sendMessage.js
│   │   │   │   ├── getConversation.js
│   │   │   │   └── groupChat.js
│   │   │   ├── websocket/
│   │   │   │   ├── connect.js
│   │   │   │   ├── disconnect.js
│   │   │   │   └── message.js
│   │   │   └── utils/
│   │   └── serverless.yml
│   │
│   ├── llm-orchestrator/
│   │   ├── src/
│   │   │   ├── handlers/
│   │   │   │   ├── routeRequest.js
│   │   │   │   ├── generateResponse.js
│   │   │   │   └── multiAgent.js
│   │   │   ├── strategies/
│   │   │   │   ├── modelSelection.js
│   │   │   │   ├── promptGeneration.js
│   │   │   │   └── responseCoordination.js
│   │   │   ├── providers/
│   │   │   │   ├── anthropic.js
│   │   │   │   ├── openai.js
│   │   │   │   ├── bedrock.js
│   │   │   │   └── selfHosted.js
│   │   │   └── cache/
│   │   └── serverless.yml
│   │
│   ├── learning-service/
│   │   ├── src/
│   │   │   ├── handlers/
│   │   │   │   ├── subjects.js
│   │   │   │   ├── progress.js
│   │   │   │   └── assessment.js
│   │   │   ├── analytics/
│   │   │   └── content/
│   │   └── serverless.yml
│   │
│   ├── websocket-service/           # ECS Fargate
│   │   ├── src/
│   │   │   ├── server.js
│   │   │   ├── handlers/
│   │   │   ├── rooms/
│   │   │   └── state/
│   │   ├── Dockerfile
│   │   └── docker-compose.yml
│   │
│   └── data-pipeline/
│       ├── src/
│       │   ├── collectors/
│       │   │   ├── interactionCollector.js
│       │   │   └── socialSignalExtractor.js
│       │   ├── processors/
│       │   │   ├── anonymizer.js
│       │   │   └── scorer.js
│       │   └── storage/
│       └── serverless.yml
│
├── shared/                            # Shared libraries
│   ├── nodejs/
│   │   ├── auth/
│   │   │   └── verifyToken.js
│   │   ├── database/
│   │   │   ├── dynamoClient.js
│   │   │   └── models/
│   │   ├── cache/
│   │   │   └── redisClient.js
│   │   ├── monitoring/
│   │   │   ├── logger.js
│   │   │   └── metrics.js
│   │   └── utils/
│   │       ├── response.js
│   │       └── validators.js
│   │
│   └── python/                       # For ML services
│       ├── vector_store/
│       ├── embeddings/
│       └── fine_tuning/
│
├── models/                            # Self-hosted models
│   ├── llama3/
│   │   ├── model/
│   │   ├── tokenizer/
│   │   └── config.json
│   └── phi3/
│
├── scripts/
│   ├── migrations/
│   ├── seed/
│   └── cleanup/
│
├── tests/
│   ├── integration/
│   ├── load/
│   └── e2e/
│
├── .github/
│   └── workflows/
│       ├── deploy.yml
│       └── test.yml
│
├── package.json
├── serverless.yml                     # Root serverless config
└── README.md
```

## 2. Database Models (DynamoDB)

### 2.1 Table Structures

```yaml
Users Table:
  PartitionKey: userId (String)
  SortKey: "PROFILE"
  Attributes:
    - email: String
    - username: String
    - role: String
    - passwordHash: String
    - emailVerified: Boolean
    - createdAt: String (ISO)
    - lastActive: String (ISO)
    - subscription: Map
    - preferences: Map
  
  GSI1:
    PartitionKey: email
    SortKey: userId
  
  GSI2:
    PartitionKey: role
    SortKey: createdAt

StudentProfiles Table:
  PartitionKey: userId (String)
  SortKey: "STUDENT#${userId}"
  Attributes:
    - name: String
    - age: Number
    - gradeLevel: String
    - curriculum: String
    - location: Map
    - subjects: List
    - helpyId: String
    - learningStyle: String
    - parentIds: List
    - metadata: Map

Helpys Table:
  PartitionKey: helpyId (String)
  SortKey: "CONFIG"
  Attributes:
    - name: String
    - ownerId: String
    - personality: Map
    - avatar: String
    - voiceId: String
    - memories: List (max 100 recent)
    - relationshipDepth: Number
    - created: String
    - lastInteraction: String
    - stats: Map

Conversations Table:
  PartitionKey: conversationId (String)
  SortKey: "METADATA"
  Attributes:
    - type: String (individual/group)
    - participants: List
    - subject: String
    - created: String
    - lastMessage: String
    - messageCount: Number
    - isActive: Boolean

Messages Table:
  PartitionKey: conversationId (String)
  SortKey: timestamp#messageId
  Attributes:
    - messageId: String
    - senderId: String
    - senderType: String (human/helpy)
    - content: String
    - contentType: String
    - metadata: Map
    - reactions: Map
    - edited: Boolean
    - editedAt: String
  
  TTL: expiresAt (90 days for free tier)

GroupSessions Table:
  PartitionKey: sessionId (String)
  SortKey: "SESSION"
  Attributes:
    - name: String
    - subject: String
    - participants: Map (userId -> participantData)
    - helpys: Map (helpyId -> helpyData)
    - startTime: String
    - endTime: String
    - sessionType: String
    - metrics: Map
    - recordingUrl: String

Progress Table:
  PartitionKey: userId#subjectId
  SortKey: "PROGRESS"
  Attributes:
    - overallProgress: Number
    - currentTopic: String
    - completedTopics: List
    - assessments: List
    - studyTime: Number (minutes)
    - lastStudied: String
    - strengths: List
    - weaknesses: List
    - streakDays: Number

Prompts Table:
  PartitionKey: userId#helpyId
  SortKey: version
  Attributes:
    - basePrompt: String
    - academicPrompt: String
    - relationshipPrompt: String
    - objectivesPrompt: String
    - compiledPrompt: String (cached)
    - tokenCount: Number
    - lastUpdated: String
    - effectiveness: Number

InteractionLogs Table:
  PartitionKey: sessionId
  SortKey: timestamp#eventId
  Attributes:
    - eventType: String
    - participants: List
    - socialSignals: Map
    - learningOutcome: Map
    - qualityScore: Number
    - flaggedForTraining: Boolean
  
  TTL: expiresAt (365 days)
```

### 2.2 Access Patterns

```yaml
Access Patterns:
  User Queries:
    - Get user by ID
    - Get user by email
    - List users by role
    - Get user with profile
  
  Conversation Queries:
    - Get conversation by ID
    - List user conversations
    - Get recent messages
    - Get group participants
  
  Progress Queries:
    - Get student progress by subject
    - Get overall progress
    - Get recent assessments
    - Track study streaks
  
  Helpy Queries:
    - Get Helpy configuration
    - Update Helpy memories
    - Get Helpy by owner
    - List active Helpys in group
```

## 3. API Structure

### 3.1 REST API Endpoints

```yaml
Auth Endpoints:
  POST /auth/register
  POST /auth/login
  POST /auth/refresh
  POST /auth/logout
  POST /auth/verify-email
  POST /auth/reset-password

User Endpoints:
  GET /users/profile
  PUT /users/profile
  GET /users/{userId}
  PUT /users/{userId}/settings
  DELETE /users/{userId}

Student Endpoints:
  POST /students/onboarding
  GET /students/{studentId}/profile
  PUT /students/{studentId}/subjects
  GET /students/{studentId}/progress
  GET /students/{studentId}/schedule

Helpy Endpoints:
  POST /helpys/create
  GET /helpys/{helpyId}
  PUT /helpys/{helpyId}/personality
  PUT /helpys/{helpyId}/memories
  POST /helpys/{helpyId}/reset

Chat Endpoints:
  POST /chat/conversations
  GET /chat/conversations
  GET /chat/conversations/{conversationId}
  POST /chat/conversations/{conversationId}/messages
  GET /chat/conversations/{conversationId}/messages
  PUT /chat/conversations/{conversationId}/typing

Group Endpoints:
  POST /groups/sessions
  GET /groups/sessions/{sessionId}
  POST /groups/sessions/{sessionId}/join
  POST /groups/sessions/{sessionId}/leave
  GET /groups/sessions/{sessionId}/participants

LLM Endpoints:
  POST /llm/generate
  POST /llm/multi-agent
  GET /llm/models
  POST /llm/feedback

Learning Endpoints:
  GET /learning/subjects
  GET /learning/subjects/{subjectId}/topics
  POST /learning/assessments
  GET /learning/progress/{userId}
  POST /learning/practice

Subscription Endpoints:
  GET /subscriptions/plans
  POST /subscriptions/subscribe
  PUT /subscriptions/update
  DELETE /subscriptions/cancel
  GET /subscriptions/usage
```

### 3.2 WebSocket Events

```yaml
WebSocket Events:
  Connection:
    - connect: {userId, token}
    - disconnect: {userId}
    - ping/pong: heartbeat
  
  Messaging:
    - message.send: {conversationId, content, metadata}
    - message.receive: {message}
    - message.edit: {messageId, content}
    - message.delete: {messageId}
  
  Presence:
    - user.typing: {conversationId, userId, isTyping}
    - user.online: {userId}
    - user.offline: {userId}
  
  Group:
    - group.join: {sessionId, userId, helpyId}
    - group.leave: {sessionId, userId}
    - group.message: {sessionId, message}
    - helpy.thinking: {helpyId, isThinking}
    - helpy.response: {helpyId, response}
  
  Real-time Updates:
    - progress.update: {userId, subjectId, progress}
    - assessment.complete: {userId, score}
```

## 4. Lambda Functions

### 4.1 Function Organization

```yaml
Auth Functions:
  auth-login:
    Runtime: Node.js 18
    Memory: 256 MB
    Timeout: 10s
    Trigger: API Gateway POST /auth/login
  
  auth-register:
    Runtime: Node.js 18
    Memory: 256 MB
    Timeout: 15s
    Trigger: API Gateway POST /auth/register
  
  auth-verify:
    Runtime: Node.js 18
    Memory: 128 MB
    Timeout: 5s
    Trigger: API Gateway Authorizer

Chat Functions:
  chat-send-message:
    Runtime: Node.js 18
    Memory: 512 MB
    Timeout: 30s
    Trigger: API Gateway POST /chat/messages
  
  chat-process-group:
    Runtime: Node.js 18
    Memory: 1024 MB
    Timeout: 60s
    Trigger: SQS Queue
  
  websocket-connect:
    Runtime: Node.js 18
    Memory: 256 MB
    Timeout: 10s
    Trigger: WebSocket $connect
  
  websocket-message:
    Runtime: Node.js 18
    Memory: 512 MB
    Timeout: 30s
    Trigger: WebSocket message

LLM Functions:
  llm-router:
    Runtime: Python 3.11
    Memory: 512 MB
    Timeout: 5s
    Trigger: API Gateway POST /llm/generate
  
  llm-anthropic:
    Runtime: Python 3.11
    Memory: 1024 MB
    Timeout: 60s
    Trigger: SQS Queue
  
  llm-openai:
    Runtime: Python 3.11
    Memory: 1024 MB
    Timeout: 60s
    Trigger: SQS Queue
  
  llm-self-hosted:
    Runtime: Container
    Memory: 4096 MB
    Timeout: 120s
    Trigger: SQS Queue
  
  llm-multi-agent:
    Runtime: Python 3.11
    Memory: 2048 MB
    Timeout: 90s
    Trigger: Step Functions

Data Pipeline Functions:
  data-collector:
    Runtime: Python 3.11
    Memory: 512 MB
    Timeout: 60s
    Trigger: EventBridge (every 5 min)
  
  data-anonymizer:
    Runtime: Python 3.11
    Memory: 1024 MB
    Timeout: 300s
    Trigger: S3 Event
  
  data-scorer:
    Runtime: Python 3.11
    Memory: 2048 MB
    Timeout: 300s
    Trigger: SQS Queue
```

### 4.2 Step Functions

```yaml
Multi-Agent Orchestration:
  States:
    1. ReceiveMessage:
        Type: Task
        Resource: llm-router
    
    2. IdentifyHelpys:
        Type: Parallel
        Branches:
          - DetermineResponders
          - CheckResponseHistory
    
    3. GenerateResponses:
        Type: Map
        ItemsPath: $.helpys
        MaxConcurrency: 3
        Iterator:
          GenerateHelpyResponse
    
    4. CoordinateResponses:
        Type: Task
        Resource: llm-multi-agent
    
    5. SendResponses:
        Type: Task
        Resource: websocket-broadcast
```

## 5. ECS Services (Fargate)

### 5.1 WebSocket Service

```yaml
WebSocket Service:
  Task Definition:
    Family: helpy-websocket
    CPU: 1024
    Memory: 2048
    Image: helpy-websocket:latest
    
  Service:
    DesiredCount: 2
    MinHealthyPercent: 50
    MaxPercent: 200
    
  Auto Scaling:
    MinCapacity: 2
    MaxCapacity: 10
    TargetCPUUtilization: 70%
    
  Load Balancer:
    Type: Application
    Protocol: WebSocket
    HealthCheck: /health
```

### 5.2 Model Hosting Service

```yaml
Model Service:
  Task Definition:
    Family: helpy-llama
    CPU: 4096
    Memory: 16384
    Image: helpy-llama:latest
    GPU: 1
    
  Service:
    DesiredCount: 1
    PlacementStrategy: spread
    
  Auto Scaling:
    MinCapacity: 0
    MaxCapacity: 5
    RequestsPerTarget: 10
```

## 6. Caching Strategy

### 6.1 Redis Cache Structure

```yaml
Cache Keys:
  User Session:
    Key: session:{userId}
    TTL: 3600 (1 hour)
    Data: User object, permissions
  
  Helpy Prompt:
    Key: prompt:{userId}:{helpyId}
    TTL: 1800 (30 minutes)
    Data: Compiled prompt
  
  LLM Response:
    Key: response:{hash(prompt)}
    TTL: 86400 (24 hours)
    Data: Generated response
  
  Conversation:
    Key: conv:{conversationId}:messages
    TTL: 3600 (1 hour)
    Data: Recent 50 messages
  
  Progress:
    Key: progress:{userId}:{subjectId}
    TTL: 300 (5 minutes)
    Data: Progress object
```

### 6.2 CloudFront Cache

```yaml
CloudFront Behaviors:
  /api/*:
    CacheBehavior: NoCache
    Origin: API Gateway
  
  /static/*:
    CacheBehavior: CacheOptimized
    TTL: 31536000 (1 year)
    Origin: S3
  
  /models/*:
    CacheBehavior: CacheOptimized
    TTL: 86400 (1 day)
    Origin: S3
```

## 7. Security Configuration

### 7.1 IAM Roles

```yaml
Lambda Execution Roles:
  BasicLambdaRole:
    - CloudWatchLogs: Write
    - XRay: Write
  
  DatabaseLambdaRole:
    - DynamoDB: Read/Write on specific tables
    - KMS: Decrypt
  
  LLMLambdaRole:
    - Secrets Manager: Read API keys
    - S3: Read model files
    - SQS: Send/Receive messages
  
  WebSocketLambdaRole:
    - API Gateway: ManageConnections
    - DynamoDB: Read/Write connections table

ECS Task Roles:
  WebSocketTaskRole:
    - DynamoDB: Read/Write
    - CloudWatch: Write logs
    - Secrets: Read
  
  ModelTaskRole:
    - S3: Read models
    - CloudWatch: Write metrics
    - ECR: Pull images
```

### 7.2 API Security

```yaml
Security Measures:
  Authentication:
    - Cognito User Pools
    - JWT tokens
    - Refresh token rotation
  
  Authorization:
    - Lambda authorizers
    - Fine-grained permissions
    - Resource-based policies
  
  Rate Limiting:
    - API Gateway throttling
    - WAF rules
    - Per-user quotas
  
  Data Protection:
    - Encryption at rest (KMS)
    - Encryption in transit (TLS)
    - Field-level encryption for PII
```

## 8. Monitoring & Observability

### 8.1 CloudWatch Metrics

```yaml
Custom Metrics:
  LLM Performance:
    - ResponseTime
    - TokensUsed
    - ModelSelected
    - CacheHitRate
  
  User Engagement:
    - ActiveSessions
    - MessagesPerSession
    - StudyTimePerDay
    - GroupParticipation
  
  System Health:
    - WebSocketConnections
    - LambdaColdStarts
    - DatabaseThrottles
    - CacheEvictions
```

### 8.2 Alarms

```yaml
Critical Alarms:
  - LLM API Errors > 1%
  - WebSocket Disconnections > 5%
  - Database Throttling > 0
  - Lambda Concurrent Executions > 900
  - API Gateway 5xx > 1%

Warning Alarms:
  - Response Time > 2s
  - Cache Hit Rate < 50%
  - Lambda Duration > 50% timeout
  - ECS CPU > 80%
```

## 9. Cost Optimization

### 9.1 Resource Allocation

```yaml
Cost Optimization Strategies:
  Lambda:
    - Right-size memory allocations
    - Use ARM architecture (Graviton2)
    - Reserved concurrency for predictable workloads
  
  DynamoDB:
    - On-demand for dev/staging
    - Provisioned with auto-scaling for production
    - Use GSIs efficiently
  
  S3:
    - Intelligent-Tiering for models
    - Lifecycle policies for logs
    - CloudFront for static content
  
  ECS:
    - Spot instances for batch processing
    - Fargate Spot for non-critical services
    - Right-size task definitions
```

### 9.2 LLM Cost Management

```yaml
LLM Cost Controls:
  Routing Rules:
    Simple Queries -> Cached Response ($0)
    Basic Questions -> Llama 3 Self-hosted ($0.001)
    Complex Problems -> Claude/GPT-4 ($0.01-0.03)
  
  Caching Strategy:
    - Semantic similarity matching
    - Response reuse for common questions
    - Prompt template caching
  
  Usage Limits:
    Free Tier: 1000 tokens/day
    Starter: 10000 tokens/day
    Premium: 50000 tokens/day
    Elite: Unlimited
```

## 10. Deployment Pipeline

### 10.1 CI/CD Workflow

```yaml
GitHub Actions Workflow:
  On Push to Main:
    1. Run Tests:
       - Unit tests
       - Integration tests
       - Security scan
    
    2. Build:
       - Package Lambda functions
       - Build Docker images
       - Generate CloudFormation
    
    3. Deploy to Staging:
       - Update Lambda functions
       - Deploy ECS services
       - Run smoke tests
    
    4. Deploy to Production:
       - Manual approval
       - Blue/green deployment
       - Health checks
       - Rollback on failure
```

### 10.2 Environment Management

```yaml
Environments:
  Development:
    - Single region (us-east-1)
    - Minimal redundancy
    - Reduced instance sizes
    - Sample data only
  
  Staging:
    - Single region (us-east-1)
    - Production-like setup
    - Full feature set
    - Anonymized prod data
  
  Production:
    - Multi-region (us-east-1, ap-southeast-1)
    - Full redundancy
    - Auto-scaling enabled
    - Real user data
```