# Lab 6: LIKE, NULL and Set Operators

**Database:** `class_db` (PART 1 of `sql/year1_sql_lab.sql`)

**What you will learn**

- match patterns with `LIKE` and `REGEXP`
- test for `NULL` correctly
- combine two queries with `UNION`, `INTERSECT` and `EXCEPT`

## Before you start

1. Open `sql/year1_sql_lab.sql` in MySQL Workbench and run **PART 1** (select it, then **Ctrl + Shift + Enter**).
2. Open a new query tab and start it with `USE class_db;`
3. Try each question yourself **first**, then compare with the expected output. Open **Show the code** only if you are stuck.

## Question 1

List the names of employees that begin with **S**.

> **Hint:** `%` stands for any number of characters. MySQL ignores upper/lower case in `LIKE`.

**Expected output**

| ename |
|---|
| Smith |

<details>
<summary>Show the code</summary>

```sql
SELECT ename
FROM EMPLOYEE
WHERE ename LIKE 'S%';
```

</details>

## Question 2

List the names that contain the letter **o** anywhere.

**Expected output**

| ename |
|---|
| Jones |
| Brown |
| Doyle |

<details>
<summary>Show the code</summary>

```sql
SELECT ename
FROM EMPLOYEE
WHERE ename LIKE '%o%';
```

</details>

## Question 3

List the names whose **second** letter is **o**.

> **Hint:** `_` stands for exactly one character.

**Expected output**

| ename |
|---|
| Jones |
| Doyle |

<details>
<summary>Show the code</summary>

```sql
SELECT ename
FROM EMPLOYEE
WHERE ename LIKE '_o%';
```

</details>

## Question 4

List the names that begin with a letter from **A to D**. First try `LIKE '[A-D]%'`, then use `REGEXP`.

> **Hint:** Square-bracket ranges work in SQL Server but not in MySQL `LIKE`. In `REGEXP`, `^` means "at the start".

**Expected output**

**(a) LIKE does not understand [ ]**

_0 rows returned (empty result)._

**(b) REGEXP**

| ename |
|---|
| Brown |
| Adams |
| Doyle |

<details>
<summary>Show the code</summary>

**(a) LIKE does not understand [ ]**

```sql
SELECT ename
FROM EMPLOYEE
WHERE ename LIKE '[A-D]%';
```

**(b) REGEXP**

```sql
SELECT ename
FROM EMPLOYEE
WHERE ename REGEXP '^[A-D]';
```

</details>

## Question 5

List the members who do **not** belong to any club.

> **Hint:** `NULL` means "unknown / no value". Test it with `IS NULL`.

**Expected output**

| member_name |
|---|
| Jones |
| Brown |

<details>
<summary>Show the code</summary>

```sql
SELECT member_name
FROM MEMBER
WHERE club_id IS NULL;
```

</details>

## Question 6

Run `WHERE club_id = NULL`. What happens, and why?

> **Hint:** Comparing anything with an unknown value is never true. `= NULL` never matches, and there is no error to warn you.

**Expected output**

_0 rows returned (empty result)._

<details>
<summary>Show the code</summary>

```sql
SELECT member_name
FROM MEMBER
WHERE club_id = NULL;
```

</details>

## Question 7

List the names of **all** suppliers and customers (each name once).

> **Hint:** Both queries need the same number of columns, with compatible types. `UNION` removes duplicates.

**Expected output**

**10 rows:** `Big IT`, `Top Design`, `ALY Ltd`, `Microsoft`, `Apple`, `PC Sport`, `IT r us`, `Myco`, `MFN Ltd`, `HP`

<details>
<summary>Show the code</summary>

```sql
SELECT s_name
FROM SUPPLIER
UNION
SELECT c_name
FROM CUSTOMER;
```

</details>

## Question 8

Repeat the last question but **keep duplicates**. Which two names appear twice?

**Expected output**

**12 rows:** `Big IT`, `Top Design`, `ALY Ltd`, `Microsoft`, `Apple`, `PC Sport`, `IT r us`, `Apple`, `Microsoft`, `Myco`, `MFN Ltd`, `HP`

<details>
<summary>Show the code</summary>

```sql
SELECT s_name
FROM SUPPLIER
UNION ALL
SELECT c_name
FROM CUSTOMER;
```

</details>

## Question 9

List the suppliers that are **also** customers.

> **Hint:** `INTERSECT`: rows that are in **both** results.

**Expected output**

| s_name |
|---|
| Microsoft |
| Apple |

<details>
<summary>Show the code</summary>

```sql
SELECT s_name
FROM SUPPLIER
INTERSECT
SELECT c_name
FROM CUSTOMER;
```

</details>

## Question 10

List the suppliers that are **not** customers, then swap the queries.

> **Hint:** `EXCEPT` keeps rows from the **first** query that are not in the second, so the order matters.

**Expected output**

**(a)**

| s_name |
|---|
| Big IT |
| Top Design |
| ALY Ltd |
| PC Sport |

**(b)**

| c_name |
|---|
| IT r us |
| Myco |
| MFN Ltd |
| HP |

<details>
<summary>Show the code</summary>

**(a)**

```sql
SELECT s_name
FROM SUPPLIER
EXCEPT
SELECT c_name
FROM CUSTOMER;
```

**(b)**

```sql
SELECT c_name
FROM CUSTOMER
EXCEPT
SELECT s_name
FROM SUPPLIER;
```

</details>

## Question 11

Run this and read the error.

> **Hint:** Count the columns in each query.

**Expected output**

> `Error Code: 1222. The used SELECT statements have a different number of columns`

<details>
<summary>Show the code</summary>

```sql
SELECT s_name, country
FROM SUPPLIER
UNION
SELECT c_name
FROM CUSTOMER;
```

</details>
