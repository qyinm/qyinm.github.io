---
title: '[DB⛁] 인덱스 이해 및 활용: Postgres 중심 ⛁'
description: 'Postgres에서 인덱스의 개념과 종류, 생성 방법 및 성능 개선 효과를 살펴본다.'
date: 2025-02-13 10:00:00 +0900
categories: [DB]
tags: ['DB', 'Postgres']
mermaid: true
related_posts:
    - db-acid.md
---

## 데이터 생성 예시

100만 건의 데이터를 생성하여 인덱스의 성능 효과를 확인할 수 있다. 아래는 Docker를 활용해 Postgres 컨테이너를 실행하고, 간단한 테이블을 생성한 후 데이터를 삽입하는 예제이다.

```docker
# Postgres 컨테이너 실행
docker run -e POSTGRES_PASSWORD=postgres --name pg postgres 

# Postgres에 접속하여 임시 테이블 생성
docker exec -it pg psql -U postgres -c "create table temp (t int);"

# 10만 건의 데이터를 생성 (예시로 10만 건; 실제 100만 건은 generate_series(0,1000000)을 사용)
docker exec -it pg psql -U postgres -c "insert into temp (t) select random()*100 from generate_series(0,100000);"
```

---

## 인덱스란?

인덱스는 데이터베이스 테이블의 특정 컬럼에 대해 별도의 자료구조를 생성하여, 데이터 검색 시 전체 테이블을 스캔하지 않고 빠르게 원하는 데이터를 찾도록 돕는다. 인덱스가 있으면 WHERE 조건에 해당하는 데이터를 효율적으로 조회할 수 있다.

### 인덱스의 종류

- **B-Tree 계열**: 대부분의 기본 인덱스이며, 균형잡힌 트리 구조를 통해 빠른 검색을 지원.
- **LSM 트리 계열**: 주로 쓰기 집약적인 환경에서 사용되며, 배치 처리에 유리.

---

## 테이블 및 데이터 생성

아래는 인덱스 강의를 위한 `employees` 테이블을 생성하고, 100만 건의 임의 데이터를 삽입하는 예제.

<details>
<summary>테이블/데이터 생성</summary>

<div markdown="1">

```sql
-- Postgres 컨테이너 실행 및 접속
docker run --name pg -e POSTGRES_PASSWORD=postgres -d postgres
docker start pg
docker exec -it pg psql -U postgres

-- employees 테이블 생성
CREATE TABLE employees (
    id serial PRIMARY KEY,
    name text
);

-- 임의 문자열 생성 함수 작성
CREATE OR REPLACE FUNCTION random_string(length integer) RETURNS text AS 
$$
DECLARE
    chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
    result text := '';
    i integer;
    length2 integer := (SELECT trunc(random() * length + 1));
BEGIN
    IF length2 < 0 THEN
        RAISE EXCEPTION 'Given length cannot be less than 0';
    END IF;
    FOR i IN 1..length2 LOOP
        result := result || chars[1 + random() * (array_length(chars, 1) - 1)];
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 100만 건의 데이터 생성
INSERT INTO employees(name)
SELECT random_string(10)
FROM generate_series(0, 1000000);
```

</div>
</details>

---

## 인덱스 성능 비교

Postgres에서 EXPLAIN ANALYZE를 사용하여 인덱스 적용 여부에 따른 쿼리 성능 차이를 확인할 수 있다.

### 1. 인덱스된 컬럼 및 인덱스된 WHERE 조건

```sql
EXPLAIN ANALYZE SELECT id FROM employees WHERE id = 1000;
```

**출력 예시:**

```plaintext
Index Only Scan using employees_pkey on employees  (cost=0.42..4.44 rows=1 width=4) (actual time=0.028..0.030 rows=1 loops=1)
   Index Cond: (id = 1000)
   Heap Fetches: 0
Planning Time: 0.092 ms
Execution Time: 0.051 ms
```

- 인덱스만으로 데이터를 조회하여 매우 빠른 응답 시간을 보여준다.

### 2. 인덱스된 WHERE 조건으로 인덱스되지 않은 컬럼 조회

```sql
EXPLAIN ANALYZE SELECT name FROM employees WHERE id = 1840;
```

**출력 예시:**

```plaintext
Index Scan using employees_pkey on employees  (cost=0.42..8.44 rows=1 width=6) (actual time=0.026..0.028 rows=1 loops=1)
   Index Cond: (id = 1840)
Planning Time: 0.076 ms
Execution Time: 0.104 ms
```

- WHERE 조건은 인덱스로 빠르게 처리되지만, 인덱스에 포함되지 않은 컬럼(name)을 조회할 경우 추가적인 테이블(Heap) 접근이 필요하여 시간이 다소 늘어난다.

### 3. 인덱스가 없는 컬럼에 대한 조회

