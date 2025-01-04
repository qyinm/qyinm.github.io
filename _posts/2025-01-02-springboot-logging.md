---
title: '[Spring🌱] 로깅(Logging) 완벽 가이드 📝'
description: 'Spring Boot 애플리케이션에서의 로깅 기능을 이해하고, 로깅 레벨 및 설정 방법을 알아본자.'
date: 2025-01-02 21:51:00 +0900
categories: [Backend, Spring]
tags: [Spring, Spring Boot, Logging, Logback, Log4j2, SLF4J]
related_posts:
---

# 스프링 부트 로깅(Spring Boot Logging) 완벽 가이드 📝

스프링 부트 애플리케이션은 **로깅(Logging)** 기능을 통해 애플리케이션 동작을 추적하고 문제를 진단할 수 있다. 이번 포스팅에서는 **Spring Boot 로깅**의 기본 동작 방식과 주요 설정 방법을 살펴보고, 실제 애플리케이션 코드에서 로깅을 어떻게 활용하는지에 대해 예제 코드를 통해 자세히 알아본다.

## 스프링 부트 로깅의 기본 원리

스프링 부트 애플리케이션은 기본적으로 **Spring Framework**에서 제공하는 `commons-logging` 라이브러리를 사용한다. 하지만 실제 로깅 구현체로는 **Logback**이 기본 채택되어 있다.

- **Commons Logging (JCL)**: 추상화 레이어 역할  
- **Logback**: 실제 로거(Logger) 구현체

즉, 스프링 부트는 `commons-logging`으로부터 로깅 호출을 받으면, 내부적으로 **Logback**을 통해 메시지를 출력한다.

### 장점

1. **일관된 로깅 API**: `commons-logging`을 통해 SLF4J, Log4j2, Logback 등 다양한 구현체로 쉽게 교체 가능  
2. **간단한 설정**: `application.properties`(또는 `.yml`) 파일을 통해 손쉽게 로깅 레벨 등을 변경할 수 있음

---

## 로깅 프레임워크 구조 이해

아래 그림은 흔히 볼 수 있는 Java 로깅 구조이다:

```
[Logger 호출부] -> [commons-logging or SLF4J] -> [실제 로깅 구현체(Logback, Log4j2...)]
```

스프링 부트에서는 기본적으로 다음 흐름을 따른다:

```
[애플리케이션 코드] -> [Commons Logging] -> [Logback]
```

원한다면 **Log4j2**로 교체할 수도 있다. SLF4J를 사용하는 방법도 비슷하다.

---

## 스프링 부트 기본 로깅 설정

스프링 부트의 **기본 로깅**은 Logback을 사용하며, 다음과 같은 특징을 가진다:

1. **기본 레벨**: `INFO`
2. **로그 출력 포맷**: 시간, 스레드, 로거 이름, 로그 레벨, 로그 메시지 형태로 콘솔 출력  
3. **컬러 지원**: 콘솔에서 로그 레벨별로 구분되는 컬러를 지원

스프링 부트는 `spring-boot-starter-logging` 라이브러리를 사용하며, 이는 Logback에 대한 기본 설정 파일(`logback.xml`)을 내장하고 있다.

---

## 로깅 레벨(Log Levels)

스프링 부트에서 지원하는 대표적인 로깅 레벨은 다음과 같다:

1. **TRACE**: 가장 상세한 로그 레벨. 개발 환경에서 주로 사용  
2. **DEBUG**: 디버깅을 위한 정보  
3. **INFO**: 일반 정보성 메시지  
4. **WARN**: 잠재적인 문제  
5. **ERROR**: 오류 발생 시 메시지  
6. **FATAL** (Log4j2 등 일부 라이브러리에서 사용): 치명적인 오류

**기본값**은 `INFO`이며, 개발 환경에서는 `DEBUG`나 `TRACE`로 세부 정보 로그를 확인할 수 있다.

---

## 설정 파일(application.properties) 예시

아래는 `application.properties`에서 로깅 레벨을 설정하는 예시이다:

```properties
# 스프링 로깅 레벨
logging.level.org.springframework=debug
logging.level.com.hippoo=trace

# 콘솔 출력 시, 컬러 활성화 여부
spring.output.ansi.enabled=ALWAYS

# 로그 패턴 변경
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n
```

