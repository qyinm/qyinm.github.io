---
title: '[Effective Jave 3/e] Item5 자원을 직접 명시하지 말고 의존 객체 주입을 사용하라'
description: 'Effective Java 3/e 정리. 주관적 해석을 곁들인'
date: 2024-10-15 10:11:00 +0900
categories: [Java, Effective Java 3/E]
tags: []
related_posts:
    - effective-java-3e-item-6.md
---

## 유연하지 않은 객체

정적 유틸리티 클래스
```java
public class SpellChecker {
	private static final Lexicon dictionary = ...;

	private SpellChecker() {}

	public static boolean isValid(String word) {...}
	public static List<String> suggestions(String typo) {...}
}
```
싱글턴
```java
public class SpellChecker {
	private final Lexicon dictionary = ...;

	private SpellChecker(...) {}
	public static SpellChecker INSTANCE = new SpellChecker(...);

	public boolean isValid(String word) {...}
	public List<String> suggestions(String typo) {...}
}
```

위 두가지 방식의 클래스들은 `dictionary`이 하나로 고정되어 있다. 코드 자체를 변경하지 않는 한 `dictionary`를 변경할 수 없다.

클래스 내에 `changeDictionary`같은 메서드를 만들어 사용할 수도 있으나 `fianl`키워드를 빼야해 동시성 혹은 다른 곳에서 에러날 수 있다.

이러한 문제들은 의존 객체 주입(Dependency Injection)을 활용해 해결 가능하다. **인스턴스 생성시 생성자에 필요한 자원을 넘겨주는 방식**이다.

```java
public class SpellChecker {
	private final Lexicon dictionary = ...;

	public SpellChecker(Lexicon dictionary) {
		this.dictionary = Objects.requireNonNull(dictionary);
	}

	public boolean isValid(String word) {...}
	public List<String> suggestions(String typo) {...}
}
```

이렇게 되면 좀더 유연하고 테스트 용이하게 해줄 뿐 아니라, 빌터, 정적 팩터리 패턴에서 동일하게 응용 가능하다.

심지어 java8의 `Supplier<T>`를 활용해 팩터리를 넘기는 것이 가능하다.
이는 팩터리 메서드 패턴(Factory Method pattern)이다.

와일드 카드를 활용해 해당 타입의 하위 타입이라면 만들 수 있는 팩터리 메서드를 인자로 줄 수 있다.

`public create(Supplier<? extends Car> carFactory) {}`

의존성 주입이 많아지면 프로젝트가 많이 복잡해져 코드를 보기 어려워진다.
이는 의존 객체 주입 프레임워크(e.g. Spring)을 활용해 해소 가능하다.

## Summary
> 클래스가 내부적으로 하나 이상의 자원에 의존하고, 그 자원이 클래스 동작에 영향을 준다면 싱글턴, 정적 유틸리티 클래스 사용하지 않는 것이 좋다. 이 자원을 클래스가 직접 만들게 해서도 안된다. 의존 객체 주입으로 자원을 넘겨주자. 클래스의 유연성, 재사용성 테스트 용이성을 개선해준다.
{: .prompt-tip }