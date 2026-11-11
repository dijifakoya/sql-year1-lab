# SQL for Year One: Lab Project

[![check labs](https://github.com/dijifakoya/sql-year1-lab/actions/workflows/check-labs.yml/badge.svg)](https://github.com/dijifakoya/sql-year1-lab/actions/workflows/check-labs.yml)
![MySQL](https://img.shields.io/badge/MySQL-8.0.31%2B-blue)
![Licence](https://img.shields.io/badge/licence-CC%20BY%204.0-green)

Hands-on SQL labs for first-year database students, using **MySQL**. The project is one SQL script that creates every practice database, and 11 lab sheets that walk through 98 questions, from creating a first table to transactions and indexes. Every question shows the **question**, the **expected output** and the **code**.

**Who it is for**

- **Students** learning SQL for the first time, working through the labs at their own pace.
- **Lecturers and tutors** who want ready-made, tested lab sheets for an introductory databases module.

## What is in this repository

```
sql-year1-lab/
├── README.md
├── sql/
│   └── year1_sql_lab.sql      one script, five databases (split into PARTS)
├── labs/
│   ├── 01-creating-databases-and-tables.md
│   ├── 02-single-table-queries.md
│   └── ... (one file per lab)
└── tests/
    └── check_labs.py          runs every lab against fresh databases
```

## Quick start

1. Install **MySQL Server 8.0.31 or later** and **MySQL Workbench** (the set operators `INTERSECT` and `EXCEPT` need 8.0.31+).
2. Clone this repository (or download it as a ZIP).
3. In Workbench choose **File | Open SQL Script** and open `sql/year1_sql_lab.sql`.
4. Run the whole file once with **Ctrl + Shift + Enter**. This creates all five databases.
5. Open `labs/01-creating-databases-and-tables.md` and start.

To put **one** database back to its starting state, select its PART in the script (from its banner down to just before the next banner) and run only that selection. Every PART drops and re-creates its own database, so it is always safe to re-run.

## The labs

| Lab | Topic | Database | Questions |
|---|---|---|---|
| 1 | [Creating a Database and Tables](labs/01-creating-databases-and-tables.md) | lab01 | 10 |
| 2 | [Single-Table Queries](labs/02-single-table-queries.md) | projemp | 14 |
| 3 | [GROUP BY and HAVING](labs/03-group-by-and-having.md) | projemp | 8 |
| 4 | [Joins (Two or More Tables)](labs/04-joins.md) | class_db and projemp | 8 |
| 5 | [Nested Queries (Subqueries)](labs/05-nested-queries.md) | projemp | 8 |
| 6 | [LIKE, NULL and Set Operators](labs/06-like-null-and-set-operators.md) | class_db | 11 |
| 7 | [Outer Joins and Unmatched Rows](labs/07-outer-joins.md) | class_db and projemp | 8 |
| 8 | [Stored Procedures](labs/08-stored-procedures.md) | proc3 | 9 |
| 9 | [Triggers](labs/09-triggers.md) | proc3 | 8 |
| 10 | [Transactions and Concurrency](labs/10-transactions.md) | txn_demo | 6 |
| 11 | [Indexes and Storage Structures](labs/11-indexes.md) | storage_demo | 8 |

## How each lab is laid out

Each question has the same three steps:

1. **Question**: read it and try it yourself first.
2. **Expected output**: what your query should return. Compare it with your result.
3. **Code**: hidden under **Show the code**. Open it only when you are stuck, or to check your answer.

Many questions also have a **Hint**.

## The databases (`sql/year1_sql_lab.sql`)

| PART | Database | Used in | Contents |
|---|---|---|---|
| 1 | `class_db` | Labs 4, 6, 7 | `EMPLOYEE`, `PROJECT`, `WORKS_ON` (a small company database), plus `SUPPLIER`, `CUSTOMER`, `CLUB`, `MEMBER` for set operators, `NULL` and outer joins |
| 2 | `projemp` | Labs 2, 3, 4, 5, 7 | `DEPT`, `EMP`, `PROJ`, `WORKS` (21 employees, 4 departments, 6 projects, 39 assignments) |
| 3 | `proc3` | Labs 8, 9 | `EMP`, `DEPT`, `ACCOUNT`, `ARCHACC`, `AUDIT`, `ARCHEMP`, `EMPAUDIT` |
| 4 | `txn_demo` | Lab 10 | A small bank: accounts A10, A25 and A30 |
| 5 | `storage_demo` | Lab 11 | `BIGEMP` with 100,000 rows (takes a few seconds to load) |

Lab 1 needs no part: students create their own database, `lab01`, and remove it in the final clean-up step.

The data has some **deliberate gaps** that the labs use: department `d4` has no employees, project `p31` has no staff, employee `e1` has no supervisor, two club members belong to no club, and the Archery club has no members.

## Things to know

- **Safe Updates.** Workbench blocks `UPDATE` and `DELETE` statements that do not use a key in the `WHERE`. Labs 8 and 9 tell students to run `SET SQL_SAFE_UPDATES = 0;` at the top of the query tab.
- **Row order.** Unless a query has `ORDER BY`, MySQL may list rows in a different order from the expected output. Check that the **same rows** come back.
- **Table names are in CAPITALS** in the script and the labs, so everything works on Windows, Mac and Linux (Linux treats table names as case-sensitive).
- **Times and IDs.** Date and time columns (for example the audit logs) show the moment you ran the statement, so the expected output shows `(date and time)`.
- **`EXPLAIN` row counts** in Lab 11 are estimates, so yours may differ a little.
- **Labs 10 and 11** are best done after the earlier labs. Lab 10 uses two query tabs to play two users at once.

## How the expected outputs were produced

Every query and statement in the labs was run on **MySQL 8.0.46**, in order, on freshly loaded databases, and the output pasted into the lab. The two-session experiments in Lab 10 (isolation, the lost update, the lock fix and the deadlock) were run on two live connections.

## Automated checks

`tests/check_labs.py` reloads the databases, runs every code block in every lab in order, and fails if MySQL reports any error that the lab does not show on purpose (several questions demonstrate errors, such as a foreign key violation). It runs automatically on GitHub Actions after every change.

To run it yourself:

```bash
MYSQL_CMD="mysql -uroot -p" python3 tests/check_labs.py
```

## Author

**Dr Adediji Fakoya, PhD, FHEA, MBCS** — lecturer in computing (databases, data science and machine learning).
[LinkedIn](https://www.linkedin.com/in/diji-fakoya-phd-b55712122/) · [GitHub](https://github.com/dijifakoya)

## Licence

The lab sheets and SQL script are released under the [Creative Commons Attribution 4.0 International licence (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/). You may use and adapt them in your own teaching, provided you credit the author.
