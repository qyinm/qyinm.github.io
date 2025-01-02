---
title: '[Spring🌱] JDBC, Spring JDBC, Spring JPA 개념과 사용법 총정리'
description: 'JDBC, Spring JDBC, 그리고 Spring JPA를 비교하고, 활용 예시 코드를 통해 차이점을 살펴보자.'
date: 2025-01-02 19:57:00 +0900
categories: [Backend, Spring]
tags: [JDBC, Spring JDBC, JPA, Hibernate, Java]
related_posts:
---

# JDBC, Spring JDBC, Spring JPA 개념과 사용법 총정리

데이터베이스와 상호작용하는 방식은 여러 가지가 있다. **JDBC**로 시작해, 이를 추상화한 **Spring JDBC**, 그리고 ORM 기반의 **Spring JPA**(Hibernate)까지 다양한 계층의 접근 방법이 존재한다. 이번 포스팅에서는 이 세 가지 기술의 특징과 사용법을 간략히 살펴보고, 예제 코드를 통해 차이점을 비교해본다.

## CommandLineRunner와 ApplicationRunner

Spring Boot 애플리케이션을 구동할 때, 특정 로직을 자동으로 실행하고 싶다면 `CommandLineRunner` 또는 `ApplicationRunner` 인터페이스를 사용할 수 있다.

```java
@Component
public class CourseJdbcCommandLineRunner implements CommandLineRunner {

    @Autowired
    private CourseJdbcRepository repository;

    @Override
    public void run(String... args) throws Exception {
        repository.insert();
    }
}
```

- **CommandLineRunner**: 스프링 애플리케이션이 가동된 직후 `run(String... args)` 메서드를 실행한다.
- **ApplicationRunner**: `CommandLineRunner`와 유사하지만, `run(ApplicationArguments args)` 형태로 인자를 전달받는다.

둘 중 하나를 선택해 개발 환경 및 필요에 따라 사용할 수 있다.

---

## JDBC

**JDBC (Java Database Connectivity)**는 자바에서 데이터베이스에 연결하고 SQL 쿼리를 실행하기 위한 표준 인터페이스이다. 가장 기본적인 접근 방식이며, 모든 DB 작업을 직접 처리한다.

아래 예시는 단순한 삭제 쿼리를 직접 수행하는 모습이다.

```java
public void deleteTodo(int id) {
    PreparedStatement st = null;
    try {
        st = db.conn.prepareStatement("delete from todo where id=?");
        st.setInt(1, id);
        st.execute();
    } catch (SQLException e) {
        logger.fatal("Query Failed : ", e);
    } finally {
        if (st != null) {
            try { st.close(); }
            catch (SQLException e) {}
        }
    }
}
```

### JDBC의 특징
- **직접적인 SQL 작성**: SQL 쿼리문을 직접 관리한다.
- **자세한 예외 처리 및 자원 관리 필요**: `try-catch-finally` 구문을 사용하여 커넥션, 스테이트먼트, 리소스 해제 등을 직접 처리해야 한다.
- **유연성 높음**: 원하는 대로 SQL 쿼리를 실행하고 커스터마이징할 수 있다.

---

## Spring JDBC

**Spring JDBC**는 JDBC를 더욱 간단히 사용할 수 있도록 도와주는 추상화 계층이다. `JdbcTemplate` 클래스를 통해 반복적인 코드(연결, 예외 처리 등)를 제거하고, SQL 실행 로직을 간단히 작성할 수 있게 해준다.

```java
@Repository
public class CourseJdbcRepository {

    @Autowired
    private JdbcTemplate springJdbcTemplate;

    private static final String INSERT_QUERY =
            """
            insert into course (id,name,author) values(2, 'azure', 'solo');
            """;

    public void insert() {
        springJdbcTemplate.update(INSERT_QUERY);
    }
}
```

- **JdbcTemplate**: SQL 실행(`update`, `queryForObject` 등)을 간단히 수행할 수 있도록 해준다.
- **코드 간결화**: 기존 JDBC보다 자원 관리와 예외 처리가 자동화되어 있다.

---

## JdbcTemplate과 queryForObject() 활용

### insert, delete 예시

```java
@Repository
public class CourseJdbcRepository {

    private static final String INSERT_QUERY = """
            insert into course (id, name, author) values(?, ?, ?);
            """;

    private static final String DELETE_QUERY = """
            delete from course where id = ?
            """;

    @Autowired
    private JdbcTemplate springJdbcTemplate;

    public void insert(Course course) {
        springJdbcTemplate.update(INSERT_QUERY,
                course.getId(), course.getName(), course.getAuthor());
    }

    public void deleteById(long id) {
        springJdbcTemplate.update(DELETE_QUERY, id);
    }
}
```

- **`update()`**: INSERT, DELETE, UPDATE 등 쿼리를 실행할 때 사용한다. 실행된 행(row)의 개수를 반환한다.

### `queryForObject()`와 RowMapper

단일 레코드를 조회할 때 주로 사용하는 메서드이다. 예를 들어, 특정 `id`로 **Course** 객체를 조회한다고 가정하자.

```java
public Course findById(long id) {
    String sql = "SELECT * FROM course WHERE id = ?";
    return springJdbcTemplate.queryForObject(
        sql,
        new BeanPropertyRowMapper<>(Course.class),
        id
    );
}
```

