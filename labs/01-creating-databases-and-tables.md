# Lab 1: Creating a Database and Tables

**Database:** `lab01` (you create it in this lab)

**What you will learn**

- create a database and tables
- choose data types, primary keys and foreign keys
- insert, update and delete rows
- read the errors MySQL gives when a rule is broken

## Before you start

This lab needs **no** part of the script. You build a small database yourself.
Open a new query tab in MySQL Workbench.

## Question 1

Create a database called `lab01`, make it the default database and check that it is selected.

> **Hint:** `USE` makes a database the default for the statements that follow.

**Expected output**

| DATABASE() |
|---|
| lab01 |

<details>
<summary>Show the code</summary>

```sql
CREATE DATABASE lab01;
USE lab01;
SELECT DATABASE();
```

</details>

## Question 2

Create a table `COURSE` with `cid` (3 characters, the primary key) and `cname` (up to 30 characters, must not be empty). Then show its structure.

> **Hint:** `DESCRIBE` lists each column, its type and its key.

**Expected output**

| Field | Type | Null | Key | Default | Extra |
|---|---|---|---|---|---|
| cid | char(3) | NO | PRI | NULL |  |
| cname | varchar(30) | NO |  | NULL |  |

<details>
<summary>Show the code</summary>

```sql
CREATE TABLE COURSE (
  cid    CHAR(3) NOT NULL,
  cname  VARCHAR(30) NOT NULL,
  PRIMARY KEY (cid)
);
DESCRIBE COURSE;
```

</details>

## Question 3

Create a table `STUDENT` with `sid` (a whole number, the primary key), `sname` (up to 30 characters, not empty) and `cid`, which must match a course in `COURSE`. Show its structure.

> **Hint:** A **foreign key** makes sure a value in one table exists in another. Create the table that is referred to first.

**Expected output**

| Field | Type | Null | Key | Default | Extra |
|---|---|---|---|---|---|
| sid | int | NO | PRI | NULL |  |
| sname | varchar(30) | NO |  | NULL |  |
| cid | char(3) | YES | MUL | NULL |  |

<details>
<summary>Show the code</summary>

```sql
CREATE TABLE STUDENT (
  sid    INT NOT NULL,
  sname  VARCHAR(30) NOT NULL,
  cid    CHAR(3),
  PRIMARY KEY (sid),
  CONSTRAINT fk_student_course FOREIGN KEY (cid) REFERENCES COURSE (cid)
);
DESCRIBE STUDENT;
```

</details>

## Question 4

Insert three courses (C01 Databases, C02 Programming, C03 Networks) and four students (Aoife on C01, Ben on C02, Chloe on C01, and Dev with no course yet). Then list all the students.

> **Hint:** A student with no course has `NULL` in `cid`. This is allowed because `cid` is not marked NOT NULL.

**Expected output**

**(a)**

_No result rows. Action Output: 3 row(s) affected._

**(b)**

_No result rows. Action Output: 4 row(s) affected._

**(c)**

| sid | sname | cid |
|---|---|---|
| 1 | Aoife | C01 |
| 2 | Ben | C02 |
| 3 | Chloe | C01 |
| 4 | Dev | NULL |

<details>
<summary>Show the code</summary>

**(a)**

```sql
INSERT INTO COURSE VALUES ('C01', 'Databases'), ('C02', 'Programming'), ('C03', 'Networks');
```

**(b)**

```sql
INSERT INTO STUDENT VALUES (1, 'Aoife', 'C01'), (2, 'Ben', 'C02'), (3, 'Chloe', 'C01'), (4, 'Dev', NULL);
```

**(c)**

```sql
SELECT * FROM STUDENT;
```

</details>

## Question 5

Try to insert another student with `sid` 1. Read the error and explain it.

> **Hint:** Think about what a primary key guarantees.

**Expected output**

> `Error Code: 1062. Duplicate entry '1' for key 'STUDENT.PRIMARY'`

<details>
<summary>Show the code</summary>

```sql
INSERT INTO STUDENT VALUES (1, 'Eve', 'C03');
```

</details>

## Question 6

Try to insert a student on a course that does not exist (`C09`). Read the error and explain it.

> **Hint:** The foreign key only accepts values that exist in `COURSE`.

**Expected output**

> `Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`lab01`.`STUDENT`, CONSTRAINT `fk_student_course` FOREIGN KEY (`cid`) REFERENCES `COURSE` (`cid`))`

<details>
<summary>Show the code</summary>

```sql
INSERT INTO STUDENT VALUES (5, 'Fin', 'C09');
```

</details>

## Question 7

Move Dev onto course C03, then check the change.

> **Hint:** Always put a `WHERE` on an `UPDATE`, or every row changes.

**Expected output**

**(a)**

_No result rows. Action Output: 1 row(s) affected._

**(b)**

| sid | sname | cid |
|---|---|---|
| 4 | Dev | C03 |

<details>
<summary>Show the code</summary>

**(a)**

```sql
UPDATE STUDENT SET cid = 'C03' WHERE sid = 4;
```

**(b)**

```sql
SELECT * FROM STUDENT WHERE sid = 4;
```

</details>

## Question 8

Delete Ben, then count the students that are left.

**Expected output**

**(a)**

_No result rows. Action Output: 1 row(s) affected._

**(b)**

| num_students |
|---|
| 3 |

<details>
<summary>Show the code</summary>

**(a)**

```sql
DELETE FROM STUDENT WHERE sid = 2;
```

**(b)**

```sql
SELECT COUNT(*) AS num_students FROM STUDENT;
```

</details>

## Question 9

Add an `email` column to `STUDENT` (up to 50 characters) and show the new structure.

> **Hint:** `ALTER TABLE` changes the structure of a table that already exists.

**Expected output**

| Field | Type | Null | Key | Default | Extra |
|---|---|---|---|---|---|
| sid | int | NO | PRI | NULL |  |
| sname | varchar(30) | NO |  | NULL |  |
| cid | char(3) | YES | MUL | NULL |  |
| email | varchar(50) | YES |  | NULL |  |

<details>
<summary>Show the code</summary>

```sql
ALTER TABLE STUDENT ADD COLUMN email VARCHAR(50);
DESCRIBE STUDENT;
```

</details>

## Question 10

Try to drop `COURSE` first. Read the error, then drop the tables in the right order.

> **Hint:** A table that is referred to by a foreign key cannot be dropped until the table that refers to it has gone.

**Expected output**

**(a)**

> `Error Code: 3730. Cannot drop table 'COURSE' referenced by a foreign key constraint 'fk_student_course' on table 'STUDENT'.`

**(b)**

_No result rows. Action Output: 0 row(s) affected._

<details>
<summary>Show the code</summary>

**(a)**

```sql
DROP TABLE COURSE;
```

**(b)**

```sql
DROP TABLE STUDENT;
DROP TABLE COURSE;
```

</details>

## Clean up

You have finished Lab 1. Remove the practice database so you can start the lab again from Question 1 at any time.

**Expected output**

_No result rows. Action Output: 0 row(s) affected._

<details>
<summary>Show the code</summary>

```sql
DROP DATABASE lab01;
```

</details>
