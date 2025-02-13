---
title: '[DB⛁] explaing 활용한 SQL 쿼리플래너, 옵티마이저 이해'
description: 'DB SQL query planner and optimizer'
date: 2025-02-13 10:00:00 +0900
categories: [DB]
tags: ['DB']
mermaid: true
related_posts:
    - database-indexing.md
---

## 쿼리 플래너와 옵티마이저란?


Postgres의 **쿼리 플래너**는 입력된 SQL 쿼리를 해석하고 가능한 여러 실행 계획을 도출한다. 그 후, **쿼리 옵티마이저**는 각 실행 계획의 예상 비용(cost)을 계산해 가장 효율적인 실행 계획을 선택한다. 이 과정은 인덱스 사용, 조인 순서, 서브쿼리 변환 등 다양한 최적화 기법을 포함한다.

---

## EXPLAIN 명령어의 기본 사용법

Postgres에서 **EXPLAIN** 명령어를 사용하면 쿼리 실행 계획을 미리 볼 수 있다. 예를 들어:

```sql
EXPLAIN SELECT * FROM posts WHERE likes > 100;
```

이 명령어는 쿼리 실행 단계, 예상 비용, 예상 행 수 등을 출력하여 쿼리의 성능 병목 지점을 파악할 수 있도록 해준다.

---

## EXPLAIN 출력 결과 주요 항목

EXPLAIN 출력 결과에서 중요한 항목은 다음과 같다:

### rows: 예상 행수

- **rows**: 쿼리 플래너가 해당 단계에서 스캔할 것으로 예상하는 행 수를 나타낸다.
- 예를 들어, 게시물의 좋아요 수를 대략적으로 집계할 때, **count(*)**를 실행하면 전체 테이블을 스캔하지만, EXPLAIN의 **rows** 통계를 활용하면 대략적인 수치를 훨씬 빠르게 파악할 수 있다.  
  → **성능 이점**: 대략적 수치가 요구되는 환경에서는 정확한 count(*) 대신 EXPLAIN의 rows 추정치를 활용하면 I/O 비용을 줄여 성능을 개선할 수 있다.

### width: 행의 폭과 전송 비용

- **width**: 한 행(row)의 평균 바이트 수를 나타낸다.
- **주의점**: `SELECT *`나 BLOB 타입의 컬럼을 포함할 경우, 반환되는 데이터의 폭이 커져 TCP 패킷 크기가 증가하고, 그에 따라 네트워크 전송 비용과 응답 시간이 증가할 수 있다.
  → **성능 고려**: 필요한 컬럼만 선택하여 width를 줄이면, 데이터 전송 효율이 개선된다.

### cost: 실행 비용과 초기 시간

- **cost**: 쿼리 실행 계획의 예상 비용으로, 시작 비용(startup cost)과 총 비용(total cost)으로 구분된다.
- **변화 요인**: ORDER BY 절이나 통계 함수(예: AVG, SUM 등)를 사용하는 경우, 정렬 및 추가 계산으로 인해 초기 비용이 크게 증가할 수 있다.
  → **참고**: 이 값은 단순 추정치이며, 실제 실행 시간은 다를 수 있다. 쿼리 복잡도에 따라 cost 값이 크게 변동할 수 있으므로 이를 참고하여 최적화 방안을 마련해야 한다.

---

## 성능 개선: count(*) vs. 행 통계 활용

게시물의 좋아요 수와 같이 대략적인 카운트가 필요한 경우, 정확한 **count(*)** 연산 대신 테이블 통계(예: pg_class의 통계 정보)나 EXPLAIN의 **rows** 추정치를 활용할 수 있다.  
- **count(*)**: 전체 테이블 스캔이 발생하여 비용이 많이 든다.  
- **행 통계 활용**: 데이터베이스 내부 통계나 EXPLAIN 결과를 참조하면 빠른 응답 속도를 얻을 수 있다.

이러한 방법은 대규모 데이터셋에서 성능 개선에 큰 도움을 줄 수 있다.

---

## ORDER BY, 통계 함수와 cost 변화

ORDER BY 절이나 통계 함수(AVG, SUM, COUNT 등)를 사용하면 쿼리 실행 과정에서 추가적인 정렬과 계산이 필요하다. 이로 인해:
- **초기 비용(startup cost)**: 정렬 준비 및 메모리 할당 등으로 인해 초기 비용이 증가한다.
- **총 비용(total cost)**: 전체 쿼리 실행 비용이 증가하며, EXPLAIN 결과의 cost 값이 상승한다.

따라서, 쿼리 작성 시 불필요한 ORDER BY나 통계 함수 사용을 피하고, 필요한 경우 인덱스 최적화나 쿼리 리팩토링을 통해 비용을 최소화하는 것이 중요하다.

---

## 실제 예제: Postgres EXPLAIN 사용법

다음은 Postgres에서 EXPLAIN 명령어를 사용하여 쿼리 실행 계획을 분석하는 예제이다.

### 예제 1: 단순 SELECT 쿼리

```sql
EXPLAIN SELECT id, title, likes FROM posts WHERE likes > 100;
```

출력 예시:
```plaintext
Seq Scan on posts  (cost=0.00..35.50 rows=150 width=24)
  Filter: (likes > 100)
```
- **rows**: 150 행을 예상함.
- **width**: 각 행의 평균 크기가 24바이트로 예상됨.
- **cost**: 총 비용이 35.50으로 추정됨.

### 예제 2: ORDER BY와 통계 함수 사용

```sql
EXPLAIN ANALYZE SELECT AVG(likes) FROM posts WHERE created_at > '2025-01-01';
```

출력 예시:
```plaintext
Aggregate  (cost=50.00..50.01 rows=1 width=8) (actual time=1.234..1.235 rows=1 loops=1)
  ->  Seq Scan on posts  (cost=0.00..45.00 rows=2000 width=4) (actual time=0.045..0.567 rows=2100 loops=1)
        Filter: (created_at > '2025-01-01'::timestamp)
```
- **cost**: Aggregate 단계의 비용이 높게 나타나며, ORDER BY나 집계 함수 사용으로 인해 초기 비용과 총 비용이 증가함을 보여준다.
- **rows**: 집계 결과는 단 한 행으로 예상됨.

---

## 결론 🎯

Postgres에서 **EXPLAIN** 명령어를 활용하면 SQL 쿼리의 실행 계획과 예상 비용, 행 수, 데이터 폭 등을 미리 파악할 수 있다.  
- **rows 통계**를 활용하면 대략적인 카운트가 필요한 환경에서 **count(*)** 대신 빠르게 결과를 예측할 수 있는 성능 이점을 얻을 수 있다.  
- **width**가 너무 커지면 불필요한 데이터를 전송하여 네트워크 비용이 증가할 수 있으므로, 필요한 컬럼만 선택하는 것이 좋다.  
- **cost** 값은 ORDER BY, 통계 함수 등의 사용으로 인해 크게 변화할 수 있으므로, 이를 최적화하기 위해 쿼리 구조를 신중하게 설계해야 한다.

이와 같은 분석을 통해 쿼리의 병목 지점을 식별하고, 효율적인 인덱스 설계와 쿼리 리팩토링을 통해 데이터베이스 성능을 크게 개선할 수 있다.
