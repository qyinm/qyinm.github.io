---
title: Junit5 정리
description: Spring 테스트 시 자주 사용되는 어노테이션과 함수, 기법들을 정리합니다.
date: 2024-10-05 12:36:00 +0900
categories: [Testing, Junit5]
tags: [Junit, Java]
---

Spring 테스트 시 자주 사용되는 어노테이션과 함수, 기법들을 정리합니다.
## Basic
### 생성 방법
intellij에서 테스트 하려는 코드에서 ⌘N 혹은 우클릭->Generate 클릭 후 Test를 클릭하면 자동으로 생성된다.
### 테스트 코드 구조
Given, When, Then 구조로 돼 있으며 함수에 무조건 @Test 어노테이션을 붙여 줘야한다. 없을 시 Error.

경우에 따라 When과 Then을 동시에 하기도 한다.
```java
class EventTest {
    @Test
    public void javaBean() {
        // Given
        String name = "Event";
        String description = "Spring";

        // When
        Event event = new Event();
        event.setName(name);
        event.setDescription("Spring");

        // Then
        assertThat(event.getName()).isEqualTo(name);
        assertThat(event.getDescription()).isEqualTo(description);
    }

    @Test
    public void createEvent_Bad_Request_Empty_Input() throws Exception {
        // Given
        EventDto eventDto = EventDto.builder().build();
        // When & Then
        this.mockMvc.perform(post("/api/events")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(this.objectMapper.writeValueAsString(eventDto)))
                .andExpect(status().isBadRequest());
    }
}
```

## Annotation
### DisplayName
![](/assets/img/post/2024-10-05-Junit5-정리/display-name.png){: .right w="200"}

테스트 코드 실행 시 IDE에서 테스트 설명이 보이게 해준다.

해당 어노테이션 없이 테스트 시 함수명으로 밖에 확인 해야 해 가독성이 떨어진다.

toss의 경우 테스트 코드 함수명을 한국어로 작성하면 서 이를 대체 하는 경우도 있다.
#### 예시
```java
@Test
@DisplayName("입력 값이 잘못된 경우에 에러가 발생하는 테스트")
void createEvent_Bad_Request_Wrong_Input() {
    // Given
    // When
    // Then
}
```

### ParameterizedTest
테스트 코드에 매개변수를 적용 할 수 있는 어노테이션이다. XOR같은 비트 연산에는 입력값의 경우가 4가지 이므로 원래라면 4개의 코드를 만들어야한다.

| A | B | result |
|---|---|--------|
| 0 | 0 | 0      |
| 0 | 1 | 1      |
| 1 | 0 | 1      |
| 1 | 1 | 0      |

이러한 경우 유용하게 쓰인다.
해당 어노테이션은 어떻게 파라미터 주는 방식 마다 다른 어노테이션과 함께 쓰인다.
#### @CsvSource
{}와 double quote(")로 감싸고 comma (,)로 나누며 'value='를 붙이는 건 option이다.
single quote (')은 double quote안에서 문자열로 사용되며 ''로 사용시 빈 값으로 인식된다.

##### Option
- nullValues: 특정 값 null 값 지정 

    `@CsvSource(value = { "apple, banana, NIL" }, nullValues = "NIL")`

- ignoreLeadingAndTrailingWhitespace: whitespace를 생략하는 것이 아닌 문자열 그대로로 인식

    `@CsvSource(value = { " apple , banana" }, ignoreLeadingAndTrailingWhitespace = false)`

```java
@ParameterizedTest
@CsvSource(value = {
        "0, 0, true",
        "0, 100, false",
        "100, 0, false",
})
public void testFree(int basePrice, int maxPrice, boolean isFree) {
    Event.EventBuilder builder = Event.builder();
    builder.basePrice(basePrice);
    builder.maxPrice(maxPrice);
    Event event = builder
            .build();

    event.update();

    assertThat(event.isFree()).isEqualTo(isFree);
}
```
#### @MethodSource
Method가 반환 한 값을 사용함. 함수명을 어노테이션에 값으로 줘야하지만 테스트코드 함수명과 동일한 함수명이면 자동으로 대입된다.

```java
@ParameterizedTest
@MethodSource("testFree")
// @MethodSource
public void testFree(int basePrice, int maxPrice, boolean isFree) {
    Event.EventBuilder builder = Event.builder();
    builder.basePrice(basePrice);
    builder.maxPrice(maxPrice);
    Event event = builder
            .build();

    event.update();

    assertThat(event.isFree()).isEqualTo(isFree);
}
private static Stream<Object[]> testFree() {
    return Stream.of(
            new Object[] {0, 0, true},
            new Object[] {100, 0, false},
            new Object[] {0, 100, false},
            );
}
```
![](/assets/img/post/2024-10-05-Junit5-정리/parameterized-csv-method.png){: .left}
_위 두 방식으로 했을 시 나오는 빌드 결과_
아래 어노테이션은 @ParameterizedTest을지원한다.
- @ValueSource
- @EnumSource
- @MethodSource
- @FieldSource
- @CsvSource
- @CsvFileSource
- @ArgumentsSource

추가 사항[Junit5 공식문서](https://junit.org/junit5/docs/current/user-guide/#writing-tests-parameterized-tests)

## Assert
editing..
### Exception
Junit5에서 예외상황에 대한 테스트는 아래와 같은 함수를 제공해준다.
Service단에서 user find 실패시 UsernameNotFoundException을 던지기도 한다. 이런 예외 상황을 테스트하는 경우도 많으므로 올고 있는 것이 좋다.
#### assertThrows
예외타입과 예외가 일어날 함수를 전달한다. 해당 함수가 발생하는 예외와 동일하면 테스트 통과된다.
예외타입은 subclass(상위)여도 통과된다.
assertThrows는 exception 객체를 반환해 해당 예외의 메시지도 동일한지 점검할 수 있다.
```java
@Test
public void findByUsernameFail() {
    String username = "random@email.com";
    UsernameNotFoundException exception = assertThrows(UsernameNotFoundException.class,
            () -> accountService.loadUserByUsername(username));

    assertThat(exception.getMessage()).isEqualTo(username);
}
@Test
void testExpectedExceptionIsThrown() {
    // The following assertion succeeds because the code under assertion
    // throws the expected IllegalArgumentException.
    // The assertion also returns the thrown exception which can be used for
    // further assertions like asserting the exception message.
    IllegalArgumentException exception =
        assertThrows(IllegalArgumentException.class, () -> {
            throw new IllegalArgumentException("expected message");
        });
    assertEquals("expected message", exception.getMessage());

    // The following assertion also succeeds because the code under assertion
    // throws IllegalArgumentException which is a subclass of RuntimeException.
    assertThrows(RuntimeException.class, () -> {
        throw new IllegalArgumentException("expected message");
    });
}

```
#### assertThrowsExactly
exactly라는 부사가 붙듯이 예외타입과 함수가 발생하는 예외와 정확이 타입이 동일해야한다.
#### assertDoesNotThrow
예외가 일어나면 안된다. 설명은 필요가 없을 것 같다.
```java
@Test
void testExceptionIsNotThrown() {
    assertDoesNotThrow(() -> {
        shouldNotThrowException();
    });
}

void shouldNotThrowException() {
}
```