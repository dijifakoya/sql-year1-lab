# Lab 4: Joins (Two or More Tables)

**Database:** `class_db and projemp` (PART 1 and PART 2 of `sql/year1_sql_lab.sql`)

**What you will learn**

- join tables on a primary key / foreign key match
- write joins in the explicit (`INNER JOIN`) and implicit (`FROM A, B WHERE`) styles
- join three tables and join a table to itself
- avoid the "ambiguous column" error

## Before you start

This lab uses **both** databases. Run **PART 1** and **PART 2** of `sql/year1_sql_lab.sql` (select a part, then **Ctrl + Shift + Enter**).
Each question starts with the `USE` it needs. Try each question yourself **first**.

## Question 1

(class_db) List the name and role of employees who work on the **first floor**. Use the explicit `INNER JOIN` style.

> **Hint:** The tables are linked by `enum`. Put the join condition in `ON` and the other condition in `WHERE`.

**Expected output**

| ename | role |
|---|---|
| Smith | Manager |
| Smith | Designer |
| Adams | Designer |
| Adams | Manager |

<details>
<summary>Show the code</summary>

```sql
USE class_db;
SELECT ename, role
FROM EMPLOYEE INNER JOIN WORKS_ON
ON EMPLOYEE.enum = WORKS_ON.enum
WHERE floor = 1;
```

</details>

## Question 2

Write the same query in the **implicit** style.

> **Hint:** The explicit style keeps join conditions apart from other conditions, so it is the better habit.

**Expected output**

| ename | role |
|---|---|
| Smith | Manager |
| Smith | Designer |
| Adams | Designer |
| Adams | Manager |

<details>
<summary>Show the code</summary>

```sql
SELECT ename, role
FROM EMPLOYEE, WORKS_ON
WHERE EMPLOYEE.enum = WORKS_ON.enum
AND floor = 1;
```

</details>

## Question 3

(class_db) List each **manager** with the name of the project they manage. This needs **three** tables.

> **Hint:** EMPLOYEE and PROJECT are linked through WORKS_ON, so WORKS_ON goes in the middle.

**Expected output**

| ename | pname | role |
|---|---|---|
| Adams | Publicity | Manager |
| Doyle | Sport | Manager |
| Evans | Analysis | Manager |
| Smith | IT | Manager |
| White | Theatre | Manager |

<details>
<summary>Show the code</summary>

```sql
SELECT ename, pname, role
FROM EMPLOYEE INNER JOIN WORKS_ON ON EMPLOYEE.enum = WORKS_ON.enum
     INNER JOIN PROJECT ON WORKS_ON.pnum = PROJECT.pnum
WHERE role = 'Manager'
ORDER BY ename;
```

</details>

## Question 4

Run this query. Why does it fail, and how do you fix it?

> **Hint:** `enum` is in both tables. Write `Table.attribute` for any attribute that is in more than one table.

**Expected output**

**(a) the error**

> `Error Code: 1052. Column 'enum' in field list is ambiguous`

**(b) the fix**

| enum | ename |
|---|---|
| 852341 | Smith |
| 852341 | Smith |
| 852358 | Jones |
| 852358 | Jones |
| 852407 | Brown |
| … | … |

_13 rows in total_

<details>
<summary>Show the code</summary>

**(a) the error**

```sql
SELECT enum, ename
FROM EMPLOYEE INNER JOIN WORKS_ON
ON EMPLOYEE.enum = WORKS_ON.enum;
```

**(b) the fix**

```sql
SELECT EMPLOYEE.enum, ename
FROM EMPLOYEE INNER JOIN WORKS_ON
ON EMPLOYEE.enum = WORKS_ON.enum;
```

</details>

## Question 5

(projemp) List the names of the employees in the **information** department.

**Expected output**

**9 rows:** `armstrong`, `neeson`, `pearse`, `quinn`, `trainor`, `vance`, `deehan`, `evans`, `hamill`

<details>
<summary>Show the code</summary>

```sql
USE projemp;
SELECT ename
FROM DEPT INNER JOIN EMP
ON DEPT.dno = EMP.dno
WHERE dname = 'information';
```

</details>

## Question 6

List the names of the projects worked on by **pearse**.

> **Hint:** EMP and PROJ are linked through WORKS.

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
FROM EMP INNER JOIN WORKS ON EMP.eno = WORKS.eno
     INNER JOIN PROJ ON WORKS.pno = PROJ.pno
WHERE ename = 'pearse';
```

</details>

## Question 7

For each project, show its name and how many employees work on it.

> **Hint:** Count the rows. Notice that one of the six projects is missing. Lab 7 explains why.

**Expected output**

| pname | num_employees |
|---|---|
| database | 5 |
| examination | 7 |
| graphics | 10 |
| payroll | 8 |
| registration | 9 |

<details>
<summary>Show the code</summary>

```sql
SELECT pname, COUNT(*) AS num_employees
FROM PROJ INNER JOIN WORKS ON PROJ.pno = WORKS.pno
GROUP BY pname
ORDER BY pname;
```

</details>

## Question 8

Show each employee with the name of their **supervisor**. Join `EMP` to **itself**, using two different names for the two copies.

> **Hint:** `AS E` and `AS S` give each copy of the table its own name. `supno` of the employee matches `eno` of the supervisor. Notice that armstrong, who has no supervisor, is missing.

**Expected output**

| employee | supervisor |
|---|---|
| jones | armstrong |
| kelly | greer |
| mccoy | carroll |
| neeson | trainor |
| oliver | roberts |
| … | … |

_20 rows in total_

<details>
<summary>Show the code</summary>

```sql
SELECT E.ename AS employee, S.ename AS supervisor
FROM EMP AS E INNER JOIN EMP AS S
ON E.supno = S.eno
ORDER BY E.eno;
```

</details>
