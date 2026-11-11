# Lab 10: Transactions and Concurrency

**Database:** `txn_demo` (PART 4 of `sql/year1_sql_lab.sql`)

**What you will learn**

- group statements into a transaction with `START TRANSACTION`, `COMMIT` and `ROLLBACK`
- see **atomicity** and **isolation** (the A and I of ACID)
- see the **lost update** problem and fix it with a lock
- see a **deadlock**

## Before you start

1. Open `sql/year1_sql_lab.sql` in MySQL Workbench and run **PART 4** (select it, then **Ctrl + Shift + Enter**).
2. Open a new query tab and start it with `USE txn_demo;`
3. Try each question yourself **first**, then compare with the expected output. Open **Show the code** only if you are stuck.
4. Some questions use **two sessions**. Open **two query tabs** in Workbench, each with its own connection. Run `USE txn_demo;` in both and call them **Session A** and **Session B**. Follow the steps in the order of the time column.

## Question 1

Check that MySQL is in **autocommit** mode.

> **Hint:** In autocommit mode every statement is committed straight away.

**Expected output**

| @@autocommit |
|---|
| 1 |

<details>
<summary>Show the code</summary>

```sql
SELECT @@autocommit;
```

</details>

## Question 2

Transfer 100 from account A10 to account A25 inside a transaction. Look at the balances before you finish, then **ROLLBACK** and look again.

> **Hint:** A transaction is **all or nothing**: `ROLLBACK` undoes both updates.

**Expected output**

**(a) inside the transaction**

| account_num | account_holder | balance |
|---|---|---|
| A10 | Smith | 900.00 |
| A25 | Jones | 1100.00 |
| A30 | Brown | 500.00 |

**(b) after ROLLBACK**

| account_num | account_holder | balance |
|---|---|---|
| A10 | Smith | 1000.00 |
| A25 | Jones | 1000.00 |
| A30 | Brown | 500.00 |

<details>
<summary>Show the code</summary>

**(a)**

```sql
START TRANSACTION;
UPDATE ACCOUNT SET balance = balance - 100 WHERE account_num = 'A10';
UPDATE ACCOUNT SET balance = balance + 100 WHERE account_num = 'A25';
SELECT * FROM ACCOUNT;
```

**(b)**

```sql
ROLLBACK;
SELECT * FROM ACCOUNT;
```

</details>

## Question 3

**Isolation.** Transfer 100 from A10 to A25 again, but in **Session A** and **without committing yet**. Look at the accounts from **Session B**. Then `COMMIT` in A and look again from B.

> **Hint:** Until A commits, B must not see A's half-finished work.

**Expected output**

**Session B at t4** (A has not committed):

| account_num | account_holder | balance |
|---|---|---|
| A10 | Smith | 1000.00 |
| A25 | Jones | 1000.00 |
| A30 | Brown | 500.00 |

**Session B at t6** (after A commits):

| account_num | account_holder | balance |
|---|---|---|
| A10 | Smith | 900.00 |
| A25 | Jones | 1100.00 |
| A30 | Brown | 500.00 |

<details>
<summary>Show the code</summary>

| Time | Session A | Session B |
|---|---|---|
| t1 | `START TRANSACTION;` |  |
| t2 | `UPDATE ACCOUNT SET balance = balance - 100 WHERE account_num = 'A10';` |  |
| t3 | `UPDATE ACCOUNT SET balance = balance + 100 WHERE account_num = 'A25';` |  |
| t4 |  | `SELECT * FROM ACCOUNT;` |
| t5 | `COMMIT;` |  |
| t6 |  | `SELECT * FROM ACCOUNT;` |

</details>

## Question 4

Write a procedure `Transfer` that moves money **as one transaction** and refuses if the paying account has too little. Transfer 100 from A10 to A25, then try to transfer 5000.

> **Hint:** `FOR UPDATE` locks the paying row. `SIGNAL` raises your own error. The `EXIT HANDLER` rolls everything back, then passes the error on.

**Expected output**

**(a) create**

_No result rows. Action Output: 0 row(s) affected._

**(b) transfer 100**

_No result rows. Action Output: 0 row(s) affected._

**(c) balances after the first transfer**

| account_num | account_holder | balance |
|---|---|---|
| A10 | Smith | 800.00 |
| A25 | Jones | 1200.00 |
| A30 | Brown | 500.00 |

**(d) transfer 5000**

> `Error Code: 1644. Insufficient funds`

**(e) balances after the failed transfer**

| account_num | account_holder | balance |
|---|---|---|
| A10 | Smith | 800.00 |
| A25 | Jones | 1200.00 |
| A30 | Brown | 500.00 |

<details>
<summary>Show the code</summary>

**(a) create**

