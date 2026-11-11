# Lab 11: Indexes and Storage Structures

**Database:** `storage_demo` (PART 5 of `sql/year1_sql_lab.sql`)

**What you will learn**

- see why a full table scan is slow on a big table
- create B-tree indexes and see the effect with `EXPLAIN`
- see that a hash index helps exact matches but not ranges

## Before you start

1. Open `sql/year1_sql_lab.sql` in MySQL Workbench and run **PART 5** (select it, then **Ctrl + Shift + Enter**).
2. Open a new query tab and start it with `USE storage_demo;`
3. Try each question yourself **first**, then compare with the expected output. Open **Show the code** only if you are stuck.
4. `EXPLAIN` in front of a `SELECT` shows how MySQL **would** run it. Read three columns: **type** (`ALL` = read every row; `ref`, `const`, `range` = use an index), **key** (the index used, or `NULL`) and **rows** (how many rows it expects to read). `rows` is an estimate, so yours may differ a little.

## Question 1

How many rows does `BIGEMP` hold?

**Expected output**

| num_rows |
|---|
| 100000 |

<details>
<summary>Show the code</summary>

```sql
SELECT COUNT(*) AS num_rows FROM BIGEMP;
```

</details>

## Question 2

Use `EXPLAIN` to see how MySQL finds the employee named `emp50000` when there is **no index** on `ename`.

> **Hint:** `type ALL` and `key NULL` mean a **full table scan**: every row is read, like searching an unordered file.

**Expected output**

| type | key | rows |
|---|---|---|
| ALL | NULL | 100,000 |

<details>
<summary>Show the code</summary>

```sql
EXPLAIN SELECT * FROM BIGEMP WHERE ename = 'emp50000';
```

</details>

## Question 3

Now `EXPLAIN` a search for `empid = 50000`.

> **Hint:** `empid` is the **primary key**, and MySQL keeps a **B-tree** index on it automatically. One row is expected instead of 100,000.

**Expected output**

| type | key | rows |
|---|---|---|
| const | PRIMARY | 1 |

<details>
<summary>Show the code</summary>

```sql
EXPLAIN SELECT * FROM BIGEMP WHERE empid = 50000;
```

</details>

## Question 4

(a) Create a **B-tree index** `idx_ename` on `ename`. (b) Run the `EXPLAIN` from Question 2 again.

> **Hint:** The syntax is `CREATE INDEX indexname ON tablename (columnname) USING BTREE`.

**Expected output**

**(a) create**

_No result rows. Action Output: 0 row(s) affected._

**(b) EXPLAIN again**

| type | key | rows |
|---|---|---|
| ref | idx_ename | 1 |

<details>
<summary>Show the code</summary>

**(a) create**

```sql
CREATE INDEX idx_ename ON BIGEMP (ename) USING BTREE;
```

**(b) EXPLAIN again**

```sql
EXPLAIN SELECT * FROM BIGEMP WHERE ename = 'emp50000';
```

</details>

## Question 5

List the indexes on `BIGEMP`.

**Expected output**

| Key_name | Column_name | Index_type |
|---|---|---|
| PRIMARY | empid | BTREE |
| idx_ename | ename | BTREE |

_SHOW INDEX shows more columns; only these three are shown here._

<details>
<summary>Show the code</summary>

```sql
SHOW INDEX FROM BIGEMP;
```

</details>

## Question 6

A **range** search: employees earning between 20,000 and 20,100. (a) `EXPLAIN` it. (b) Create an index on `salary`. (c) `EXPLAIN` it again.

> **Hint:** A B-tree keeps values in order, so MySQL finds the first match and reads along the leaves (`type range`). That is why a B-tree is good for both direct and sequential access.

**Expected output**

**(a) before**

| type | key | rows |
|---|---|---|
| ALL | NULL | 100,000 |

**(b) create**

_No result rows. Action Output: 0 row(s) affected._

**(c) after**

| type | key | rows |
|---|---|---|
| range | idx_salary | 253 |

<details>
<summary>Show the code</summary>

**(a) before**

```sql
EXPLAIN SELECT * FROM BIGEMP WHERE salary BETWEEN 20000 AND 20100;
```

**(b) create**

```sql
CREATE INDEX idx_salary ON BIGEMP (salary);
```

**(c) after**

```sql
EXPLAIN SELECT * FROM BIGEMP WHERE salary BETWEEN 20000 AND 20100;
```

</details>

## Question 7

**Hashing.** MySQL supports hash indexes only in `MEMORY` tables. (a) Create `EMPMEM` with hash indexes. (b) Copy the first 20,000 employees into it. (c) `EXPLAIN` an exact match. (d) `EXPLAIN` a range search.

> **Hint:** A hash index goes straight to a record from its value, which is excellent for an **exact** match, but the values are scattered, not in order, so it **cannot help a range**. (Ordinary InnoDB tables silently turn `USING HASH` into a B-tree.)

**Expected output**

**(a) create**

_No result rows. Action Output: 0 row(s) affected._

**(b) copy**

_No result rows. Action Output: 20000 row(s) affected._

**(c) exact match**

| type | key | rows |
|---|---|---|
| ref | idx_hash_ename | 2 |

**(d) range**

| type | key | rows |
|---|---|---|
| ALL | NULL | 20,000 |

<details>
<summary>Show the code</summary>

**(a) create**

```sql
CREATE TABLE EMPMEM (
  empid   INT NOT NULL,
  ename   VARCHAR(20) NOT NULL,
  salary  DECIMAL(8,2) NOT NULL,
  PRIMARY KEY (empid),
  INDEX idx_hash_ename  USING HASH (ename),
  INDEX idx_hash_salary USING HASH (salary)
) ENGINE = MEMORY;
```

**(b) copy**

```sql
INSERT INTO EMPMEM
SELECT empid, ename, salary
FROM BIGEMP
WHERE empid <= 20000;
```

**(c) exact match**

```sql
EXPLAIN SELECT * FROM EMPMEM WHERE ename = 'emp5000';
```

**(d) range**

```sql
EXPLAIN SELECT * FROM EMPMEM WHERE salary BETWEEN 20000 AND 20100;
```

</details>

## Question 8

Drop the index `idx_ename` and `EXPLAIN` the search for `emp50000` again. What changed?

> **Hint:** Indexes speed up reads but cost space, and every insert or update must keep them up to date. Add them for the searches you actually make.

**Expected output**

**(a) drop**

_No result rows. Action Output: 0 row(s) affected._

**(b)**

| type | key | rows |
|---|---|---|
| ALL | NULL | 100,000 |

<details>
<summary>Show the code</summary>

**(a) drop**

```sql
DROP INDEX idx_ename ON BIGEMP;
```

**(b)**

```sql
EXPLAIN SELECT * FROM BIGEMP WHERE ename = 'emp50000';
```

</details>
