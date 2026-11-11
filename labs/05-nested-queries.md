# Lab 5: Nested Queries (Subqueries)

**Database:** `projemp` (PART 2 of `sql/year1_sql_lab.sql`)

**What you will learn**

- put one query inside another
- know when to use `=` and when to use `IN`
- use `NOT IN`, `EXISTS` and `NOT EXISTS`
- compare a value with an aggregate

## Before you start

1. Open `sql/year1_sql_lab.sql` in MySQL Workbench and run **PART 2** (select it, then **Ctrl + Shift + Enter**).
2. Open a new query tab and start it with `USE projemp;`
3. Try each question yourself **first**, then compare with the expected output. Open **Show the code** only if you are stuck.

## Question 1

List the names of employees in the **information** department, using a nested query instead of a join.

> **Hint:** The inner query runs first and passes its result to the outer query. `IN` accepts one **or more** values.

**Expected output**

**9 rows:** `armstrong`, `neeson`, `pearse`, `quinn`, `trainor`, `vance`, `deehan`, `evans`, `hamill`

<details>
<summary>Show the code</summary>

```sql
SELECT ename
FROM EMP
WHERE dno IN
  (SELECT dno
   FROM DEPT
   WHERE dname = 'information');
```

</details>

## Question 2

List the names of the projects worked on by **pearse**, using nested queries only.

**Expected output**

| pname |
|---|
| payroll |
| graphics |
| registration |

<details>
<summary>Show the code</summary>

```sql
SELECT pname
FROM PROJ
WHERE pno IN
  (SELECT pno
   FROM WORKS
   WHERE eno IN
     (SELECT eno
      FROM EMP
      WHERE ename = 'pearse'));
```

</details>

## Question 3

List the names of employees who earn **less than the average** salary.

> **Hint:** The inner query returns a single value, so `<` works.

**Expected output**

**12 rows:** `kelly`, `oliver`, `pearse`, `roberts`, `breen`, `urquhart`, `vance`, `carroll`, `flynn`, `greer`, `hamill`, `irwin`

<details>
<summary>Show the code</summary>

```sql
SELECT ename
FROM EMP
WHERE salary <
  (SELECT AVG(salary)
   FROM EMP);
```

</details>

## Question 4

Why can't you write `WHERE salary < AVG(salary)`? Run it and read the error.

> **Hint:** Aggregate functions cannot be used directly in `WHERE`. That is why the nested query is needed.

**Expected output**

> `Error Code: 1111. Invalid use of group function`

<details>
<summary>Show the code</summary>

```sql
SELECT ename
FROM EMP
WHERE salary < AVG(salary);
```

</details>

## Question 5

List the name and salary of the **information** employees who earn more than the **information** average.

**Expected output**

| ename | salary |
|---|---|
| armstrong | 50000.00 |
| neeson | 48000.00 |
| trainor | 35000.00 |
| deehan | 50000.00 |
| evans | 38000.00 |

<details>
<summary>Show the code</summary>

```sql
SELECT ename, salary
FROM EMP
WHERE dno = 'd1'
AND salary >
  (SELECT AVG(salary)
   FROM EMP
   WHERE dno = 'd1');
```

</details>

## Question 6

List the name and salary of the **information** employees who earn more than the **maximum** salary in the **service** department.

**Expected output**

| ename | salary |
|---|---|
| armstrong | 50000.00 |
| neeson | 48000.00 |
| trainor | 35000.00 |
| deehan | 50000.00 |
| evans | 38000.00 |

<details>
<summary>Show the code</summary>

```sql
SELECT ename, salary
FROM EMP
WHERE dno = 'd1'
AND salary >
  (SELECT MAX(salary)
   FROM EMP
   WHERE dno = 'd2');
```

</details>

## Question 7

List the names of employees who do **not** work on project `p13`.

> **Hint:** `NOT IN` gives the opposite of `IN`.

**Expected output**

**13 rows:** `armstrong`, `jones`, `kelly`, `mccoy`, `neeson`, `oliver`, `quinn`, `trainor`, `breen`, `urquhart`, `carroll`, `deehan`, `flynn`

<details>
<summary>Show the code</summary>

```sql
SELECT ename
FROM EMP
WHERE eno NOT IN
  (SELECT eno
   FROM WORKS
   WHERE pno = 'p13');
```

</details>

## Question 8

List the departments that have **at least one** employee, and then those that have **none**. Use `EXISTS` and `NOT EXISTS`.

> **Hint:** `EXISTS` is true if the inner query returns at least one row. The inner query refers to the outer table (`DEPT`), so it runs once for each department.

**Expected output**

**(a) EXISTS**

| dname |
|---|
| information |
| service |
| engineering |

**(b) NOT EXISTS**

| dname |
|---|
| personnel |

<details>
<summary>Show the code</summary>

**(a) EXISTS**

```sql
SELECT dname
FROM DEPT
WHERE EXISTS
  (SELECT *
   FROM EMP
   WHERE EMP.dno = DEPT.dno);
```

**(b) NOT EXISTS**

```sql
SELECT dname
FROM DEPT
WHERE NOT EXISTS
  (SELECT *
   FROM EMP
   WHERE EMP.dno = DEPT.dno);
```

</details>
