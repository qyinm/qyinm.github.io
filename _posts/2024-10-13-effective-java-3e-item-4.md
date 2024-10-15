---
title: '[Effective Jave 3/e] Item4 인스턴스화를 막으려거든 private 생성자를 사용하라'
description: 'Effective Java 3/e 정리. 주관적 해석을 곁들인'
date: 2024-10-13 13:11:00 +0900
categories: [Java, Effective Java 3/E]
tags: []
related_posts:
    - 2024-10-15-effective-java-3e-item-5.md
---

정적 메서드와 정적 필드만을 담은 클래스를 만들 때 처음 만드려는 의도대로 만들자.

정적 멤버만 담은 유틸리티 클래스는 인스턴스로 만들어 쓰려고 설계한 것이 아니다. 하지만 생성자를 명시하지 않는다면 컴파일러에서 자동으로 기본 생성자를 만든다.
매개변수가 없는 public 생성자가 자동으로 만들어진다. 이러헥 만들어진 생성자로 인해 클래스 사용자들은 인스턴스를 만들어도 되는 의도로 작성됐다고 오해가 가능하다.

추상 클래스로 만들어도 이를 상속해서 인스턴스화가 가능하다. 그러므로, **private 생성자를 추가해서 인스턴스화를 막아야 한다.**

```java
public class UtilityClass {
	// 기본 생성자가 만들어지는 것을 막음(인스턴스화 방지용).
	private UtilityClass() {
		throw new AssetionError();
	}
}
```
private 생성자로 만들어서 접근할 수 없어 굳이 Error을 만들 필요는 없다.
이렇게 하면 하위 클래스가 상위 클래스의 생성자 접근도 막아준다.