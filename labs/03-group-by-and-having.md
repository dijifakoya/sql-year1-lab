# Lab 3: GROUP BY and HAVING

**Database:** `projemp` (PART 2 of `sql/year1_sql_lab.sql`)

**What you will learn**

- calculate one result per group with GROUP BY
- filter groups with HAVING (and rows with WHERE)
- understand why a non-grouped column is an error

## Before you start

1. Open `sql/year1_sql_lab.sql` in MySQL Workbench and run **PART 2** (select it, then **Ctrl + Shift + Enter**).
2. Open a new query tab and start it with `USE projemp;`
3. Try each question yourself **first**, then compare with the expected output. Open **Show the code** only if you are stuck.

## Question 1

Show the **average salary in each department**.

> **Hint:** `GROUP BY` makes one row per value of `dno`, and the aggregate is worked out for each group.

**Expected output**

| dno | AVG(salary) |
|---|---|
| d1 | 34888.888889 |
| d2 | 24800.000000 |
| d3 | 26000.000000 |

<details>
<summary>Show the code</summary>

```sql
SELECT dno, AVG(salary)
FROM EMP
GROUP BY dno
ORDER BY dno;
```

</details>

## Question 2

How many employees work on **each project**?

**Expected output**

| pno | COUNT(eno) |
|---|---|
| p13 | 8 |
| p15 | 5 |
| p19 | 10 |
| p23 | 9 |
| p26 | 7 |

<details>
<summary>Show the code</summary>

```sql
SELECT pno, COUNT(eno)
FROM WORKS
GROUP BY pno
ORDER BY pno;
```

</details>

## Question 3

Which departments have an **average salary below 30,000**?

> **Hint:** `HAVING` chooses between **groups**. It compares an aggregate with a value.

**Expected output**

| dno |
|---|
| d2 |
| d3 |

<details>
<summary>Show the code</summary>

```sql
SELECT dno
FROM EMP
GROUP BY dno
HAVING AVG(salary) < 30000
ORDER BY dno;
```

</details>

## Question 4

Which projects have **fewer than 9** employees?

**Expected output**

| pno |
|---|
| p13 |
| p15 |
| p26 |

<details>
<summary>Show the code</summary>

```sql
SELECT pno
FROM WORKS
GROUP BY pno
HAVING COUNT(eno) < 9
ORDER BY pno;
```

</details>

## Question 5

Show each employee's **total duration** across all projects, but only for employees whose total is **over 20**.

**Expected output**

| eno | total_duration |
|---|---|
| e21 | 25 |

<details>
<summary>Show the code</summary>

```sql
SELECT eno, SUM(duration) AS total_duration
FROM WORKS
GROUP BY eno
HAVING SUM(duration) > 20
ORDER BY eno;
```

</details>

## Question 6

For every department **except `d1`**, show the highest salary, but only where it is **above 30,000**.

> **Hint:** `WHERE` removes **rows** before grouping. `HAVING` removes **groups** after it.

**Expected output**

| dno | highest |
|---|---|
| d2 | 33000.00 |
| d3 | 48000.00 |

<details>
<summary>Show the code</summary>

```sql
SELECT dno, MAX(salary) AS highest
FROM EMP
WHERE dno <> 'd1'
GROUP BY dno
HAVING MAX(salary) > 30000
ORDER BY dno;
```

</details>

## Question 7

Count the **different** departments that have employees.

**Expected output**

| num_departments |
|---|
| 3 |

<details>
<summary>Show the code</summary>

```sql
SELECT COUNT(DISTINCT dno) AS num_departments
FROM EMP;
```

</details>

## Question 8

Run this query and read the error. Why does MySQL refuse it?

> **Hint:** Every column in `SELECT` must be either in the `GROUP BY` or inside an aggregate function. Which employee name should a whole department show?

**Expected output**

> `Error Code: 1055. Expression #2 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'projemp.EMP.ename' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by`

<details>
<summary>Show the code</summary>

```sql
SELECT dno, ename, AVG(salary)
FROM EMP
GROUP BY dno;
```

</details>
