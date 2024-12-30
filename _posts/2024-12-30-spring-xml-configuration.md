---
title: "[Spring🌱] XML Configuration 📄"
description: 'Spring Boot에서 XML을 사용한 설정 방법과 어노테이션과의 비교'
date: 2024-12-30 20:39:00 +0900
categories: [Backend, Spring]
tags: [Spring, XML, Configuration, Udemy]
related_posts:
---
## XML Configuration 🛠️

XML을 사용해 Bean을 설정 하는 것은 Annotation이 없던 시절에 사용됐으며 최근에는 거의 사용하지 않는다.

하지만 Legacy 코드를 보기 위해 볼 수도 있으니 이해가 필요하다.

### XML Configuration 예제 코드 📄

#### Java 코드

```java
package com.hippoo.studyspring.examples.h1;

import com.hippoo.studyspring.game.GameRunner;
import java.util.Arrays;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class XmlConfigurationContextLauncherApplication {

    public static void main(String[] args) {
        try (var context = new ClassPathXmlApplicationContext("contextConfiguration.xml")) {

            Arrays.stream(context.getBeanDefinitionNames()).forEach(System.out::println);

            System.out.println(context.getBean("name"));
            System.out.println(context.getBean("age"));
            context.getBean(GameRunner.class).run();
        }

    }
}
```

#### XML 설정 파일

```xml
위치: resources/contextConfiguration.xml

<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context" xsi:schemaLocation="
        http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">

    <bean id="name" class="java.lang.String">
        <constructor-arg value="Ranga"/>
    </bean>

    <bean id="age" class="java.lang.Integer">
        <constructor-arg value="35"/>
    </bean>

    <context:component-scan base-package="com.hippoo.studyspring.game"/>

    <bean id="game" class="com.hippoo.studyspring.game.PacmanGame"/>
    <bean id="gameRunner" class="com.hippoo.studyspring.game.GameRunner">
        <constructor-arg ref="game" />
    </bean>
</beans>
```

### 설명 📝

XML 파일을 통해 스프링 빈을 설정할 수 있으며, `<bean>` 태그를 사용하여 빈을 생성한다. 이는 `@Bean`, `@Component` 등의 어노테이션을 사용하는 것과 동일한 역할을 하며, 생성자 인수로 객체를 넘길 때는 `ref` 옵션을 추가하여 의존성을 주입한다.

예전에는 `@Configuration`, `@Component`, `@Bean`과 같은 어노테이션이 없었기 때문에 XML로 모든 설정을 했다. 최근에 만들어진 코드들은 설정을 어노테이션으로 주로 사용하지만, 여전히 기존의 XML 설정을 사용하는 프로젝트들이 많기 때문에 이를 이해가 필요하다.

## 어노테이션과 비교표 📊

아래 표는 XML 설정과 어노테이션 기반 설정의 주요 차이점을 비교한 것.

| 항목               | XML 설정                              | 어노테이션 기반 설정                          |
| ------------------ | ------------------------------------- | --------------------------------------------- |
| **설정 방식**      | XML 파일에 빈 정의                    | 코드 내 어노테이션 사용                       |
| **가독성**         | 설정 파일이 길어질 수 있음            | 코드와 설정이 밀접하게 연동되어 가독성이 좋음 |
| **유지보수성**     | 설정 변경 시 XML 파일 수정 필요       | 코드 변경과 동시에 설정도 변경 가능           |
| **의존성 주입**    | `ref`나 `value` 속성 사용             | 생성자, 필드, 세터를 통한 주입                |
| **유연성**         | 다양한 설정을 XML에서 쉽게 관리 가능  | 어노테이션을 통해 동적으로 설정 가능          |
| **디버깅**         | XML 설정 오류 시 런타임에서 발견 가능 | 컴파일 타임에 일부 오류 발견 가능             |
| **학습 곡선**      | XML 문법에 대한 이해 필요             | 자바 어노테이션에 대한 이해 필요              |
| **환경 설정 분리** | 설정과 코드가 명확히 분리됨           | 설정과 코드가 함께 존재함                     |

## Pros & Cons ⚖️

### Pros ✅

- **순수 자바로 POJO 유지**: XML 설정은 순수 자바 객체를 유지할 수 있어 테스트가 용이합니다.
- **디버깅이 조금 더 쉽다**: 어노테이션의 경우 스프링 프레임워크가 알아서 설정을 처리하기 때문에 프레임워크의 동작을 깊이 이해해야 하지만, XML 설정은 설정 파일을 직접 보고 이해할 수 있습니다.

### Cons ❌

- **유지보수가 힘들다**: XML 설정 파일이 커질수록 관리하기 어려워집니다.
- **장황하다**: 어노테이션에 비해 설정이 길어져 코드가 장황해질 수 있습니다.

## TIP 💡

**Annotation과 XML 중 하나만 사용해서 설정을 일관성 있게 유지.** 두 가지 방식을 혼용하면 설정의 복잡성이 증가하고 유지보수가 어려워질 수 있다.

## 참고자료 📚

- [Spring Framework XML Configuration Reference](https://docs.spring.io/spring-framework/docs/4.2.x/spring-framework-reference/html/xsd-configuration.html)
- [Spring Framework XSD Schemas](https://docs.spring.io/spring-framework/reference/core/appendix/xsd-schemas.html)
