# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Helpy Ninja is an AI-powered tutoring platform backend built with Spring Boot. The project focuses on multi-agent LLM interactions where multiple AI tutors collaborate in group learning sessions. This is the backend component that provides REST APIs and real-time communication capabilities.

## Development Commands

### Build and Run
- **Build project**: `./mvnw clean compile`
- **Run application**: `./mvnw spring-boot:run`
- **Run tests**: `./mvnw test`
- **Build JAR**: `./mvnw clean package`
- **Skip tests during build**: `./mvnw clean package -DskipTests`

### Development Tools
- **Hot reload**: Spring Boot DevTools is configured for automatic restart during development
- **Maven wrapper**: Use `./mvnw` instead of `mvn` to ensure consistent Maven version
- **Java version**: Java 17 LTS is required

## Architecture Overview

### Technology Stack
- **Framework**: Spring Boot 3.x with Spring Web and Spring WebSocket
- **Build Tool**: Maven with Maven wrapper
- **Java Version**: Java 17 LTS
- **Architecture Pattern**: Monolithic Spring Boot (current phase) transitioning to AWS Serverless (future)

### Key Dependencies
- Spring Boot Starter Web
- Spring Boot DevTools (development)
- Lombok (boilerplate reduction)
- Spring Boot Starter Test (testing framework)

### Target Architecture
- **Database**: DynamoDB with single-table design pattern
- **Caching**: Redis for distributed caching and session storage
- **LLM Integration**: Multi-provider strategy (Claude, GPT-4, Gemini, local models)
- **Real-time Communication**: WebSocket with STOMP for group sessions
- **Authentication**: JWT with AWS Cognito integration
- **Monitoring**: Micrometer with Spring Boot Actuator

## Directory Structure
```
src/
├── main/java/com/americanwor/helpy_backend/
│   └── HelpyBackendApplication.java (Main Spring Boot application)
└── test/java/com/americanwor/helpy_backend/
    └── HelpyBackendApplicationTests.java (Basic application tests)
```

## Development Guidelines

### Project Context
- This is a Spring Boot backend for an AI tutoring platform
- Focus on multi-agent LLM coordination and group learning sessions
- Mobile-first design with offline-first capabilities in mind
- Performance targets: <2s response latency, 99.9% uptime

### Daily Workflow (from info.txt)
- Start with `git pull origin main`
- Use feature branches: `git checkout -b feature/task-name`
- Follow repository → provider → UI architecture patterns
- Run quality checks before committing: tests and analysis
- Commit with proper conventional commit format

### Memory Bank
The `memory-bank/` directory contains important project context:
- `projectbrief.md`: Executive summary and business context
- `techContext.md`: Detailed technical architecture and decisions
- Review these files when making architectural decisions

## Key Features to Implement
- Multi-agent LLM coordination system
- Real-time group learning sessions via WebSocket
- User authentication and authorization
- Performance optimization for mobile clients
- Scalable architecture supporting millions of concurrent users

## Testing Strategy
- Use Spring Boot Test framework for integration tests
- Testcontainers for testing with real dependencies
- Load testing with JMeter for performance validation
- Target >80% test coverage

## Performance Considerations
- Virtual threads (Java 21) for improved concurrency
- Multi-level caching strategy (application, Redis, CDN)
- DynamoDB optimization with proper access patterns
- LLM response optimization with caching and streaming