- `logging.level.<패키지명>`: 특정 패키지나 클래스에 대한 로깅 레벨을 지정한다.  
- `spring.output.ansi.enabled`: 콘솔 로그에서 ANSI 컬러 코드를 활성화한다.  
- `logging.pattern.console`: 콘솔로 출력되는 로그의 패턴을 정의한다.

---

## Logback & Log4j2 설정 커스터마이징

### Logback 설정

스프링 부트에서 Logback 설정을 커스터마이징하려면 프로젝트 루트 경로에 `logback-spring.xml` 또는 `logback.xml` 파일을 작성한다.

```xml
<configuration>
    <property name="LOG_PATH" value="logs"/>
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} %-5level [%thread] %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${LOG_PATH}/myapp.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${LOG_PATH}/myapp-%d{yyyy-MM-dd}.%i.log</fileNamePattern>
            <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>10MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
            <maxHistory>30</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} %-5level [%thread] %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <logger name="com.hippoo" level="DEBUG" additivity="false">
        <appender-ref ref="FILE"/>
    </logger>

    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
        <appender-ref ref="FILE"/>
    </root>
</configuration>
```

- `<logger>` 태그를 통해 특정 패키지나 클래스의 로깅 레벨을 설정할 수 있다.  
- `<root>` 태그는 전체 로거에 대한 레벨을 설정한다.
- **파일 앱렌더**(`FILE`)를 추가하여 로그를 파일에도 출력하도록 설정했다.

### Log4j2 설정

Log4j2를 사용하고 싶다면 **`spring-boot-starter-logging`**을 제거하고, **`spring-boot-starter-log4j2`**를 추가한다. 그리고 `log4j2-spring.xml` 파일을 작성하여 설정하면 된다.

```xml
<Configuration status="WARN">
    <Appenders>
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout pattern="%d{yyyy-MM-dd HH:mm:ss} %-5level [%thread] %logger{36} - %msg%n"/>
        </Console>
        <File name="File" fileName="logs/myapp.log">
            <PatternLayout pattern="%d{yyyy-MM-dd HH:mm:ss} %-5level [%thread] %logger{36} - %msg%n"/>
            <Policies>
                <TimeBasedTriggeringPolicy />
                <SizeBasedTriggeringPolicy size="10MB"/>
            </Policies>
            <DefaultRolloverStrategy max="30"/>
        </File>
    </Appenders>

    <Loggers>
        <Logger name="com.hippoo" level="debug" additivity="false">
            <AppenderRef ref="File"/>
        </Logger>
        <Root level="info">
            <AppenderRef ref="Console"/>
            <AppenderRef ref="File"/>
        </Root>
    </Loggers>
</Configuration>
```

---

## SLF4J에서 Logging 파일 이름과 경로 설정하기 📁

**SLF4J (Simple Logging Facade for Java)**는 자바 애플리케이션에서 다양한 로깅 프레임워크(Logback, Log4j2 등)를 추상화하여 일관된 로깅 API를 제공하는 페이서(facade)이다. 스프링 부트에서는 SLF4J를 기본 로깅 API로 사용하며, 기본 구현체로 **Logback**을 채택하고 있다. SLF4J를 통해 로깅 파일의 이름과 경로를 설정하는 방법을 알아보자.

### 1. `application.properties`를 통한 설정

스프링 부트에서는 `application.properties` 또는 `application.yml` 파일을 통해 간단하게 로깅 파일의 이름과 경로를 설정할 수 있다. 이는 가장 손쉬운 방법으로, 별도의 설정 파일을 작성할 필요 없이 기본적인 로깅 설정을 관리할 수 있다.

```properties
# application.properties

# 로깅 파일 이름 설정
logging.file.name=logs/myapp.log

# 로깅 파일 경로 설정
logging.file.path=/var/log/myapp

# 또는 로깅 파일의 전체 경로를 설정할 수도 있다
logging.file=/var/log/myapp/myapp.log
```

- **`logging.file.name`**: 로깅 파일의 이름을 설정한다. 예를 들어, `logs/myapp.log`는 현재 디렉토리의 `logs` 폴더에 `myapp.log` 파일을 생성한다.
- **`logging.file.path`**: 로깅 파일이 저장될 디렉토리의 경로를 설정한다. 이 경우, `logging.file.name`과 함께 사용하여 파일 이름을 지정할 수 있다.
- **`logging.file`**: 로깅 파일의 전체 경로를 설정한다. 파일 이름과 경로를 한 번에 지정할 때 유용하다.

