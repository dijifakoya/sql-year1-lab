# Lab 9: Triggers

**Database:** `proc3` (PART 3 of `sql/year1_sql_lab.sql`)

**What you will learn**

- create `AFTER` and `BEFORE` triggers
- use `OLD` and `NEW` to see the values being changed
- keep summary, archive and audit tables up to date automatically
- stop invalid changes with `SIGNAL`

## Before you start

1. Open `sql/year1_sql_lab.sql` in MySQL Workbench and run **PART 3** (select it, then **Ctrl + Shift + Enter**).
2. Open a new query tab and start it with `USE proc3;`
3. Try each question yourself **first**, then compare with the expected output. Open **Show the code** only if you are stuck.
4. Also run `SET SQL_SAFE_UPDATES = 0;` at the top of the tab (Workbench blocks `UPDATE` statements in triggers otherwise: Error 1175).
5. If you worked through Lab 8 first, re-run PART 3 so that you start from clean tables.

## Question 1

Add three departments, each with 0 employees: 11 admin, 12 sales and 13 finance.

> **Hint:** `numemp` is meant to hold the number of employees in the department. It is 0 even though departments 11 and 12 have employees. A trigger will fix that.

**Expected output**

**(a)**

_No result rows. Action Output: 3 row(s) affected._

**(b)**

| dnum | dname | numemp |
|---|---|---|
| 11 | admin | 0 |
| 12 | sales | 0 |
| 13 | finance | 0 |

<details>
<summary>Show the code</summary>

**(a)**

```sql
INSERT INTO DEPT VALUES (11, 'admin', 0), (12, 'sales', 0), (13, 'finance', 0);
```

**(b)**

```sql
SELECT * FROM DEPT;
```

</details>

## Question 2

Create a trigger `tr1` that fires **after an INSERT** on `EMP` and recounts the employees in every department into `DEPT.numemp`.

> **Hint:** A trigger belongs to a table and fires on an event. `FOR EACH ROW` means it runs once for each row that is changed.

**Expected output**

_No result rows. Action Output: 0 row(s) affected._

<details>
<summary>Show the code</summary>

```sql
DELIMITER $$
CREATE TRIGGER tr1 AFTER INSERT ON EMP
FOR EACH ROW
BEGIN
  UPDATE DEPT
  SET numemp = (SELECT COUNT(*) FROM EMP
                WHERE EMP.dnum = DEPT.dnum);
END$$
DELIMITER ;
```

</details>

## Question 3

Insert a new employee (8, Watts, 30000, 37, department 11) and look at `DEPT`. Then add (9, allen, 20000, 52, department 13) and look again.

> **Hint:** You never call a trigger. It runs by itself.

**Expected output**

**(a)**

_No result rows. Action Output: 1 row(s) affected._

**(b) after Watts**

| dnum | dname | numemp |
|---|---|---|
| 11 | admin | 3 |
| 12 | sales | 2 |
| 13 | finance | 0 |

**(c)**

_No result rows. Action Output: 1 row(s) affected._

**(d) after allen**

| dnum | dname | numemp |
|---|---|---|
| 11 | admin | 3 |
| 12 | sales | 2 |
| 13 | finance | 1 |

<details>
<summary>Show the code</summary>

**(a)**

```sql
INSERT INTO EMP VALUES (8, 'Watts', 30000, 37, 11);
```

**(b) after Watts**

```sql
SELECT * FROM DEPT;
```

**(c)**

```sql
INSERT INTO EMP VALUES (9, 'allen', 20000, 52, 13);
```

**(d) after allen**

```sql
SELECT * FROM DEPT;
```

</details>

## Question 4

Create a trigger `tr2` that fires **after a DELETE** on `ACCOUNT` and saves a copy of the deleted account in `ARCHACC`. Delete account 56789 and check both tables.

> **Hint:** Inside a trigger, `OLD.column` is the value in the row **before** the change.

**Expected output**

**(a) create**

_No result rows. Action Output: 0 row(s) affected._

**(b)**

_No result rows. Action Output: 1 row(s) affected._

**(c) ACCOUNT**

| accnum | balance |
|---|---|
| 12345 | 150 |
| 23456 | 1400 |
| 34567 | 850 |
| 45678 | 2300 |

**(d) ARCHACC**

| accnum | balance |
|---|---|
| 56789 | 1865 |

<details>
<summary>Show the code</summary>

**(a) create**

```sql
DELIMITER $$
CREATE TRIGGER tr2 AFTER DELETE ON ACCOUNT
FOR EACH ROW
BEGIN
  INSERT INTO ARCHACC (accnum, balance)
  VALUES (OLD.accnum, OLD.balance);
END$$
DELIMITER ;
```