```sql
DELIMITER $$
CREATE PROCEDURE Transfer (IN p_from CHAR(3), IN p_to CHAR(3),
                           IN p_amount DECIMAL(8,2))
BEGIN
  DECLARE v_balance DECIMAL(8,2);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;
  START TRANSACTION;
  SELECT balance INTO v_balance FROM ACCOUNT
  WHERE account_num = p_from FOR UPDATE;
  IF v_balance < p_amount THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds';
  END IF;
  UPDATE ACCOUNT
  SET balance = balance - p_amount
  WHERE account_num = p_from;
  UPDATE ACCOUNT
  SET balance = balance + p_amount
  WHERE account_num = p_to;
  COMMIT;
END$$
DELIMITER ;
```

**(b) transfer 100**

```sql
CALL Transfer('A10', 'A25', 100);
```

**(c) check**

```sql
SELECT * FROM ACCOUNT;
```

**(d) transfer 5000**

```sql
CALL Transfer('A10', 'A25', 5000);
```

**(e) check**

```sql
SELECT * FROM ACCOUNT;
```

</details>

## Question 5

**The lost update problem.** Account A30 has 500. Session A withdraws 100 and Session B deposits 50 at the same time, so the correct final balance is **450**.

(a) Run the first table. Each session reads the balance and then writes the value it worked out. What is the final balance?

(b) Set A30 back to 500 (`UPDATE ACCOUNT SET balance = 500 WHERE account_num = 'A30';`) and run the second table, which locks the row with `SELECT ... FOR UPDATE`.

> **Hint:** In (a) both sessions read 500 before either writes, so B overwrites A. In (b) `FOR UPDATE` makes B **wait** until A commits, so B reads the up-to-date balance.

**Expected output**

**(a)**

```text
Session A reads 500.00 at t3.
Session B reads 500.00 at t4.
Final balance of A30: 550.00  (should be 450.00: A's withdrawal is lost)
```

**(b)**

```text
Session A reads 500.00 at t2 and now holds a lock on the row.
Session B's SELECT at t4 does not finish: it waits for the lock.
After A commits at t6, B's SELECT completes and returns 400.00.
Final balance of A30: 450.00  (correct)
```

<details>
<summary>Show the code</summary>

**(a) without locking**

| Time | Session A (withdraw 100) | Session B (deposit 50) |
|---|---|---|
| t1 | `START TRANSACTION;` |  |
| t2 |  | `START TRANSACTION;` |
| t3 | `SELECT balance FROM ACCOUNT WHERE account_num = 'A30';` |  |
| t4 |  | `SELECT balance FROM ACCOUNT WHERE account_num = 'A30';` |
| t5 | `UPDATE ACCOUNT SET balance = 400 WHERE account_num = 'A30';` |  |
| t6 | `COMMIT;` |  |
| t7 |  | `UPDATE ACCOUNT SET balance = 550 WHERE account_num = 'A30';` |
| t8 |  | `COMMIT;` |

**(b) with `FOR UPDATE`**

| Time | Session A (withdraw 100) | Session B (deposit 50) |
|---|---|---|
| t1 | `START TRANSACTION;` |  |
| t2 | `SELECT balance FROM ACCOUNT WHERE account_num = 'A30' FOR UPDATE;` |  |
| t3 |  | `START TRANSACTION;` |
| t4 |  | `SELECT balance FROM ACCOUNT WHERE account_num = 'A30' FOR UPDATE;` |
| t5 | `UPDATE ACCOUNT SET balance = 400 WHERE account_num = 'A30';` |  |
| t6 | `COMMIT;` |  |
| t7 |  | `UPDATE ACCOUNT SET balance = 450 WHERE account_num = 'A30';` |
| t8 |  | `COMMIT;` |

</details>

## Question 6

**Deadlock.** Run the steps in order. Each session locks one row and then asks for the row the other session holds. What happens at t6?

> **Hint:** Each session is waiting for the other, so neither can ever finish. MySQL spots this at once and **aborts one** (the victim) so the other can carry on. The victim should simply be run again.

**Expected output**

**Session B at t6:**

> `Error Code: 1213. Deadlock found when trying to get lock; try restarting transaction`

Session A's UPDATE at t5, which was waiting, then completes.

<details>
<summary>Show the code</summary>

| Time | Session A | Session B |
|---|---|---|
| t1 | `START TRANSACTION;` |  |
| t2 |  | `START TRANSACTION;` |
| t3 | `UPDATE ACCOUNT SET balance = balance - 10 WHERE account_num = 'A10';` |  |
| t4 |  | `UPDATE ACCOUNT SET balance = balance - 10 WHERE account_num = 'A25';` |
| t5 | `UPDATE ACCOUNT SET balance = balance + 10 WHERE account_num = 'A25';` |  |
| t6 |  | `UPDATE ACCOUNT SET balance = balance + 10 WHERE account_num = 'A10';` |
| t7 | `ROLLBACK;` | `ROLLBACK;` |

</details>