### 2. Logback 설정 파일(`logback-spring.xml`)을 통한 설정

보다 세밀한 로깅 설정이 필요하다면, `logback-spring.xml` 파일을 사용하여 SLF4J와 Logback을 커스터마이징할 수 있다. 이 방법을 사용하면 로그 파일의 형식, 롤링 정책, 로그 레벨 등을 상세하게 제어할 수 있다.

#### Logback 설정 예시

```xml
<!-- src/main/resources/logback-spring.xml -->

<configuration>

    <!-- 파일 경로와 이름을 프로퍼티로 설정 -->
    <property name="LOG_PATH" value="${LOG_PATH:-logs}"/>
    <property name="LOG_FILE" value="${LOG_FILE:-myapp.log}"/>

    <!-- 콘솔 로그 설정 -->
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} %-5level [%thread] %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <!-- 파일 로그 설정 -->
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${LOG_PATH}/${LOG_FILE}</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${LOG_PATH}/${LOG_FILE}.%d{yyyy-MM-dd}.%i.log</fileNamePattern>
            <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>10MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
            <maxHistory>30</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} %-5level [%thread] %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <!-- 특정 패키지에 대한 로깅 레벨 설정 -->
    <logger name="com.hippoo" level="DEBUG" additivity="false">
        <appender-ref ref="FILE"/>
    </logger>

    <!-- 루트 로거 설정 -->
    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
        <appender-ref ref="FILE"/>
    </root>

</configuration>
```

- **프로퍼티 설정**: `LOG_PATH`와 `LOG_FILE` 프로퍼티를 사용하여 로그 파일의 경로와 이름을 유연하게 관리할 수 있다. 환경 변수나 시스템 프로퍼티를 통해 값을 동적으로 설정할 수 있다.
- **콘솔 및 파일 앱렌더**: 로그를 콘솔과 파일 모두에 출력하도록 설정하였다. 파일 로그는 롤링 정책을 통해 일정 크기나 기간마다 새로운 로그 파일로 분리된다.
- **로거 설정**: 특정 패키지(`com.hippoo`)에 대해 별도의 로깅 레벨을 설정할 수 있다.
- **루트 로거**: 기본 로깅 레벨과 앱렌더를 설정한다. 모든 로그는 콘솔과 파일에 출력된다.

### 3. 환경 변수 또는 JVM 옵션을 통한 설정

스프링 부트 애플리케이션을 실행할 때, 환경 변수나 JVM 옵션을 통해 로깅 파일의 이름과 경로를 설정할 수도 있다.

#### 환경 변수 설정 예시

```bash
export LOG_FILE=/var/log/myapp/custom.log
export LOG_PATH=/var/log/myapp
java -jar myapp.jar
```

#### JVM 옵션 설정 예시

```bash
java -Dlogging.file.name=/var/log/myapp/custom.log -Dlogging.file.path=/var/log/myapp -jar myapp.jar
```

이 방법을 사용하면, 코드나 설정 파일을 수정하지 않고도 로그 파일의 위치와 이름을 변경할 수 있다.

### 4. 코드 내에서 로깅 설정 변경

코드 내에서 직접 로깅 설정을 변경하는 것은 권장되지 않지만, 필요한 경우 SLF4J API를 사용하여 로깅 레벨을 동적으로 변경할 수 있다. 다만, 이는 런타임 동안만 유효하며, 애플리케이션을 재시작하면 초기 설정으로 돌아간다.

```java
import org.slf4j.LoggerFactory;
import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.Level;

public void changeLogLevel(String loggerName, String levelStr) {
    Logger logger = (Logger) LoggerFactory.getLogger(loggerName);
    Level level = Level.toLevel(levelStr, Level.INFO);
    logger.setLevel(level);
}
```

---
    
## 실제 애플리케이션 코드에서 로깅 활용하기 🛠️

실제 애플리케이션 코드에서 로깅을 활용하는 방법을 예제 코드를 통해 살펴보자. SLF4J와 Logback을 사용하여 다양한 로깅 레벨로 메시지를 출력하는 방법을 설명한다.

