---
title: '[Spring🌱] application.properties 활용'
description: 'Spring Boot에서 application.properties를 활용하여 개발과 배포 환경을 효율적으로 관리하는 방법'
date: 2025-01-01 20:05:00 +0900
categories: [Backend, Spring]
tags: [Spring, Configuration, application.properties, Java, Udemy]
related_posts:
---
    
# Spring Boot에서 application.properties 프로필 관리
    
Spring Boot에서는 `application.properties` 파일을 통해 다양한 설정을 관리할 수 있다. 그러나 개발 환경과 배포 환경에서 필요한 설정이 다를 수 있기 때문에, 이를 효과적으로 관리하기 위해 프로필(Profile)을 사용하는 것이 중요하다. 이번 포스팅에서는 `application.properties`와 프로필을 활용하여 환경별 설정을 관리하는 방법과 이를 컴포넌트에서 활용하는 방법에 대해 자세히 알아본다.
    
## 프로필 나누기의 필요성🤔
    
개발 단계와 배포 단계에서는 서로 다른 설정이 필요할 수 있다. 예를 들어, 개발 환경에서는 디버깅을 위해 로깅 레벨을 높게 설정하고, 배포 환경에서는 성능을 최적화하기 위해 로깅 레벨을 낮출 수 있다. 이러한 설정을 하나의 파일에 모두 포함시키면 관리가 어려워지고, 실수로 잘못된 설정을 배포할 위험이 있다.
    
프로필을 나누어 관리하면 다음과 같은 장점을 얻을 수 있다:
    
- **환경별 설정 관리 용이**: 개발, 테스트, 배포 등 각 환경에 맞는 설정을 별도로 관리할 수 있다.
- **보안 강화**: 배포 환경에서는 민감한 정보를 숨길 수 있다.
- **유지보수성 향상**: 설정 파일이 명확하게 분리되어 관리가 쉬워진다.
    
## 프로필 설정 방법 📂
    
Spring Boot에서는 `application.properties` 또는 `application.yml` 파일을 기본 설정 파일로 사용한다. 여기에 각 프로필에 따른 설정 파일을 추가하여 환경별 설정을 관리할 수 있다.
    
### 설정 파일 예제 📄
    
#### 기본 설정 파일: `application.properties`
    
```properties
spring.application.name=learn-spring-boot
logging.level.org.springframework=debug

spring.profiles.active=dev

currency-service.url=https://qyinm.github.io
currency-service.username=qyinm
currency-service.key=defaultKey
```
    
#### 개발 프로필 설정 파일: `application-dev.properties`
    
```properties
spring.application.name=learn-spring-boot-dev
logging.level.org.springframework=trace

currency-service.url=https://dev.qyinm.github.io
currency-service.username=devUser
currency-service.key=devKey
```
    
#### 배포 프로필 설정 파일: `application-prod.properties`
    
```properties
spring.application.name=learn-spring-boot-prod
logging.level.org.springframework=error

currency-service.url=https://prod.qyinm.github.io
currency-service.username=prodUser
currency-service.key=prodKey
```
    
### 설명 📝
    
- **기본 설정 파일 (`application.properties`)**: 모든 프로필에서 공통으로 사용하는 설정을 정의한다.
- **프로필별 설정 파일 (`application-dev.properties`, `application-prod.properties`)**: 특정 프로필에서만 적용되는 설정을 정의한다. 예를 들어, `dev` 프로필에서는 개발 환경에 맞는 설정을, `prod` 프로필에서는 배포 환경에 맞는 설정을 정의한다.
    
## 프로필 활성화 방법 🔧
    
Spring Boot에서는 `spring.profiles.active` 속성을 사용하여 활성화할 프로필을 지정한다. 이 속성은 기본 설정 파일에 정의하거나, JVM 옵션을 통해 지정할 수 있다.
    
### 방법 1: 기본 설정 파일에서 활성화
        
```properties
spring.profiles.active=dev
```
    
### 방법 2: JVM 옵션을 통해 활성화
        
