# Lab 7: Outer Joins and Unmatched Rows

**Database:** `class_db and projemp` (PART 1 and PART 2 of `sql/year1_sql_lab.sql`)

**What you will learn**

- keep unmatched rows with `LEFT`, `RIGHT` and (emulated) `FULL` outer joins
- find rows that have **no match**
- count correctly when a group can be empty

## Before you start

Run **PART 1** and **PART 2** of `sql/year1_sql_lab.sql`. Each question starts with the `USE` it needs.

## Question 1

(class_db) List each member with their club using an **INNER JOIN**. Who is missing?

> **Hint:** An inner join keeps only rows with a match in **both** tables.

**Expected output**

| member_name | club_name |
|---|---|
| Smith | Judo |
| White | Tennis |
| Black | Judo |
| Green | Tennis |

<details>
<summary>Show the code</summary>

```sql
USE class_db;
SELECT member_name, club_name
FROM MEMBER INNER JOIN CLUB
ON MEMBER.club_id = CLUB.club_id;
```

</details>

## Question 2

List **all** members with their club, including members who belong to no club.

> **Hint:** A `LEFT OUTER JOIN` keeps **all** rows of the table on the left. Where there is no match, the right-hand columns are `NULL`.

**Expected output**

| member_id | member_name | club_id | club_name |
|---|---|---|---|
| M20 | Smith | C3 | Judo |
| M21 | Jones | NULL | NULL |
| M22 | White | C1 | Tennis |
| M23 | Black | C3 | Judo |
| M24 | Green | C1 | Tennis |
| M25 | Brown | NULL | NULL |

<details>
<summary>Show the code</summary>

```sql
SELECT member_id, member_name, MEMBER.club_id, club_name
FROM MEMBER LEFT OUTER JOIN CLUB
ON MEMBER.club_id = CLUB.club_id;
```

</details>

## Question 3

List **all** clubs with their members, including clubs with no members.

> **Hint:** Now the table on the **right** keeps all its rows. Take `club_id` from `CLUB` so Archery still shows C2.

**Expected output**

| member_id | member_name | club_id | club_name |
|---|---|---|---|
| M24 | Green | C1 | Tennis |
| M22 | White | C1 | Tennis |
| NULL | NULL | C2 | Archery |
| M23 | Black | C3 | Judo |
| M20 | Smith | C3 | Judo |

<details>
<summary>Show the code</summary>

```sql
SELECT member_id, member_name, CLUB.club_id, club_name
FROM MEMBER RIGHT OUTER JOIN CLUB
ON MEMBER.club_id = CLUB.club_id;
```

</details>

## Question 4

Show **all** members **and** all clubs (a full outer join). First try `FULL OUTER JOIN`, then emulate it.

> **Hint:** A full join is a left join plus a right join. `UNION` removes the duplicates.

**Expected output**

**(a) MySQL has no FULL OUTER JOIN**

> `Error Code: 1064. You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'OUTER JOIN CLUB ON MEMBER.club_id = CLUB.club_id' at line 2`

**(b) LEFT + RIGHT with UNION**

| member_id | member_name | club_id | club_name |
|---|---|---|---|
| M20 | Smith | C3 | Judo |
| M21 | Jones | NULL | NULL |
| M22 | White | C1 | Tennis |
| M23 | Black | C3 | Judo |
| M24 | Green | C1 | Tennis |
| M25 | Brown | NULL | NULL |
| NULL | NULL | C2 | Archery |

<details>
<summary>Show the code</summary>

**(a) MySQL has no FULL OUTER JOIN**

```sql
SELECT *
FROM MEMBER FULL OUTER JOIN CLUB
ON MEMBER.club_id = CLUB.club_id;
```

**(b) LEFT + RIGHT with UNION**

```sql
SELECT member_id, member_name, MEMBER.club_id, club_name
FROM MEMBER LEFT OUTER JOIN CLUB
ON MEMBER.club_id = CLUB.club_id
UNION
SELECT member_id, member_name, CLUB.club_id, club_name
FROM MEMBER RIGHT OUTER JOIN CLUB
ON MEMBER.club_id = CLUB.club_id;
```

</details>

## Question 5

List the members who belong to **no club**, using a `LEFT JOIN`.

> **Hint:** Keep only the rows where the **right** table found nothing. Test its primary key with `IS NULL`.

**Expected output**

| member_id | member_name |
|---|---|
| M21 | Jones |
| M25 | Brown |

<details>
<summary>Show the code</summary>

```sql
SELECT member_id, member_name
FROM MEMBER LEFT OUTER JOIN CLUB
ON MEMBER.club_id = CLUB.club_id
WHERE CLUB.club_id IS NULL;
```

</details>

## Question 6

List the clubs that have **no members**, using a `RIGHT JOIN` and the table aliases `M` and `C`.

**Expected output**

| club_id | club_name |
|---|---|
| C2 | Archery |

<details>
<summary>Show the code</summary>

```sql
SELECT C.club_id, club_name
FROM MEMBER AS M RIGHT OUTER JOIN CLUB AS C
ON M.club_id = C.club_id
WHERE M.member_id IS NULL;
```

</details>

## Question 7

(projemp) Show how many employees are in **each department, including departments with none**. Then change `COUNT(eno)` to `COUNT(*)`. What goes wrong?

> **Hint:** `COUNT(eno)` ignores `NULL`, so an empty department counts 0. `COUNT(*)` counts the one all-`NULL` row, so it counts 1, which is wrong.

**Expected output**

**(a) COUNT(eno)**

| dname | num_employees |
|---|---|
| engineering | 7 |
| information | 9 |
| personnel | 0 |
| service | 5 |

**(b) COUNT(*)**

| dname | num_employees |
|---|---|
| engineering | 7 |
| information | 9 |
| personnel | 1 |
| service | 5 |

<details>
<summary>Show the code</summary>

**(a) COUNT(eno)**

```sql
USE projemp;
SELECT dname, COUNT(eno) AS num_employees
FROM DEPT LEFT OUTER JOIN EMP
ON DEPT.dno = EMP.dno
GROUP BY dname
ORDER BY dname;
```

**(b) COUNT(*)**

```sql
SELECT dname, COUNT(*) AS num_employees
FROM DEPT LEFT OUTER JOIN EMP
ON DEPT.dno = EMP.dno
GROUP BY dname
ORDER BY dname;
```

</details>

## Question 8

List the projects that have **no staff** assigned to them.

**Expected output**

| pno | pname |
|---|---|
| p31 | warehouse |

<details>
<summary>Show the code</summary>

```sql
SELECT PROJ.pno, pname
FROM PROJ LEFT OUTER JOIN WORKS
ON PROJ.pno = WORKS.pno
WHERE WORKS.eno IS NULL;
```

</details>
