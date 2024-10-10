---
title: '[Effective Jave 3/e] Item1 생성자 대신 정적 팩터리 메서드를 고려할'
description: Spring 테스트 시 자주 사용되는 어노테이션과 함수, 기법들을 정리합니다.
date: 2024-10-09 23:43:00 +0900
categories: [Java, Effective Java 3/E]
tags: []
---

우리가 보통 클래스의 인스턴스를 얻을 때 생성자를 이용하여 얻는다.

예시: `Object a = new Object();`

하지만 이러한 방법 외에도 **정적 팩터리 메서드(static factory method)**라는 기법이 추가적으로 존재하며,
이를 이용함으로 장단점을 기술하겠습니다.
### 장점
#### 이름을 가진다

위의 예시처럼 우리가 생성자를 통해 인스턴스를 얻을 때 우리는 해당 인스턴스를 통해 어떠한 정보를 유추할 수가 없다.

만약 `BigInteger(int, int, Random)`과 `BigInteger.probablePrime()` 둘 중 어느 것이 더 인스턴스의 특성을 잘 나타낼 수 있을까?

후자의 경우 정적 팩터리 메서드를 사용해 소수인 값을 반환함을 유추가 가능하다.

반환 값의 유추 외에도 생성자를 추가해 인스턴스를 늘린다면 협업하는 개발자 입장에서 실수가 발생할 수 있다.

#### 호출될 때 마다 인스턴스 새로 생성하지 않음

정적인 메서드이기 때문에 객체를 생성하지 않고 실행 가능하다. 만약 정적으로 무언가를 자주 생성해서 반환한다면 객체의 생성은 성능면에서 떨어질 수가 있다.

`Boolean.valueOf(boolean)`메서드의 경우 객체를 아예 생성하지 않는다.

가변 데이터와 불변 데이터와 나누는 것이, Flyweight pattern도 이와 비슷한 기법이라 할 수 있다.
![flyweight-pattern](assets/img/post/2024-10-09-effective-java-3e-item-1/flyweight.png)_https://refactoring.guru/ko/design-patterns/flyweight_


#### 반환 타입의 하위 타입 객체 반환 가능

우리가 흔히 `List<Long> ids = new ArrayList<>();`와 같이 코딩을 하듯이 반환 타입으로 하위 타입 객체를 받을 수 있다.

Spring 개발할 때 DI(Dependency Injection)에서 느꼈던 편리함 같이 하위 타입으로 반환 받을 수 있는 것은 큰 편리함이다.

Java 8 이전에는 인터페이스 내에 정적 메서드를 가질 수 없어 암묵적으로 동반 클래스(Companion class)를 만들어 사용했다.

대표적으로 `java.util.Collection` 을 `java.util.Collections`가 동반 클래스로서 구현한다. Collection의 구현체는 인스턴스 불가한 Collections에서 정적 메서드로 받으며 반환 받은 인스턴스는 인터페이스로 다룰 수 있다.

#### 입력 매개변수에 따라 매번 다른 클래스 객체 반환

`EnumSet` 클래스의 경우 정적 팩터리만으로 제공된다. 해당 메서드에 매개변수에 따라 구현체가 다르다

OpenJDK의 경우 원소 수가 64이하면 `RegularEnumSet`, 이상이면 `JumboEnumSet`을 반환한다.
만약 원소 수에 따라 나눈 구현체의 성능 이점이 없다면 언제든 바꿀 수 있다.

개발자 입장에서는 반환받는 인스턴스 타입을 알 필요없고, 구현자 또한 언제든 **유연성** 있게 바꿀 수 있다.

#### 정적 팩터리 메서드 작성 시점에 반환 객체 클래스 존재 필요x
<!-- 
JDBC의 경우 Connection이 서비스 인터페이스, DriverManager.registerDriver 제공자 등록 API, DriverManager.getConnection 서비스 접근 API, Driver 서비스 제공자 인터페이스 역할을 한다. 이는 각각의 인터페이스에서  -->
<aside>
💡

이해가 되지 않으므로 조금 더 공부 해보겠습니다.

</aside>
### 단점
#### 상속을 위해 public/protected 생성자 필요

위의 장점인 반환 타입의 하위 타입 객체 반환이 가능하려면 어쩔 수 없이 상속 가능해야한다.

만약 정적 팩터리 메서드로만 정의가 되어 있다면 private인 생성자로 인해 상속(`super()`)이 불가. 그래서 생성자가 필요하다.

하지만 **다중 상속이(is-a)** 아닌 **컴포지션(has-a)**를 유도하는 제약 조건이 생긴 셈으로 오히려 장점으로 인식할 수도 있다.
#### 정적 팩터리 메서드를 개발자가 찾기 어려움
![difficult](assets/img/post/2024-10-09-effective-java-3e-item-1/item1-javadoc-find-difficult.png)

javadoc에서 객체의 생성자와 메서드로만 구분할 뿐 정적 팩터리 메서드와 구분하지 않는다.

그러므로 API에서 구분할 수 있게 잘 알려진 규칙대로 써야한다.
##### 네이밍 규칙

- **from**: 매개변수 하나 받아서 해당 타입의 인스턴스를 반환하는 형변환 메서드

    `Date d = Date.from(instant)`
- **of**: 여러 매개변수 받아 적합한 타입의 인스턴스 반환하는 집계 메서드

    `Set<Rank> faceCards = EnumSet.of(JACK, QUEEN, KING);`
- **valueOf**: from과 of의 더 자세한 버전

    `BigInteger prime = BigInteger.valueOf(Integer.MAX_VALUE);`
- **instance** 혹은 **getInstance**: (매개변수 받을 시) 매개변수로 명시한 인스턴스 반환, 같은 인스턴스 보장❌

    `StackWalker luke = StackWalker.getInstance(options);`
- **create** 혹은 **newInstance**: instance 혹은 getInstance와 같지만, 매번 새로운 인스턴스를 생성해 반환함을 보장

    `Object newArr = Array.newInstance(classObject, arrayLen);`
- **getType**: getInstance와 같으나, 생성할 클래스가 아닌 다른 클래스에 팩터리 메서드 정의 시 사용. "Type"은 팩터리 메서드가 반환할 객체의 타입이다

    `FileStore fs = Files.getFileStore(path);`
- **newType**: newInstance와 같으나, 생성할 클래스가 아닌 다른 클래스에 팩터리 메서드를 정의할 때 쓴다. "Type"은 팩터리 메서드가 반환할 객체의 타입

    `BufferedReader br = Files.newBufferedReader(path);`
- **type**: getType과 newType의 간결 버전

    `List<Complaint> litany = Collections.list(legacyLitany);`
