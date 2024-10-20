---
title: '[Effective Jave 3/e] Item6 불필요한 객체 생성을 피하라'
description: 'Effective Java 3/e 정리. 주관적 해석을 곁들인'
date: 2024-10-20 10:11:00 +0900
categories: [Java, Effective Java 3/E]
tags: []
related_posts:
    - effective-java-3e-item-7.md
    - effective-java-3e-item-67.md
    - effective-java-3e-item-83.md
    - effective-java-3e-item-50
---

Java로 개발을 하다보면 우리는 객체를 자주 생성한다.
객체의 생성 시 불필요한 자원들이 쓰일 수 있으므로 우리는 주의하며 개발해야한다.

### 불필요한 생성자 사용
#### String()
```java
String s1 = "Hello";
String s2 = new String("Hello");
```
s1, s2 모두 String 인스턴스가 만들어졌다. 하지만 둘의 차이점은 s1과 같이 ""(double quotes)로 인스턴스를 `String s3 = "Hello";` 이와 같이 생성했다면, 인스턴스를 새로 생성하는 것이 아닌 s1과 동일한 인스턴스가 재사용된다.

java에서 문자열 리터럴이 같은 모든 코드가 같은 객체를 재사용함이 보장된다.[[JLS,3.10.5]](https://docs.oracle.com/javase/specs/jls/se7/html/jls-3.html#jls-3.10.5)
#### Boolean
정적 팩터리 메서드를 이용해 불필요한 객체 생성을 피할 수 있다.
`Boolean(String)`생성자 대신에 `Boolean.valueOf(String)`의 사용으로 피할수 있다.
### 비싼 생성자
객체 중에서도 생성비용이 비싼 객체가 존재한다. 
```java
static boolean isRomanNumberal(String s) {
    return s.matches("^(?=.)M*(C[[MD]|D?C{0,3})"
            + "(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$");
}
```
위 방식은 `String.matches`를 사용함으로 정규표현식 문자열 형태를 확인하기 용이하지만, 성능에서 부족함이 생긴다.

메서드 내부에서 정규표현식용 `Pattern` 인스턴스가 일회용으로 사용되고 가비지 컬렉션 대상이 되기 때문이다.
`Pattern`은 입력 받은 정규표현식에 해당하는 유한 상태 머신을 만들기 대문에 인스턴스 비용이 높다.

따라서, 불변인 정규표현식은 `Pattern` 인스턴스를 객체 초기화 과정에서 정적으로 직접 생성해 캐싱하는 것이 좋다.

정규표현식이 사용되지 않으면 쓸데없는 초기화를 했다고 생각해 [지연 초기화]("https://qyinm.github.io/post/effective-java-3e-item-83")를 고려할수 있지만, 오히려 [성능은 크게 개선되지 않을때가 많으므로 권장되지 않는다]("https://qyinm.github.io/post/effective-java-3e-item-67").

```java
class RomanNumerals {
    static boolean isRomanNumberal(String s) {
        return s.matches("^(?=.)M*(C[[MD]|D?C{0,3})"
                + "(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$");
    }
}
```

### 재사용이 직관적이 않을 때
객체가 불면이라면 재사용해도 안전함이 명백하다. 하지만 이러한 직관에 반대되는 상황도 있다.

어댑터를(어댑터를 View라고도 한다) 생각했을 때, 어댑터는 실제 작업은 뒷단 객체에 위임하고 자신은 제 2의 인터페이스 역할을 한다. 어댑터는 뒷단 객체 하나만 관리 하면되므로 뒷단 객체 하나 당 어댑터 하나씩만 만들면 된다.

예를 들어 Map 인터페이스의 keySet 메서드는 Map 객체 안의 키 전부를 담은 Set 뷰를 반환한다. keySet 호출 시 인스턴스가 생성되리라 생각 할 수 있지만, keySet은 Map객체 안의 key 값들만 대면 함으로 가변이더라도 반환된 Set 들은 기능적으로 동일하다.
```java
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class Main {
    public static void main(String[] args) {
        // Map 객체 생성
        Map<String, Integer> map = new HashMap<>();
        map.put("Apple", 1);
        map.put("Banana", 2);
        map.put("Orange", 3);

        // Map의 keySet 메서드를 호출하여 키들의 Set 뷰 반환
        Set<String> keys1 = map.keySet();
        Set<String> keys2 = map.keySet();

        // keySet이 반환한 두 Set의 동일성 확인
        System.out.println("keys1 == keys2: " + (keys1 == keys2)); // true

        // map이 가변적이므로 keySet으로 반환된 Set도 영향을 받음
        System.out.println("Before modification: " + keys1); // [Apple, Banana, Orange]

        // Map 객체 수정
        map.put("Grape", 4);
        System.out.println("After modification: " + keys1); // [Apple, Banana, Orange, Grape]

        // Set에 값을 직접 추가하려고 하면 예외 발생
        try {
            keys1.add("Pineapple");
        } catch (UnsupportedOperationException e) {
            System.out.println("Cannot modify keySet directly.");
        }
    }
}
```

### 불필요한 오토박싱
```java
private static long sum(){
  Long sum = 0L;

  for (long i = 0; i< Integer.MAX_VALUE; i++)
    sum += i;

  return sum;
}
```
위 코드의 경우 long 타입의 값을 Long 타입에 더하기 위해서 long 타입을 값을 Long타입으로 변환 해서 더해주고 있다.

`Integer.MAX_VALUE`개 만큼 Long타입이 계속 생성되고 있어 성능 이슈가 생긴다.
이러한 경우 sum을 long으로만 변경하면 쉽게 해결가능하다.

**박싱된 기본 타입보다 기본 타입을 사용하고, 의도치 않은 오토박싱을 조심하자**

### 오해

'객체 생성은 비용이 비싸니 하지말자' 라는 것이 아니다. 요즘 JVM에서 별다른 일을 하지 않는 작은 객체를 생성하고 회수하는 것은 크게 부담되지 않는다. 프로그램의 명확성, 간결성, 기능을 위해서 객체를 추가로 생성하는 것이라면 일반적으로 좋다.

반대로 아주 무거운 객체가 아니고서 객체 풀(pool)을 만들지 말자. JPA에서 Hikaricp 같은 경우가 있지만, 데이터베이스의 경우 생성 비용이 비싸 재사용 하는 편이 낫다. 일반적으로 자체 객체 풀은 코드를 헷갈리게 하고 메모리 사용량을 늘려 성능을 떨어뜨린다. 요즘 JVM 가비지 컬렉터는 잘 최적화 되있어 가벼운 객체를 다룰 때는 직접 만든 객체 풀보다 빠르다.

### 방어적 복사
이번 아이템은 [방어적 복사(defensive copy)]("https://qyinm.github.io/post/effective-java-3e-item-50")를 다루는 아이템 50과 대조적이다. 이번 아이템이 "기족 객체를 재사용 해야한다면 새로운 객체를 만들지 마라" 라면, 아이템 50은 "새로운 객체를 만들어야 한다면 기존 객체를 재사용하지 마라"다.

>방어적 복사가 필요한 상황에서 객체를 재사용 했을 때 피해가, 필요 없는 객체를 반복 생성했을 때의 피해보다 훨씬 큼을 기억하자.
**방어적 복사에 실패하면 언제 터져 나올지 모르는 버그와 보안 구멍으로 이어지지만, 불필요한 객체 생성은 그저 코드 형태와 성능에만 영향을 준다.**
{: .prompt-tip }