### 1. SLF4J와 Logback을 이용한 로깅 설정

스프링 부트 프로젝트에서는 기본적으로 SLF4J와 Logback이 설정되어 있다. Lombok을 사용하면 로거 설정이 더욱 간편해진다. Lombok의 `@Slf4j` 애너테이션을 사용하여 로거를 자동으로 생성할 수 있다.

#### Lombok을 사용한 로깅 예시

```java
package com.hippoo.learnspringboot.controller;

import com.hippoo.learnspringboot.service.CourseService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/courses")
@Slf4j
public class CourseController {

    @Autowired
    private CourseService courseService;

    @GetMapping("/{id}")
    public Course getCourseById(@PathVariable Long id) {
        log.info("Fetching course with id: {}", id);
        Course course = courseService.findById(id);
        if (course == null) {
            log.warn("Course with id: {} not found", id);
        } else {
            log.debug("Course details: {}", course);
        }
        return course;
    }

    @PostMapping
    public Course createCourse(@RequestBody Course course) {
        log.info("Creating new course: {}", course.getName());
        Course createdCourse = courseService.save(course);
        log.info("Created course with id: {}", createdCourse.getId());
        return createdCourse;
    }

    @DeleteMapping("/{id}")
    public void deleteCourse(@PathVariable Long id) {
        log.info("Deleting course with id: {}", id);
        courseService.deleteById(id);
        log.info("Deleted course with id: {}", id);
    }
}
```

- **`@Slf4j`**: Lombok 애너테이션으로, 클래스 내에 `log` 변수를 자동으로 생성해준다.
- **로깅 메서드**: `log.info()`, `log.warn()`, `log.debug()`, `log.error()` 등을 사용하여 다양한 로깅 레벨로 메시지를 출력할 수 있다.
- **파라미터 바인딩**: `{}`를 사용하여 메시지에 변수를 삽입할 수 있으며, 이는 성능상 이점을 제공한다.

### 2. 직접 로거 생성하기

Lombok을 사용하지 않는 경우, SLF4J의 `LoggerFactory`를 이용하여 로거를 직접 생성할 수 있다.

#### 직접 로거를 생성한 로깅 예시

```java
package com.hippoo.learnspringboot.service;

import com.hippoo.learnspringboot.repository.CourseRepository;
import com.hippoo.learnspringboot.model.Course;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class CourseService {

    private static final Logger logger = LoggerFactory.getLogger(CourseService.class);

    @Autowired
    private CourseRepository courseRepository;

    public Course findById(Long id) {
        logger.info("Service: Fetching course with id: {}", id);
        try {
            Course course = courseRepository.findById(id);
            if (course == null) {
                logger.warn("Service: Course with id: {} not found", id);
            } else {
                logger.debug("Service: Found course: {}", course);
            }
            return course;
        } catch (Exception e) {
            logger.error("Service: Error fetching course with id: {}", id, e);
            throw e;
        }
    }

    public Course save(Course course) {
        logger.info("Service: Saving new course: {}", course.getName());
        try {
            Course savedCourse = courseRepository.save(course);
            logger.info("Service: Saved course with id: {}", savedCourse.getId());
            return savedCourse;
        } catch (Exception e) {
            logger.error("Service: Error saving course: {}", course.getName(), e);
            throw e;
        }
    }

    public void deleteById(Long id) {
        logger.info("Service: Deleting course with id: {}", id);
        try {
            courseRepository.deleteById(id);
            logger.info("Service: Deleted course with id: {}", id);
        } catch (Exception e) {
            logger.error("Service: Error deleting course with id: {}", id, e);
            throw e;
        }
    }
}
```

- **로거 생성**: `LoggerFactory.getLogger(CourseService.class)`를 통해 로거를 생성한다.
- **로깅 메서드**: 필요한 곳에서 `logger.info()`, `logger.warn()`, `logger.debug()`, `logger.error()` 등을 사용하여 메시지를 기록한다.
- **예외 로깅**: 예외 발생 시 `logger.error()`를 사용하여 스택 트레이스를 포함한 오류 메시지를 기록할 수 있다.

### 3. 로깅 레벨별 사용 사례

