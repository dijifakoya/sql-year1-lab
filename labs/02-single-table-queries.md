# Lab 2: Single-Table Queries

**Database:** `projemp` (PART 2 of `sql/year1_sql_lab.sql`)

**What you will learn**

- select rows with WHERE, AND, OR, IN and BETWEEN
- sort with ORDER BY
- summarise with COUNT, SUM, AVG, MIN and MAX
- remove duplicates with DISTINCT
- insert, update and delete rows safely

## Before you start

1. Open `sql/year1_sql_lab.sql` in MySQL Workbench and run **PART 2** (select it, then **Ctrl + Shift + Enter**).
2. Open a new query tab and start it with `USE projemp;`
3. Try each question yourself **first**, then compare with the expected output. Open **Show the code** only if you are stuck.

## Question 1

List the names of employees who earn **more than 25,000**.

**Expected output**

**11 rows:** `armstrong`, `jones`, `kelly`, `mccoy`, `neeson`, `oliver`, `quinn`, `smyth`, `trainor`, `deehan`, `evans`

<details>
<summary>Show the code</summary>

```sql
SELECT ename
FROM EMP
WHERE salary > 25000;
```

</details>

## Question 2

List the names of employees who earn more than 25,000 **and** work in department `d1`.

> **Hint:** Text values go in quotes. `AND` needs both conditions to be true.

**Expected output**

| ename |
|---|
| armstrong |
| neeson |
| quinn |
| trainor |
| deehan |
| evans |

<details>
<summary>Show the code</summary>

```sql
SELECT ename
FROM EMP
WHERE salary > 25000
AND dno = 'd1';
```

</details>

## Question 3

What is the **average age** of the employees in department `d2`?

**Expected output**

| AVG(age) |
|---|
| 33.4000 |

<details>
<summary>Show the code</summary>

```sql
SELECT AVG(age)
FROM EMP
WHERE dno = 'd2';
```

</details>

## Question 4

List the name, salary and age of the employees in `d1`, **oldest first**.

> **Hint:** `ORDER BY` sorts ascending by default. Add `DESC` for descending.

**Expected output**

| ename | salary | age |
|---|---|---|
| armstrong | 50000.00 | 56 |
| quinn | 33000.00 | 54 |
| deehan | 50000.00 | 48 |
| evans | 38000.00 | 45 |
| trainor | 35000.00 | 39 |
| … | … | … |

_9 rows in total_

<details>
<summary>Show the code</summary>

```sql
SELECT ename, salary, age
FROM EMP
WHERE dno = 'd1'
ORDER BY age DESC;
```

</details>

## Question 5

List the names of employees who earn **less than 20,000 or more than 30,000**.

**Expected output**

**14 rows:** `armstrong`, `jones`, `mccoy`, `neeson`, `quinn`, `smyth`, `trainor`, `breen`, `urquhart`, `vance`, `carroll`, `deehan`, `evans`, `greer`

<details>
<summary>Show the code</summary>

```sql
SELECT ename
FROM EMP
WHERE salary < 20000
OR salary > 30000;
```

</details>

## Question 6

List the names of employees who earn between 20,000 and 30,000 (inclusive).

> **Hint:** `BETWEEN` includes both end values.

**Expected output**

| ename | salary |
|---|---|
| kelly | 28000.00 |
| oliver | 26000.00 |
| pearse | 20000.00 |
| roberts | 21000.00 |
| flynn | 24000.00 |
| hamill | 25000.00 |
| irwin | 23000.00 |

<details>
<summary>Show the code</summary>

```sql
SELECT ename, salary
FROM EMP
WHERE salary BETWEEN 20000 AND 30000;
```

</details>

## Question 7

List the names of employees who earn exactly 18,000 or 20,000.

> **Hint:** `IN (a, b)` is shorthand for `= a OR = b`.

**Expected output**

| ename |
|---|
| pearse |
| carroll |

<details>
<summary>Show the code</summary>

```sql
SELECT ename
FROM EMP
WHERE salary IN (18000, 20000);
```