**(b)**

```sql
DELETE FROM ACCOUNT WHERE accnum = 56789;
```

**(c) ACCOUNT**

```sql
SELECT * FROM ACCOUNT;
```

**(d) ARCHACC**

```sql
SELECT * FROM ARCHACC;
```

</details>

## Question 5

Create a trigger `tr3` that fires **after an UPDATE** on `ACCOUNT` and logs the old and new balance and the time in `AUDIT`. Change two balances and check `AUDIT`.

> **Hint:** `NEW.column` is the value **after** the change. `NOW()` is the current date and time. `id` is `AUTO_INCREMENT`, so you never insert it. The time you see will be yours.

**Expected output**

**(a) create**

_No result rows. Action Output: 0 row(s) affected._

**(b)**

_No result rows. Each UPDATE reports 1 row(s) affected._

**(c)**

| id | accnum | old_balance | new_balance | atime |
|---|---|---|---|---|
| 1 | 12345 | 150 | 300 | (date and time) |
| 2 | 23456 | 1400 | 1500 | (date and time) |

<details>
<summary>Show the code</summary>

**(a) create**

```sql
DELIMITER $$
CREATE TRIGGER tr3 AFTER UPDATE ON ACCOUNT
FOR EACH ROW
BEGIN
  INSERT INTO AUDIT (accnum, old_balance, new_balance, atime)
  VALUES (OLD.accnum, OLD.balance, NEW.balance, NOW());
END$$
DELIMITER ;
```

**(b)**

```sql
UPDATE ACCOUNT SET balance = 300 WHERE accnum = 12345;
UPDATE ACCOUNT SET balance = 1500 WHERE accnum = 23456;
```

**(c)**

```sql
SELECT * FROM AUDIT;
```

</details>

## Question 6

Create a **BEFORE UPDATE** trigger `tr4` that rejects a negative balance. Then try to set account 34567 to -50 and check that the balance is unchanged.

> **Hint:** MySQL has no `INSTEAD OF` triggers. To **prevent** a change, use a `BEFORE` trigger and `SIGNAL` an error. The change is then cancelled.

**Expected output**

**(a) create**

_No result rows. Action Output: 0 row(s) affected._

**(b)**

> `Error Code: 1644. Balance cannot be negative`

**(c)**

| accnum | balance |
|---|---|
| 34567 | 850 |

<details>
<summary>Show the code</summary>

**(a) create**

```sql
DELIMITER $$
CREATE TRIGGER tr4 BEFORE UPDATE ON ACCOUNT
FOR EACH ROW
BEGIN
  IF NEW.balance < 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Balance cannot be negative';
  END IF;
END$$
DELIMITER ;
```

**(b)**

```sql
UPDATE ACCOUNT SET balance = -50 WHERE accnum = 34567;
```

**(c)**

```sql
SELECT * FROM ACCOUNT WHERE accnum = 34567;
```

</details>

## Question 7

List the triggers in `proc3`.

> **Hint:** `SHOW TRIGGERS;` gives the same information with more columns.

**Expected output**

| TRIGGER_NAME | ACTION_TIMING | EVENT_MANIPULATION | EVENT_OBJECT_TABLE |
|---|---|---|---|
| tr1 | AFTER | INSERT | EMP |
| tr2 | AFTER | DELETE | ACCOUNT |
| tr3 | AFTER | UPDATE | ACCOUNT |
| tr4 | BEFORE | UPDATE | ACCOUNT |

<details>
<summary>Show the code</summary>

```sql
SELECT TRIGGER_NAME, ACTION_TIMING, EVENT_MANIPULATION, EVENT_OBJECT_TABLE
FROM INFORMATION_SCHEMA.TRIGGERS
WHERE TRIGGER_SCHEMA = 'proc3'
ORDER BY TRIGGER_NAME;
```

</details>

## Question 8

Drop `tr1`. Insert employee (5, Black, 21000, 30, department 12) and look at `DEPT`. What do you notice?

> **Hint:** Department 12 now has three employees. Is `numemp` right?

**Expected output**

**(a)**

_No result rows. Action Output: 0 row(s) affected._

**(b)**

_No result rows. Action Output: 1 row(s) affected._

**(c)**

| dnum | dname | numemp |
|---|---|---|
| 11 | admin | 3 |
| 12 | sales | 2 |
| 13 | finance | 1 |

<details>
<summary>Show the code</summary>

**(a)**

```sql
DROP TRIGGER tr1;
```

**(b)**

```sql
INSERT INTO EMP VALUES (5, 'Black', 21000, 30, 12);
```

**(c)**

```sql
SELECT * FROM DEPT;
```

</details>
