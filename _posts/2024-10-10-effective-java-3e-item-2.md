---
title: '[Effective Jave 3/e] Item2 생성자에 매개변수가 많다면 빌더를 고려하라'
description: 'Effective Java 3/e 정리. 주관적 해석을 곁들인'
date: 2024-10-10 23:49:00 +0900
categories: [Java, Effective Java 3/E]
tags: []
---

개발을 하면서 우리는 정적 팩터리 혹은 생성자에서 공통적인 불편함을 느낄 것이다.

바로 매개변수를 많이 넘길 시 매개변수 순서 혼동이나 각 매개변수 구성에 맞는 구현을 해줘야하는 것이다.

필수로 받는 매개변수와 선택으로 받는 매개변수 마다 다르게 함수나 생성자를 만들 수는 없다. 물론 전체 매개변수를 갖는 메서드 하나와 매개변수 초기화를 이용한다면 어느정도 이를 해결할 수 있을지도 모른다.

개발자는 단순히 객체 생성시 값만 넣는 것이 아니라 유효성 검증과 같은 처리도 하기 때문에 이는 언젠가 매개변수가 많아질 때 큰 고민으로 올 것이다.

이러한 문제를 해결하는 것으로 JavaBeans pattern인 Setter와 Builder pattern이 있다.

## JavaBean Pattern
우리가 흔히 객체에서 사용하는 getter, setter를 활용한 패턴이다.
```java
class Member {
    private Long id;
    private String username;
    private String address;
    private int age;

    public Member member() {}

    public void setId(Long id) {
        this.id = id;
    }
    ...
}

class Main {
    public void main() {
        Member member = new Member();
        member.setId(1L);
        member.setUsername("kk");
        member.setAddress("Seoul, Republic of Korea");
        member.setAge(22);
    }
}
```
### Pros
인스턴스를 만들 때 길기만 한 매개변수를 없애고 좀 더 명확한 인스턴스 생성이 가능하다

### Cons
Setter는 크게 권장이 되지 않는다. 인스턴스 생성 단계에서 `new`로 이미 생성된 후 setter가 후처리를 하는 과정이다.
이렇게 되면 setter 호출 도중 참조가 된다면 **일관성**이 깨진다. 일관성을 유지하려면 개발자가 freezing을 수동으로 설정해줘야 하나 이는 번거롭다.

또한 **Member**객체에서 볼 수 있듯, setter함수는 public으로 되어있다. 다른 개발자가 마음대로 값을 변경할 수 있는 점에서 불변성 또한 만족하지 못한다.

오히려 setter는 생성자의 문제점을 해결한 것 같으나 단점이 더 많은 것 같다.

## Builder Pattern

```java
public class Notion {
	private String title;
	private String content;
	
	public Notion(String title, String content) {
		this.title = title;
		this.content = content;
	}

	public static Notion.NotionBuilder build() {
		return new Notion.NotionBuilder();
	}
	
	public static class NotionBuilder {
		private String title;
		private String content;

		NotionBuilder() {
		}
		
		public Notion.NotionBuilder title(String title) {
			this.name = name;
			return this;
		}
		public Notion.NotionBuilder content(String content) {
			this.content = content;
			return this;
		}
		public Notion build() {
			return new Notion(name, content);
		}
	}
}

Notion notion = Notion.build()
                .title("abc")
	        .content("def")
	        .build();
```

빌더 패턴은 위의 코드와 같이 구현이 된다. 
원리는 Builder 정적 클래스를 내부에 선언하고 Builder 클래스가 this를 반환하며 체이닝을 하게된다.
이 원리를 기반하여 매개변수명 함수에 값을 집어 넣으면 최종적으로 인스턴스가 만들어진다.

위의 JavaBeans Pattern의 단점을 상쇄해준다.

### 어노테이션 사용시 유의사항
평소 롬복(Lombok)을 통해 `@Builder`나`@Setter`같은 어노테이션을 활용하면 이와 같은 패턴들을 다 만들어준다.
하지만 Builder Patter은 마지막에 모든 매개변수를 넣는 생성자를 통해 인스턴스가 완성되며 반환된다.
그래서 `@NoArgsConstructor`를 사용한다면 꼭 `@AllArgsConstructor`도 사용해줘야 한다.

## 요약
> 매개변수가 4개 이하라면 생성자를 이용해도 괜찮으며, 그 이상이라면 빌더패턴 이용이 좋다
{: .prompt-tip }