</details>

## Question 8

For department `d3`, show how many employees there are and their total, lowest and highest salary. Give each result a clear heading.

> **Hint:** `AS` gives a result column a name.

**Expected output**

| num_employees | total_salary | lowest | highest |
|---|---|---|---|
| 7 | 182000.00 | 17000.00 | 48000.00 |

<details>
<summary>Show the code</summary>

```sql
SELECT COUNT(*) AS num_employees,
       SUM(salary) AS total_salary,
       MIN(salary) AS lowest,
       MAX(salary) AS highest
FROM EMP
WHERE dno = 'd3';
```

</details>

## Question 9

Show the monthly salary (salary divided by 12, to 2 decimal places) of the employees in `d2`, highest first.

**Expected output**

| ename | monthly_salary |
|---|---|
| mccoy | 2750.00 |
| kelly | 2333.33 |
| flynn | 2000.00 |
| irwin | 1916.67 |
| greer | 1333.33 |

<details>
<summary>Show the code</summary>

```sql
SELECT ename, ROUND(salary / 12, 2) AS monthly_salary
FROM EMP
WHERE dno = 'd2'
ORDER BY monthly_salary DESC;
```

</details>

## Question 10

Compare the two queries. What does `DISTINCT` do?

**Expected output**

**(a)**

**21 rows:** `d1`, `d1`, `d1`, `d1`, `d1`, `d1`, `d1`, `d1`, `d1`, `d2`, `d2`, `d2`, `d2`, `d2`, `d3`, `d3`, `d3`, `d3`, `d3`, `d3`, `d3`

**(b)**

| dno |
|---|
| d1 |
| d2 |
| d3 |

<details>
<summary>Show the code</summary>

**(a)**

```sql
SELECT dno FROM EMP;
```

**(b)**

```sql
SELECT DISTINCT dno FROM EMP;
```

</details>

## Question 11

Insert a new employee (`e51`, mallon, 26000, age 32, supervisor `e17`, department `d2`) and check the row.

**Expected output**

**(a)**

_No result rows. Action Output: 1 row(s) affected._

**(b)**

| eno | ename | salary | age | supno | dno |
|---|---|---|---|---|---|
| e51 | mallon | 26000.00 | 32 | e17 | d2 |

<details>
<summary>Show the code</summary>

**(a)**

```sql
INSERT INTO EMP
VALUES ('e51', 'mallon', 26000.00, 32, 'e17', 'd2');
```

**(b)**

```sql
SELECT * FROM EMP WHERE eno = 'e51';
```

</details>

## Question 12

Delete employee `e51`.

**Expected output**

**(a)**

_No result rows. Action Output: 1 row(s) affected._

**(b)**

| num_employees |
|---|
| 21 |

<details>
<summary>Show the code</summary>

**(a)**

```sql
DELETE FROM EMP
WHERE eno = 'e51';
```

**(b)**

```sql
SELECT COUNT(*) AS num_employees FROM EMP;
```

</details>

## Question 13

Try to delete employee `e19`. Read the error and explain why the delete is blocked.

> **Hint:** Look at what other table refers to employee e19.

**Expected output**

> `Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`projemp`.`WORKS`, CONSTRAINT `works_ibfk_1` FOREIGN KEY (`eno`) REFERENCES `EMP` (`eno`))`

<details>
<summary>Show the code</summary>

```sql
DELETE FROM EMP WHERE eno = 'e19';
```

</details>

## Question 14

Change the budget of project `p13` to 650,000 and check it.

**Expected output**

**(a)**

_No result rows. Action Output: 1 row(s) affected._

**(b)**

| pno | pname | budget |
|---|---|---|
| p13 | payroll | 650000.00 |

<details>
<summary>Show the code</summary>

**(a)**

```sql
UPDATE PROJ
SET budget = 650000
WHERE pno = 'p13';
```

**(b)**

```sql
SELECT pno, pname, budget FROM PROJ WHERE pno = 'p13';
```

</details>
