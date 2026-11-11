# Lab 8: Stored Procedures

**Database:** `proc3` (PART 3 of `sql/year1_sql_lab.sql`)

**What you will learn**

- create and call a stored procedure
- use `IN` and `OUT` parameters
- make decisions inside a procedure with `IF`
- list and drop procedures

## Before you start

1. Open `sql/year1_sql_lab.sql` in MySQL Workbench and run **PART 3** (select it, then **Ctrl + Shift + Enter**).
2. Open a new query tab and start it with `USE proc3;`
3. Try each question yourself **first**, then compare with the expected output. Open **Show the code** only if you are stuck.
4. Also run `SET SQL_SAFE_UPDATES = 0;` at the top of the tab. Without it Workbench blocks `UPDATE` statements inside procedures (Error 1175).
5. To create a procedure, write the `DELIMITER $$ ... DELIMITER ;` lines exactly as shown, **select the whole block** and run it.

## Question 1

Create a procedure `GetEmp` that returns every record in `EMP`, then run it.

> **Hint:** The body goes between `BEGIN` and `END`. `DELIMITER $$` stops Workbench ending the statement at the first `;`. Run a procedure with `CALL`.

**Expected output**

**(a) create**

_No result rows. Action Output: 0 row(s) affected._

**(b) run**

| enum | ename | salary | age | dnum |
|---|---|---|---|---|
| 1 | Smith | 25000.00 | 25 | 11 |
| 2 | Jones | 32000.00 | 41 | 12 |
| 3 | White | 19000.00 | 34 | 11 |
| 4 | Brown | 28000.00 | 22 | 12 |

<details>
<summary>Show the code</summary>

**(a) create**

```sql
DELIMITER $$
CREATE PROCEDURE GetEmp()
BEGIN
  SELECT * FROM EMP;
END$$
DELIMITER ;
```

**(b) run**

```sql
CALL GetEmp();
```

</details>

## Question 2

Create a procedure `GetEnameBySal` with an **input parameter** and use it to list the employees who earn more than 20,000, then more than 30,000.

> **Hint:** Give the parameter the same data type as the column. Start its name with `p_` so it can never be confused with a column.

**Expected output**

**(a) create**

_No result rows. Action Output: 0 row(s) affected._

**(b) 20000**

| ename |
|---|
| Smith |
| Jones |
| Brown |

**(c) 30000**

| ename |
|---|
| Jones |

<details>
<summary>Show the code</summary>

**(a) create**

```sql
DELIMITER $$
CREATE PROCEDURE GetEnameBySal (IN p_sal DECIMAL(7,2))
BEGIN
  SELECT ename FROM EMP WHERE salary > p_sal;
END$$
DELIMITER ;
```

**(b) 20000**

```sql
CALL GetEnameBySal(20000);
```

**(c) 30000**

```sql
CALL GetEnameBySal(30000);
```

</details>

## Question 3

Create a procedure `InsDept` that inserts a department, then use it to add departments 11 (admin), 12 (sales) and 13 (finance), each with 0 employees. Check `DEPT`.

**Expected output**

**(a) create**

_No result rows. Action Output: 0 row(s) affected._

**(b) call**

_No result rows. Each CALL reports 1 row(s) affected._

**(c) check**

| dnum | dname | numemp |
|---|---|---|
| 11 | admin | 0 |
| 12 | sales | 0 |
| 13 | finance | 0 |

<details>
<summary>Show the code</summary>

**(a) create**

```sql
DELIMITER $$
CREATE PROCEDURE InsDept (IN p_dnum TINYINT, IN p_dname CHAR(15),
                          IN p_numemp TINYINT)
BEGIN
  INSERT INTO DEPT
  VALUES (p_dnum, p_dname, p_numemp);
END$$
DELIMITER ;
```

**(b) call**

```sql
CALL InsDept(11, 'admin', 0);
CALL InsDept(12, 'sales', 0);
CALL InsDept(13, 'finance', 0);
```

**(c) check**

```sql
SELECT * FROM DEPT;
```

</details>

## Question 4

Try to add department 13 again. Read the error and explain it.

> **Hint:** What is `dnum` in the `DEPT` table?

**Expected output**

> `Error Code: 1062. Duplicate entry '13' for key 'DEPT.PRIMARY'`

<details>
<summary>Show the code</summary>

```sql
CALL InsDept(13, 'finance', 0);
```

</details>

## Question 5

Create a procedure `UpdEmpName` that changes an employee's name, given the employee number. Use it to rename employee 4 to Green and check.

**Expected output**

**(a) create**

_No result rows. Action Output: 0 row(s) affected._

**(b) call**

_No result rows. Action Output: 1 row(s) affected._

**(c) check**