```sql
EXPLAIN ANALYZE SELECT id FROM employees WHERE name = 'NM';
```

**출력 예시:**

```plaintext
Gather  (cost=1000.00..11310.94 rows=6 width=4) (actual time=6.634..36.562 rows=30 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on employees  (cost=0.00..10310.34 rows=2 width=4) (actual time=3.235..20.112 rows=10 loops=3)
         Filter: (name = 'NM'::text)
         Rows Removed by Filter: 333324
Planning Time: 0.106 ms
Execution Time: 36.592 ms
```

- 인덱스가 없는 컬럼(name)에 대한 조건은 순차 검색(Seq Scan)을 사용하여 전체 테이블을 스캔하므로 성능이 현저히 떨어진다.

#### 인덱스 생성

```sql
CREATE INDEX employees_name ON employees(name);
```

### 4. 인덱스 생성 후, 인덱스 기반 조회

```sql
EXPLAIN ANALYZE SELECT id FROM employees WHERE name = 'TT';
```

**출력 예시:**

```plaintext
Bitmap Heap Scan on employees  (cost=4.47..27.93 rows=6 width=4) (actual time=0.217..0.279 rows=26 loops=1)
   Recheck Cond: (name = 'TT'::text)
   Heap Blocks: exact=26
   ->  Bitmap Index Scan on employees_name  (cost=0.00..4.47 rows=6 width=0) (actual time=0.201..0.201 rows=26 loops=1)
         Index Cond: (name = 'TT'::text)
Planning Time: 0.090 ms
Execution Time: 0.305 ms
```

- 인덱스가 생성된 후, 인덱스 기반 Bitmap Scan을 통해 조회 속도가 개선되었다.

### 5. LIKE 조건의 경우

```sql
EXPLAIN ANALYZE SELECT id FROM employees WHERE name LIKE '%OOP%';
```

**출력 예시:**

```plaintext
Gather  (cost=1000.00..11319.34 rows=90 width=4) (actual time=4.130..31.376 rows=16 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on employees  (cost=0.00..10310.34 rows=38 width=4) (actual time=1.934..17.924 rows=5 loops=3)
         Filter: (name ~~ '%OOP%'::text)
         Rows Removed by Filter: 333328
Planning Time: 0.475 ms
Execution Time: 31.395 ms
```

- LIKE 패턴에 선행 와일드카드(`%`)가 포함되면 인덱스 사용이 어려워져 순차 스캔을 하므로 성능이 저하된다.

---

## TIP: MySQL vs PostgreSQL 기본키 탐색 방식

### MySQL (InnoDB)

- **기본키 = 클러스터형 인덱스**
- 기본키 조회 시 B+트리 인덱스의 리프 노드에서 바로 데이터를 조회하므로 추가적인 테이블 조회가 필요 없다.
- 읽기 성능이 매우 빠르다.

### PostgreSQL

- **기본키도 일반적인 B-트리 인덱스**
- 기본키 조회 시 B-트리 인덱스를 통해 TID(Heap Tuple Identifier)를 얻고, 별도의 Heap 조회가 발생한다.
- 추가적인 디스크 I/O가 발생할 수 있으나, Index-Only Scan이나 CLUSTER 명령어 등을 통해 성능을 개선할 수 있다.

| 비교 항목            | MySQL (InnoDB)              | PostgreSQL                      |
| -------------------- | --------------------------- | ------------------------------- |
| **기본 인덱스 구조** | 클러스터형 인덱스           | Heap + B-트리 인덱스            |
| **기본키 조회 과정** | B+트리에서 직접 데이터 조회 | B-트리 인덱스 → TID → Heap 조회 |
| **추가 디스크 I/O**  | 없음                        | 있음                            |
| **읽기 성능**        | 빠름                        | 상대적으로 느림                 |

---

## 결론

Postgres에서 인덱스는 데이터 검색 성능을 크게 향상시킨다.  
- **인덱스 적용**: 인덱스가 적용된 컬럼은 빠른 검색이 가능하며, EXPLAIN ANALYZE 결과에서 인덱스 스캔이 나타난다.
- **인덱스 미적용**: 인덱스가 없는 컬럼이나 불필요한 컬럼 전체 조회(SELECT *)는 네트워크 전송 비용과 I/O 부담을 증가시킨다.
- **LIKE 조건**: 선행 와일드카드 사용 시 인덱스 활용이 어려워진다.
- **기본키 탐색**: MySQL과 PostgreSQL의 기본키 인덱스 처리 방식은 차이가 있으며, PostgreSQL은 추가적인 Heap 조회가 발생할 수 있다.

이러한 분석을 통해 인덱스의 중요성을 인지하고, 쿼리 성능을 최적화하기 위한 인덱스 설계 및 쿼리 리팩토링이 필요하다.

---