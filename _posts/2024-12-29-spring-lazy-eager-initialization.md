---
title: '[Spring🌱] Bean 지연 초기화, 즉시 초기화'
description: 'Spring의 지연 초기화와 즉시 초기화의 차이를 확인해보자.'
date: 2024-12-29 15:00:00 +0900
categories: [Backend, Spring]
tags: ['Spring', 'Udemy']
related_posts: []
---

## 🌟 Spring에서의 초기화 방식: Lazy vs Eager

Spring에서 빈(bean)을 초기화하는 두 가지 방식인 지연 초기화(Lazy Initialization)와 즉시 초기화(Eager Initialization)가 있다.

---

### 🚀 즉시 초기화 (Eager Initialization)

Spring의 기본 설정은 **즉시 초기화**이다.  
컨테이너가 생성될 때 모든 빈을 즉시 생성하고 초기화 한다.  
애플리케이션 실행 시 빈이 이미 준비되어 있어, 바로 사용 가능하다는 장점이 있다.

#### **장점**
- 애플리케이션이 실행되는 동안에는 빈 초기화 지연이 없어 성능이 안정적.
- 초기화가 빨리 이루어지므로 디버깅 시 버그를 쉽게 찾을 수 있음.

#### **단점**
- 필요 없는 빈도 초기화하므로 메모리 낭비가 있을 수 있음.
- 애플리케이션 시작 시간이 길어질 수 있음.

---

### ⏳ 지연 초기화 (Lazy Initialization)

지연 초기화는 애플리케이션 실행 시 모든 빈을 초기화하지 않고, **필요할 때 초기화**하는 방식.  
`@Lazy` 어노테이션을 사용하면 특정 빈만 지연 초기화할 수도 있고, 전체 빈에 대해 지연 초기화를 활성화할 수도 있어.

#### **장점**
- 애플리케이션 시작 시간이 단축돼 초기 로딩이 빨라짐.
- 메모리 절약 가능.

#### **단점**
- 빈을 호출하는 시점에 초기화되므로 성능에 영향을 줄 수 있음.
- 초기화 타이밍이 명확하지 않아 디버깅이 어려울 수 있음.

---

### 📋 예제 코드

```java
package com.example.lazyinitialization;

import org.springframework.context.annotation.*;

@Component
class ClassA {
    public ClassA() {
        System.out.println("ClassA initialized");
    }
}

@Component
@Lazy
class ClassB {
    private final ClassA classA;

    public ClassB(ClassA classA) {
        System.out.println("ClassB initialized");
        this.classA = classA;
    }

    public void doSomething() {
        System.out.println("Doing something...");
    }
}

@Configuration
@ComponentScan
public class LazyInitializationExample {

    public static void main(String[] args) {
        var context = new AnnotationConfigApplicationContext(LazyInitializationExample.class);
        System.out.println("Context initialized");

        context.getBean(ClassB.class).doSomething();
    }
}
```

🖥️ 출력 결과

실행결과는 아래와 같음:
```
ClassA initialized
Context initialized
ClassB initialized
Doing something...
```
📌 요약
- 즉시 초기화: 컨테이너가 생성될 때 빈을 모두 초기화함. 애플리케이션 실행 중 성능이 안정적이지만 메모리 낭비가 발생할 수 있음.
- 지연 초기화: 필요한 시점에 빈을 초기화함. 메모리 절약과 빠른 초기 로딩이 가능하지만, 성능에 영향을 줄 수 있음.

💡 팁<br>
지연 초기화는 메모리와 성능 최적화가 필요할 때 유용함.
하지만 모든 빈에 적용하면 디버깅이 어려워질 수 있으므로 중요한 빈은 즉시 초기화를 유지하는 게 좋음.