| enum | ename | salary | age | dnum |
|---|---|---|---|---|
| 4 | Green | 28000.00 | 22 | 12 |

<details>
<summary>Show the code</summary>

**(a) create**

```sql
DELIMITER $$
CREATE PROCEDURE UpdEmpName (IN p_ename CHAR(15), IN p_enum TINYINT)
BEGIN
  UPDATE EMP
  SET ename = p_ename
  WHERE enum = p_enum;
END$$
DELIMITER ;
```

**(b) call**

```sql
CALL UpdEmpName('Green', 4);
```

**(c) check**

```sql
SELECT * FROM EMP WHERE enum = 4;
```

</details>

## Question 6

Create a procedure `GetSalByEnum` with an **OUT** parameter that returns an employee's salary. Call it for employee 2 and show the value.

> **Hint:** `SELECT ... INTO` puts the result into the OUT parameter. `@salary` is a session variable that receives it.

**Expected output**

**(a) create**

_No result rows. Action Output: 0 row(s) affected._

**(b) call**

_No result rows. Action Output: 1 row(s) affected._

**(c) show the value**

| @salary |
|---|
| 32000.00 |

<details>
<summary>Show the code</summary>

**(a) create**

```sql
DELIMITER $$
CREATE PROCEDURE GetSalByEnum (IN p_enum TINYINT, OUT p_sal DECIMAL(7,2))
BEGIN
  SELECT salary INTO p_sal
  FROM EMP
  WHERE enum = p_enum;
END$$
DELIMITER ;
```

**(b) call**

```sql
CALL GetSalByEnum(2, @salary);
```

**(c) show the value**

```sql
SELECT @salary;
```

</details>

## Question 7

Create a procedure `SalaryBand` that returns `High` (30,000 or more), `Medium` (20,000 or more) or `Low` for a given employee. Try employees 2, 1 and 3.

> **Hint:** `DECLARE` makes a local variable. `IF ... ELSEIF ... ELSE ... END IF` chooses between cases.

**Expected output**

**(a) create**

_No result rows. Action Output: 0 row(s) affected._

**(b) employee 2 (32000)**

| band_of_2 |
|---|
| High |

**(c) employee 1 (25000)**

| band_of_1 |
|---|
| Medium |

**(d) employee 3 (19000)**

| band_of_3 |
|---|
| Low |

<details>
<summary>Show the code</summary>

**(a) create**

```sql
DELIMITER $$
CREATE PROCEDURE SalaryBand (IN p_enum TINYINT, OUT p_band VARCHAR(10))
BEGIN
  DECLARE v_sal DECIMAL(7,2);
  SELECT salary INTO v_sal FROM EMP WHERE enum = p_enum;
  IF v_sal >= 30000 THEN
    SET p_band = 'High';
  ELSEIF v_sal >= 20000 THEN
    SET p_band = 'Medium';
  ELSE
    SET p_band = 'Low';
  END IF;
END$$
DELIMITER ;
```

**(b) employee 2 (32000)**

```sql
CALL SalaryBand(2, @band);
SELECT @band AS band_of_2;
```

**(c) employee 1 (25000)**

```sql
CALL SalaryBand(1, @band);
SELECT @band AS band_of_1;
```

**(d) employee 3 (19000)**

```sql
CALL SalaryBand(3, @band);
SELECT @band AS band_of_3;
```

</details>

## Question 8

List the procedures stored in `proc3`, and show the definition of `GetEmp`.

> **Hint:** In SQL Server you would use `sp_helptext`. MySQL uses `SHOW CREATE PROCEDURE`.

**Expected output**

**(a)**

| ROUTINE_NAME | ROUTINE_TYPE |
|---|---|
| GetEmp | PROCEDURE |
| GetEnameBySal | PROCEDURE |
| GetSalByEnum | PROCEDURE |
| InsDept | PROCEDURE |
| SalaryBand | PROCEDURE |
| UpdEmpName | PROCEDURE |

**(b)**

```text
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetEmp`()
BEGIN
  SELECT * FROM EMP;
END
```

<details>
<summary>Show the code</summary>

**(a)**

```sql
SELECT ROUTINE_NAME, ROUTINE_TYPE
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'proc3'
ORDER BY ROUTINE_NAME;
```

**(b)**

```sql
SHOW CREATE PROCEDURE GetEmp;
```

</details>

## Question 9

Drop `GetEmp` and check that it has gone.

**Expected output**

**(a)**

_No result rows. Action Output: 0 row(s) affected._

**(b)**

| num_procedures |
|---|
| 5 |

<details>
<summary>Show the code</summary>

**(a)**

```sql
DROP PROCEDURE GetEmp;
```

**(b)**

```sql
SELECT COUNT(*) AS num_procedures
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'proc3';
```

</details>
