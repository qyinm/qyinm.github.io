---
title: '[Effective Jave 3/e] Item7 다 쓴 객체 참조를 해제하라'
description: 'Effective Java 3/e 정리. 주관적 해석을 곁들인'
date: 2024-10-21 21:18:00 +0900
categories: [Java, Effective Java 3/E]
tags: []
related_posts:
    - effective-java-3e-item-8.md
    - effective-java-3e-item-57.md
---

자바와 같은 가바지 컬렉터를 가지고 있는 언어는 C,C++ 과 달리 메모리를 알아서 회수해가니 아주 편하다고 느껴진다.
하지만 이는 마법이 아니며 메모리 관리에 유의해야한다.

## 메모리 누수 예시
```java
public class Stack {
    private Object[] elements;
    private int size = 0;
    private static final int DEFAULT_INITAL_CAPACITY = 16;

    public Stack() {
        elements = new Object[DEFAULT_INITAL_CAPACITY];
    }

    public void push(Object e) {
        ensureCapacity();
        elements[size++] = e;
    }

    public Object pop() {
        if (size == 0) {
            throw new EmptyStackException();
        }
        return elements[--size];
    }

    /**
     * 원소를 위한 공간을 적어도 하나 이상 확보한다.
     * 배열 크기를 늘려야 할 때마다 대략 두 배씩 늘린다.
     */
    private void ensureCapacity() {
        if (elements.length == size) {
            elements = Array.copyOf(elements, 2 * size + 1);
        }
    }
}
```

위 스택에 대한 코드는 큰 문제 없어 보인다. 하지만 한 가지 문제가 있는데, 이는 바로 '메모리 누수'이다. 이 코드를 오래 사용하다 보면 가비지 컬렉션 활동과 메모리 사용량이 늘어나 성능저하가 발생한다. 
상대적으로 드문 경우지만 심할 때는 디스크 페이징 혹은 `OutOfMemoryError`를 일으켜 예기치 못하게 종료되기도 한다.


## 메모리누수 원인
### 1. 객체가 직접 메모리를 관리

**객체가 직접 메모리를 관리한다면 `null`처리를 해 메모리 누수에 주의 해야한다.**

위 코드에서 `pop()` 메서드에서 메모리 누수가 발생한다. size를 줄이기만 할 뿐 elements가 참조하고 있는 객체는 그대로 참조 상태이기 때문이다.
객체가 직접 메모리를 관리 할 때 발생한다 
#### 해결방법: null 처리
```java
public Object pop() {
    if (size == 0) {
        throw new EmptyStackException();
    }
    Object result = elements[--size];
    elements[size] = null;
    return result;
}
```
`pop()` 메서드는 그냥 기존에 참조 하던 것을 `null`처리 해주면 된다. 
#### 단점
하지만 만약 실수로 잘못 참조하게 되면 `null`을 참조하게 되어, `NullPointerException`이 발생할 수 있으니 조심해야한다.

또한 이렇게 모든 참조를 `null`처리 하게 된다면 코드 가독성을 해칠 수 있으므로 `null`처리는 예외적인 경우여야 한다. 다 쓴 참조를 해제하는 best practice는 그 참조를 담은 변수를 유효 범위(scope) 밖으로 밀어내는 것이다. 변수의 번위를 최소가 되게 정의했다면
(아이템 57)<!--[ ] 아이템 57 해결하기
 (![아이템 57]("https://qyinm.github.io/posts/effective-java-3e-item-57")) -->
자연스럽게 해결된다.

이러한 문제는 스택이 elements 배열로 풀을 만들어 객체를 관리하기 때문이다. size 변수 값에 따라 객체 사용 유무가 결정된다. 하지만 가비지 컬렉터는 사용되지 않는 객체를 판별할 수 없다. 따라서 `null`처리를 해야 가비지 컬렉터가 알수 있다.

### 2. 캐시 사용
#### 해결 방법:  WeakHashMap
캐시 사용 역시 메모리 누수가 일어난다. 우리가 `HashMap`을 사용해 캐싱 하는 경우가 있는데, 만약 캐시 외부에서 key값을 참조 하는 동안만 엔트리가 살아 있는 캐시가 필요하다면 차라리 `WeakHashMap`을 사용하는 것이 좋다. 다 쓴 엔트리(`WeakHashMap.remove` 된 것)은 그즉시 자동으로 가비지 컬렉터가 제거 해준다. 
> WeakHashMap은 key값을 참조하는 동안 엔트리가 살아 있는 캐시가 필요할 때만 유용하다.

<details>
    <summary>WeakHashMap 예제 코드</summary>
    <div markdown="1">
    
```java
import java.util.WeakHashMap;

public class CacheDemo {
    public static void main(String[] args) {
        WeakHashMap<Object, String> cache = new WeakHashMap<>();
        Object key = new Object();
        cache.put(key, "Cached Value");

        System.out.println("Before GC: " + cache);
            
        key = null; // Key에 대한 강한 참조를 제거
            
        System.gc(); // 강제로 GC 실행
        
        // 약한 참조는 수거될 수 있음
        System.out.println("After GC: " + cache);
    }
}
```
</div>
</details>


캐시를 만들 때 캐시 엔트리의 유효 기간을 정확히 정의하기 어렵기 때문에 시간이 지날 수록 엔트리의 가치를 떨어뜨리는 방식을 흔히 사용한다. 이런 방식은 쓰지 않는 엔트리를 가끔 청소해줘야 한다. (`ScheduledThreadPollExecutor` 같은) 백그라운드 스레드를 활용하거나 캐시에 엔트리를 추가할 때 부수 작업으로 수행하는 방법이 있다.
`LinkedHashMap`은 removeEldestEntry 메서드를 사용해 후자의 방식으로 처리한다. 더 복잡한 캐시는 `java.lang.ref`패키지를 직접 활용해야한다.


### 3. 리스너(listenr) 혹은 콜백(callback) 사용

클라이언트가 콜백을 등록만 하고 명확히 해지하지 않고, 조치를 취하지 않으면 콜백은 계속 쌓인다. 이럴 때 콜백을 약한 참조(weak reference)로 저장하면 가비지 컬렉터가 즉시 수거해간다. `WeakHashMap`을 사용한다.
<details>
<summary>예제 코드</summary>

<div markdown="1">

```java
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

interface EventListener {
    void onEvent();
}

class EventSource {
    private final List<WeakReference<EventListener>> listeners = new ArrayList<>();

    public void addListener(EventListener listener) {
        listeners.add(new WeakReference<>(listener));
    }

    public void triggerEvent() {
        for (WeakReference<EventListener> weakListener : listeners) {
            EventListener listener = weakListener.get();
            if (listener != null) {
                listener.onEvent();
            }
        }
    }
}
```
</div>
</details>

## Summary
> 메모리 누수는 겉으로 잘 알아내기 힘들다. 철저한 코드 리뷰나 힙 프로파일러 같은 디버깅을 도구를 동원해야만 발견되기도 하므로 위와 같은 예방법을 익혀 두자.