애플리케이션을 실행할 때 JVM 옵션을 추가하여 프로필을 활성화할 수 있다.
    
```bash
java -jar -Dspring.profiles.active=prod learn-spring-boot.jar
```
    
### 방법 3: 환경 변수를 통해 활성화
        
환경 변수를 설정하여 프로필을 활성화할 수도 있다.
    
```bash
export SPRING_PROFILES_ACTIVE=prod
```
    
## Component에서 값 가져와 쓰기 📝
    
Spring Boot에서는 `@ConfigurationProperties` 어노테이션을 사용하여 프로퍼티 값을 컴포넌트에 주입할 수 있다. 이를 통해 환경별로 다른 설정 값을 손쉽게 관리할 수 있다.
    
### 코드 예제 📄
    
#### `CurrencyController.java`
    
```java
package com.hippoo.learnspringboot;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CurrencyController {

    @Autowired
    private CurrencyServiceConfiguration configuration;

    @GetMapping("/currency-configuration")
    public CurrencyServiceConfiguration retrieveCurrencyConfiguration() {
        return configuration;
    }
}
```
    
#### `CurrencyServiceConfiguration.java`
    
```java
package com.hippoo.learnspringboot;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@ConfigurationProperties(prefix = "currency-service")
@Component
public class CurrencyServiceConfiguration {

    private String url;
    private String username;
    private String key;

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }
}
```
    
### 설정 파일 예제 📄
    
#### `application.properties`
    
```properties
spring.application.name=learn-spring-boot
logging.level.org.springframework=debug

spring.profiles.active=dev

currency-service.url=https://qyinm.github.io
currency-service.username=qyinm
currency-service.key=defaultKey
```
    
#### `application-dev.properties`
    
```properties
spring.application.name=learn-spring-boot-dev
logging.level.org.springframework=trace

currency-service.url=https://dev.qyinm.github.io
currency-service.username=devUser
currency-service.key=devKey
```
    
이렇게 설정하면, 활성화된 프로필에 따라 다른 설정 값이 `CurrencyServiceConfiguration` 컴포넌트에 주입된다.
    
## 프로필 사용 시 주의사항 ⚠️
    
프로필을 사용할 때 다음 사항을 유의해야 한다:
    
- **프로필 파일 명명 규칙 준수**: `application-{profile}.properties` 또는 `application-{profile}.yml` 형식을 따라야 한다.
- **필수 프로퍼티 확인**: 특정 프로필에서만 필요한 프로퍼티가 있다면, 해당 프로필 파일에 누락되지 않도록 주의해야 한다.
- **보안 정보 관리**: 민감한 정보는 프로필별 설정 파일에 저장하지 않고, 환경 변수나 시크릿 관리 도구를 사용하는 것이 좋다.
- **프로필 혼용 피하기**: 한 환경에 여러 프로필을 동시에 활성화하면 설정 충돌이 발생할 수 있으므로, 명확히 구분된 프로필을 사용하는 것이 좋다.
    
## 결론 🎯
    
Spring Boot의 프로필 기능을 활용하면 개발, 테스트, 배포 등 다양한 환경에서 필요한 설정을 효율적으로 관리할 수 있다. 프로필을 나누어 설정 파일을 분리하면 프로젝트의 유지보수성이 향상되고, 환경별로 최적화된 설정을 적용할 수 있다. 또한, `@ConfigurationProperties`와 같은 어노테이션을 활용하면 코드에서 설정 값을 쉽게 주입받아 사용할 수 있다.
    
프로젝트의 복잡성이 증가함에 따라 프로필을 적절히 활용하여 환경별 설정을 체계적으로 관리해보자. 이를 통해 더욱 견고하고 유연한 Spring Boot 애플리케이션을 구축할 수 있을 것이다.
    
## 참고자료 📚
    
- [Spring Boot Profiles Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.profiles)
- [Configuration Properties in Spring Boot](https://www.baeldung.com/configuration-properties-in-spring-boot)
- [Spring Boot Logging](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.logging)