- **`queryForObject()`**: 첫 번째 인자로 SQL 쿼리, 두 번째 인자로 `RowMapper`, 세 번째 인자로 파라미터를 받는다.
- **BeanPropertyRowMapper**: SQL 결과를 Java 객체의 프로퍼티에 자동 매핑해준다. 필드 이름과 컬럼 이름이 일치하면 자동으로 할당한다.

#### RowMapper의 작동 원리
1. SQL 실행 결과인 `ResultSet`을 받는다.
2. `RowMapper` 구현체가 `ResultSet`의 각 컬럼을 Java 객체로 매핑한다.
3. 매핑된 객체를 반환한다.

---

## Spring JPA와 Hibernate

**JPA (Java Persistence API)**는 자바 진영에서 정의한 ORM(Object-Relational Mapping) 표준 인터페이스이다. **Hibernate**는 이 JPA 표준의 대표적인 구현체이다.

- **JPA**: 어떤 기능(메서드, API)을 가져야 하는지 명세한 인터페이스(표준).
- **Hibernate**: JPA 규격을 구현한 실제 구현체.  
  예를 들어, `@Entity`, `@Table`, `@Id` 등 애너테이션 기반으로 DB 테이블과 Java 객체를 매핑해준다.

### JPA 사용 시 장점
- **생산성**: 직접 SQL을 작성하지 않아도, 메서드 이름이나 JPA 쿼리(`JPQL`)로 쉽게 CRUD를 구현할 수 있다.
- **객체 지향적 데이터 접근**: 클래스와 필드만 정의해두면, JPA가 테이블과 자동으로 매핑해준다.
- **트랜잭션 및 캐싱**: 영속성 컨텍스트, 1차 캐시, 지연 로딩 등 다양한 기능으로 개발 생산성과 성능을 높인다.

#### 왜 직접 Hibernate를 사용하지 않고 JPA 코드를 쓰나?
- **구현체 교체 유연성**: Hibernate 외에도 EclipseLink, OpenJPA 등이 있다. JPA 코드를 사용하면 언제든 다른 구현체로 갈아탈 수 있다.
- **표준화**: JPA는 자바 진영에서 표준으로 인정받은 스펙이므로, 일관된 코드를 유지할 수 있다.

---

## JDBC vs Spring JDBC vs Spring JPA 비교

### 1) JDBC

- **직접 SQL 작성**: 자유도가 매우 높지만, 반복 코드가 많다.
- **예외 처리와 자원 관리**: 개발자가 세세하게 제어해야 함.
- **학습 곡선**: 쉽지만, 대규모 프로젝트에서는 유지보수성이 떨어질 수 있다.

### 2) Spring JDBC

- **`JdbcTemplate`**: 반복적인 DB 접근 로직을 추상화해 코드 간결화.
- **예외 변환**: SQL 예외를 Spring 예외로 변환해 일관된 처리가 가능.
- **적절한 추상화 수준**: SQL 중심 개발을 지원하면서도 반복 코드를 줄여줌.

### 3) Spring JPA (Hibernate)

- **ORM 기반**: 객체와 테이블 간 매핑에 집중. SQL 작성이 대폭 줄어듦.
- **자동 쿼리 생성**: 메서드 이름을 기반으로 자동으로 쿼리를 생성(`findById`, `findByName` 등).
- **높은 생산성**: 프로젝트가 커질수록 유지보수, 확장성이 탁월.

| 항목            | JDBC          | Spring JDBC           | Spring JPA (Hibernate)       |
| --------------- | ------------- | --------------------- | ---------------------------- |
| **추상화 수준** | 낮음          | 중간                  | 높음                         |
| **코드 간결성** | 낮음          | 높음                  | 매우 높음                    |
| **예외 처리**   | 직접 처리     | Spring 예외 변환 지원 | Spring 예외 변환 + ORM 지원  |
| **쿼리 작성**   | 직접 SQL 작성 | 직접 SQL 작성         | 메서드 기반 자동 생성 + JPQL |
| **유연성**      | 매우 높음     | 높음                  | 중간 (ORM 규칙에 따름)       |
| **학습 곡선**   | 낮음          | 낮음                  | 중간~높음                    |
| **유지보수성**  | 낮음          | 중간~높음             | 높음                         |

---

## 결론 🎯

프로젝트의 규모나 요구사항에 따라 **JDBC**, **Spring JDBC**, **Spring JPA**를 적절히 선택해야 한다.  

- **단순한 쿼리**나 **직접 제어가 필요한 경우**: JDBC 또는 Spring JDBC가 더 적합하다.  
- **대규모 엔터프라이즈 애플리케이션**이나 **객체 지향적 개발**을 선호하는 경우: Spring JPA(Hibernate)를 사용하는 편이 생산성과 유지보수성 측면에서 유리하다.

각각의 장단점을 잘 이해하고, 상황에 맞춰 적절히 활용하는 것이 중요하다.

---

## 참고자료 📚

- [Official JDBC Documentation](https://docs.oracle.com/javase/8/docs/technotes/guides/jdbc/)
- [Spring Framework Documentation (Spring JDBC)](https://docs.spring.io/spring-framework/docs/current/reference/html/data-access.html#jdbc)
- [Spring Boot JDBC Examples](https://www.baeldung.com/spring-jdbc-jdbctemplate)
- [Java Persistence API (JPA) Specification](https://jakarta.ee/specifications/persistence/)
- [Hibernate ORM Documentation](https://hibernate.org/orm/documentation/)