- **TRACE**: 매우 상세한 정보, 주로 개발 단계에서 사용  
  ```java
  log.trace("Trace log: Detailed debug information for tracing execution.");
  ```
  
- **DEBUG**: 디버깅을 위한 정보  
  ```java
  log.debug("Debug log: Variables state - userId={}, userName={}", userId, userName);
  ```
  
- **INFO**: 일반 정보성 메시지  
  ```java
  log.info("Info log: Application started successfully.");
  ```
  
- **WARN**: 잠재적인 문제  
  ```java
  log.warn("Warn log: Deprecated API usage detected.");
  ```
  
- **ERROR**: 오류 발생 시 메시지  
  ```java
  log.error("Error log: Failed to process request.", exception);
  ```

---

## 로깅 출력 위치와 롤링 파일 설정

- **출력 위치**: 기본적으로 콘솔(표준 출력)에 로그를 출력한다. 파일이나 원격 로깅 서버 등 다양한 위치로도 전송할 수 있다.
- **롤링 파일 설정**: 로그 파일의 크기가 커지면 자동으로 파일을 분할(롤링)하여 저장할 수 있다.  
  예를 들어, Logback의 `<rollingPolicy>`나 Log4j2의 `<RollingFile>` 등을 설정해서 구현한다.

### Logback 롤링 파일 설정 예시

```xml
<appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>logs/myapp.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
        <fileNamePattern>logs/myapp-%d{yyyy-MM-dd}.%i.log</fileNamePattern>
        <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
            <maxFileSize>10MB</maxFileSize>
        </timeBasedFileNamingAndTriggeringPolicy>
        <maxHistory>30</maxHistory>
    </rollingPolicy>
    <encoder>
        <pattern>%d{yyyy-MM-dd HH:mm:ss} %-5level [%thread] %logger{36} - %msg%n</pattern>
    </encoder>
</appender>
```

- **`<file>`**: 기본 로그 파일의 위치와 이름을 설정한다.
- **`<rollingPolicy>`**: 롤링 정책을 설정한다. 여기서는 시간 기반 롤링과 크기 기반 롤링을 결합하여, 매일 로그 파일을 분리하고 각 파일의 최대 크기를 10MB로 제한한다.
- **`<maxHistory>`**: 유지할 로그 파일의 개수를 설정한다. 여기서는 30일치 로그 파일을 유지한다.
- **`<pattern>`**: 로그 메시지의 포맷을 설정한다.

---

## 결론 🎯

**Spring Boot Logging**은 강력한 추상화 덕분에 애플리케이션 개발자가 복잡한 로깅 설정을 크게 신경 쓰지 않아도 되도록 도와준다. 상황에 따라 **Logback**, **Log4j2** 등 구현체를 자유롭게 선택할 수 있고, `application.properties`만으로도 충분히 간단한 설정이 가능하다.

**SLF4J**를 통해 로깅 API를 일관되게 사용할 수 있으며, 로깅 파일의 이름과 경로를 유연하게 설정할 수 있다. 기본 설정을 활용하거나, `logback-spring.xml`과 같은 설정 파일을 통해 세밀하게 조정할 수 있어 다양한 요구사항을 충족할 수 있다.

실제 애플리케이션 코드에서는 로깅을 적절한 레벨로 사용하여 애플리케이션의 상태를 효과적으로 추적하고, 문제 발생 시 신속하게 원인을 파악할 수 있도록 하는 것이 중요하다. 특히 **대규모 애플리케이션**에서는 **로깅 출력 위치, 롤링 정책, 레벨 설정** 등을 면밀히 검토해야 한다. **생산 환경**에서 로그가 너무 많으면 디스크나 네트워크 자원을 빠르게 소비할 수 있으므로, 적절한 **로그 레벨** 및 **로그 로테이션** 정책을 수립하는 것이 필수적이다.

---

## 참고자료 📚

- [Spring Boot Logging 공식 문서](https://docs.spring.io/spring-boot/reference/features/logging.html)
- [Spring Boot Logging 공식 문서 2](https://docs.spring.io/spring-boot/docs/2.1.8.RELEASE/reference/html/howto-logging.html)
- [Log4j2 공식 문서](https://logging.apache.org/log4j/2.x/manual/configuration.html)
- [Baeldung - Guide to SLF4J with Spring Boot](https://www.baeldung.com/spring-boot-logging)