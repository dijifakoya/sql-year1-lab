/* =====================================================================
   SQL for Year One: lab database script

   One script, five databases. Every part DROPS and re-creates its own
   database, so running a part again always puts the data back to its
   starting state. Table names are in CAPITALS so the labs work on Windows,
   Mac and Linux.

   How to use it (MySQL Workbench):
     - Run the WHOLE file once with Ctrl + Shift + Enter to create everything.
     - To reset ONE database: select that part (from its banner down to just
       before the next banner) and press Ctrl + Shift + Enter.

     PART 1  class_db       Labs 4, 6, 7
     PART 2  projemp        Labs 2, 3, 4, 5, 7
     PART 3  proc3          Labs 8, 9
     PART 4  txn_demo       Lab 10
     PART 5  storage_demo   Lab 11   (100,000 rows; takes a few seconds)

   Lab 1 needs no part: you create your own database, lab01, in the lab.
   Needs MySQL 8.0.31 or later (INTERSECT and EXCEPT).
   ===================================================================== */

-- ======================================================================
-- PART 1: class_db  (Labs 4, 6, 7)
-- ======================================================================
-- EMPLOYEE, PROJECT, WORKS_ON: a small company database (employees, projects and who works on what).
-- SUPPLIER, CUSTOMER: for set operators.   CLUB, MEMBER: for NULL and outer joins.
-- ======================================================================

DROP DATABASE IF EXISTS class_db;
CREATE DATABASE class_db;
USE class_db;

-- Company tables
CREATE TABLE EMPLOYEE (
  enum    INT NOT NULL,
  ename   VARCHAR(25),
  salary  DECIMAL(8,2),
  floor   TINYINT,
  CONSTRAINT pk_emp PRIMARY KEY (enum)
);

CREATE TABLE PROJECT (
  pnum    SMALLINT NOT NULL,
  pname   VARCHAR(25),
  leader  VARCHAR(25),
  CONSTRAINT pk_proj PRIMARY KEY (pnum)
);

CREATE TABLE WORKS_ON (
  enum  INT NOT NULL,
  pnum  SMALLINT NOT NULL,
  role  VARCHAR(20),
  CONSTRAINT pk_wrks   PRIMARY KEY (enum, pnum),
  CONSTRAINT fk_wrks_1 FOREIGN KEY (enum) REFERENCES EMPLOYEE (enum),
  CONSTRAINT fk_wrks_2 FOREIGN KEY (pnum) REFERENCES PROJECT (pnum)
);

INSERT INTO EMPLOYEE VALUES
(852341, 'Smith',  15000, 1),
(852358, 'Jones',  19000, 3),
(852407, 'Brown',  16000, 3),
(852455, 'White',  25100, 2),
(852491, 'Adams',  30500, 1),
(852514, 'Doyle',  11650, 2),
(852530, 'Evans',  26980, 4);

INSERT INTO PROJECT VALUES
(121, 'IT',        'Gates'),
(135, 'Design',    'Sinclair'),
(147, 'Analysis',  'Einstein'),
(216, 'Publicity', 'Saatchi'),
(227, 'Theatre',   'Dench'),
(251, 'Sport',     'Shearer');

INSERT INTO WORKS_ON VALUES
(852341, 121, 'Manager'),
(852341, 135, 'Designer'),
(852358, 147, 'Consultant'),
(852358, 135, 'Consultant'),
(852407, 216, 'Assistant'),
(852455, 121, 'Assistant'),
(852455, 227, 'Manager'),
(852491, 135, 'Designer'),
(852491, 216, 'Manager'),
(852514, 121, 'Assistant'),
(852514, 216, 'Consultant'),
(852514, 251, 'Manager'),
(852530, 147, 'Manager');

-- Tables for set operators (Microsoft and Apple are in BOTH tables)
CREATE TABLE SUPPLIER (
  sup_no   CHAR(4) NOT NULL,
  s_name   VARCHAR(20),
  country  VARCHAR(15),
  PRIMARY KEY (sup_no)
);
INSERT INTO SUPPLIER VALUES
('s121', 'Big IT',     'Germany'),
('s135', 'Top Design', 'Italy'),
('s147', 'ALY Ltd',    'USA'),
('s216', 'Microsoft',  'France'),
('s227', 'Apple',      'Zambia'),
('s251', 'PC Sport',   'Vietnam');

CREATE TABLE CUSTOMER (
  cus_no   CHAR(4) NOT NULL,
  c_name   VARCHAR(20),
  contact  VARCHAR(15),
  PRIMARY KEY (cus_no)
);
INSERT INTO CUSTOMER VALUES
('c164', 'Apple',     'Jobs'),
('c045', 'IT r us',   'Sinclair'),
('c237', 'Microsoft', 'Gates'),
('c256', 'Myco',      'Jones'),
('c290', 'MFN Ltd',   'Smith'),
('c515', 'HP',        'Bloggs');

-- Tables for NULL and outer joins
-- Jones (M21) and Brown (M25) have NO club. The Archery club (C2) has NO members.
CREATE TABLE CLUB (
  club_id    CHAR(2) NOT NULL,
  club_name  VARCHAR(15),
  PRIMARY KEY (club_id)
);
INSERT INTO CLUB VALUES ('C1', 'Tennis'), ('C2', 'Archery'), ('C3', 'Judo');

CREATE TABLE MEMBER (
  member_id    CHAR(3) NOT NULL,
  member_name  VARCHAR(15),
  club_id      CHAR(2) DEFAULT NULL,
  PRIMARY KEY (member_id),
  CONSTRAINT member_ibfk_1 FOREIGN KEY (club_id) REFERENCES CLUB (club_id)
);
INSERT INTO MEMBER VALUES
('M20', 'Smith', 'C3'),
('M21', 'Jones', NULL),
('M22', 'White', 'C1'),
('M23', 'Black', 'C3'),
('M24', 'Green', 'C1'),
('M25', 'Brown', NULL);


-- ======================================================================
-- PART 2: projemp  (Labs 2, 3, 4, 5, 7)
-- ======================================================================
-- DEPT, EMP, PROJ, WORKS. Department d4 has no employees; project p31 has no
-- staff; employee e1 has no supervisor (supno is NULL). EMP.dno may be NULL.
-- ======================================================================

CREATE DATABASE IF NOT EXISTS projemp;
USE projemp;

-- Drop tables (children first, so there are no foreign key errors)
DROP TABLE IF EXISTS WORKS;
DROP TABLE IF EXISTS EMP;
DROP TABLE IF EXISTS PROJ;
DROP TABLE IF EXISTS DEPT;

-- ---------------------------------------------------------------------
-- DEPT
-- Note: department d4 (personnel) has no employees.
-- ---------------------------------------------------------------------
CREATE TABLE DEPT (
  dno       CHAR(3)  NOT NULL,
  dname     CHAR(15) DEFAULT NULL,
  location  CHAR(15) DEFAULT NULL,
  PRIMARY KEY (dno)
);

INSERT INTO DEPT (dno, dname, location) VALUES
('d1', 'information', 'newry'),
('d2', 'service',     'belfast'),
('d3', 'engineering', 'belfast'),
('d4', 'personnel',   'belfast');

-- ---------------------------------------------------------------------
-- EMP
-- Note: employee e1 (armstrong) has no supervisor (supno is NULL).
--       dno allows NULL (see the note at the top of this file).
-- ---------------------------------------------------------------------
CREATE TABLE EMP (
  eno     CHAR(3)       NOT NULL,
  ename   CHAR(15)      DEFAULT NULL,
  salary  DECIMAL(8,2)  DEFAULT NULL,
  age     TINYINT       DEFAULT NULL,
  supno   CHAR(3)       DEFAULT NULL,
  dno     CHAR(3)       DEFAULT NULL,
  PRIMARY KEY (eno)
);

INSERT INTO EMP (eno, ename, salary, age, supno, dno) VALUES
('e1',  'armstrong', 50000, 56, NULL, 'd1'),
('e10', 'jones',     48000, 49, 'e1',  'd3'),
('e11', 'kelly',     28000, 36, 'e7',  'd2'),
('e12', 'mccoy',     33000, 29, 'e3',  'd2'),
('e13', 'neeson',    48000, 36, 'e19', 'd1'),
('e14', 'oliver',    26000, 35, 'e17', 'd3'),
('e15', 'pearse',    20000, 28, 'e21', 'd1'),
('e16', 'quinn',     33000, 54, 'e2',  'd1'),
('e17', 'roberts',   21000, 27, 'e4',  'd3'),
('e18', 'smyth',     33000, 34, 'e21', 'd3'),
('e19', 'trainor',   35000, 39, 'e7',  'd1'),
('e2',  'breen',     17000, 21, 'e4',  'd3'),
('e20', 'urquhart',  19000, 22, 'e11', 'd3'),
('e21', 'vance',     15000, 19, 'e10', 'd1'),
('e3',  'carroll',   18000, 31, 'e10', 'd3'),
('e4',  'deehan',    50000, 48, 'e1',  'd1'),
('e5',  'evans',     38000, 45, 'e11', 'd1'),
('e6',  'flynn',     24000, 30, 'e17', 'd2'),
('e7',  'greer',     16000, 24, 'e1',  'd2'),
('e8',  'hamill',    25000, 38, 'e3',  'd1'),
('e9',  'irwin',     23000, 48, 'e2',  'd2');

-- ---------------------------------------------------------------------
-- PROJ
-- Note: project p31 (warehouse) has no employees working on it.
-- ---------------------------------------------------------------------
CREATE TABLE PROJ (
  pno     CHAR(3)       NOT NULL,
  pname   CHAR(15)      DEFAULT NULL,
  ptype   CHAR(15)      DEFAULT NULL,
  budget  DECIMAL(9,2)  DEFAULT NULL,
  PRIMARY KEY (pno)
);

INSERT INTO PROJ (pno, pname, ptype, budget) VALUES
('p13', 'payroll',      'access', 520000),
('p15', 'database',     'access', 540000),
('p19', 'graphics',     'c',      650000),
('p23', 'registration', 'access', 790000),
('p26', 'examination',  'c',      690000),
('p31', 'warehouse',    'php',     30000);

-- ---------------------------------------------------------------------
-- WORKS
-- ---------------------------------------------------------------------
CREATE TABLE WORKS (
  eno       CHAR(3)   NOT NULL,
  pno       CHAR(3)   NOT NULL,
  role      CHAR(15)  DEFAULT NULL,
  duration  TINYINT   DEFAULT NULL,
  PRIMARY KEY (eno, pno)
);

INSERT INTO WORKS (eno, pno, role, duration) VALUES
('e1',  'p19', 'consultant',    6),
('e1',  'p23', 'consultant',    6),
('e10', 'p15', 'manager',       4),
('e11', 'p19', 'administrator', 10),
('e12', 'p23', 'consultant',    6),
('e12', 'p26', 'administrator', 8),
('e13', 'p23', 'manager',       12),
('e14', 'p23', 'engineer',      8),
('e14', 'p26', 'analyst',       5),
('e15', 'p13', 'programmer',    7),
('e15', 'p19', 'programmer',    8),
('e15', 'p23', 'programmer',    4),
('e16', 'p19', 'manager',       6),
('e16', 'p23', 'manager',       10),
('e17', 'p13', 'analyst',       8),
('e17', 'p19', 'programmer',    4),
('e18', 'p13', 'consultant',    6),
('e18', 'p23', 'analyst',       5),
('e18', 'p26', 'consultant',    8),
('e19', 'p15', 'analyst',       9),
('e19', 'p19', 'consultant',    5),
('e2',  'p15', 'engineer',      6),
('e20', 'p15', 'engineer',      8),
('e20', 'p19', 'engineer',      6),
('e21', 'p13', 'programmer',    8),
('e21', 'p23', 'programmer',    7),
('e21', 'p26', 'programmer',    10),
('e3',  'p19', 'programmer',    8),
('e3',  'p26', 'engineer',      4),
('e4',  'p26', 'manager',       6),
('e5',  'p13', 'manager',       11),
('e6',  'p19', 'consultant',    9),
('e6',  'p26', 'analyst',       5),
('e7',  'p13', 'administrator', 8),
('e7',  'p15', 'administrator', 7),
('e8',  'p13', 'programmer',    12),
('e8',  'p23', 'analyst',       4),
('e9',  'p13', 'programmer',    6),
('e9',  'p19', 'consultant',    9);

-- ---------------------------------------------------------------------
-- Foreign keys
-- ---------------------------------------------------------------------
ALTER TABLE EMP
  ADD CONSTRAINT emp_ibfk_1 FOREIGN KEY (dno) REFERENCES DEPT (dno);

ALTER TABLE WORKS
  ADD CONSTRAINT works_ibfk_1 FOREIGN KEY (eno) REFERENCES EMP (eno);

ALTER TABLE WORKS
  ADD CONSTRAINT works_ibfk_2 FOREIGN KEY (pno) REFERENCES PROJ (pno);

-- ---------------------------------------------------------------------
-- Check the load. You should see: DEPT 4, EMP 21, PROJ 6, WORKS 39
-- ---------------------------------------------------------------------
SELECT 'DEPT' AS table_name, COUNT(*) AS num_rows FROM DEPT
UNION ALL SELECT 'EMP',   COUNT(*) FROM EMP
UNION ALL SELECT 'PROJ',  COUNT(*) FROM PROJ
UNION ALL SELECT 'WORKS', COUNT(*) FROM WORKS;


-- ======================================================================
-- PART 3: proc3  (Labs 8, 9)
-- ======================================================================
-- EMP, DEPT (empty), ACCOUNT, ARCHACC, AUDIT, ARCHEMP, EMPAUDIT.
-- Procedures and triggers are created by YOU in the labs.
-- ======================================================================

DROP DATABASE IF EXISTS proc3;
CREATE DATABASE proc3;
USE proc3;

-- Employees and departments. DEPT starts EMPTY (numemp = number of employees).
CREATE TABLE EMP (
  enum    TINYINT NOT NULL,
  ename   CHAR(15),
  salary  DECIMAL(7,2),
  age     TINYINT,
  dnum    TINYINT,
  CONSTRAINT pk_emp PRIMARY KEY (enum)
);
INSERT INTO EMP VALUES
(1, 'Smith', 25000, 25, 11),
(2, 'Jones', 32000, 41, 12),
(3, 'White', 19000, 34, 11),
(4, 'Brown', 28000, 22, 12);

CREATE TABLE DEPT (
  dnum    TINYINT NOT NULL,
  dname   CHAR(15),
  numemp  TINYINT,
  CONSTRAINT pk_dept PRIMARY KEY (dnum)
);

-- Bank accounts, an archive of deleted accounts, and an audit log.
-- AUDIT.id is AUTO_INCREMENT: MySQL generates 1, 2, 3 ...
CREATE TABLE ACCOUNT (
  accnum   INT NOT NULL,
  balance  SMALLINT,
  CONSTRAINT pk_account PRIMARY KEY (accnum)
);
INSERT INTO ACCOUNT VALUES
(12345,  150),
(23456, 1400),
(34567,  850),
(45678, 2300),
(56789, 1865);

CREATE TABLE ARCHACC (
  accnum   INT NOT NULL,
  balance  SMALLINT,
  CONSTRAINT pk_archacc PRIMARY KEY (accnum)
);

CREATE TABLE AUDIT (
  id           INT NOT NULL AUTO_INCREMENT,
  accnum       INT,
  old_balance  SMALLINT,
  new_balance  SMALLINT,
  atime        DATETIME,
  CONSTRAINT pk_audit PRIMARY KEY (id)
);

-- Archive and audit tables for the employee triggers
CREATE TABLE ARCHEMP (
  enum    TINYINT NOT NULL,
  ename   CHAR(15),
  salary  DECIMAL(7,2),
  age     TINYINT,
  dnum    TINYINT,
  CONSTRAINT pk_archemp PRIMARY KEY (enum)
);

CREATE TABLE EMPAUDIT (
  id          INT NOT NULL AUTO_INCREMENT,
  enum        TINYINT,
  oldsalary   DECIMAL(7,2),
  newsalary   DECIMAL(7,2),
  changedate  DATETIME,
  CONSTRAINT pk_empaudit PRIMARY KEY (id)
);


-- ======================================================================
-- PART 4: txn_demo  (Lab 10)
-- ======================================================================
-- ACCOUNT: A10 and A25 with 1000 each, A30 with 500.
-- ======================================================================

DROP DATABASE IF EXISTS txn_demo;
CREATE DATABASE txn_demo;
USE txn_demo;

CREATE TABLE ACCOUNT (
  account_num     CHAR(3)       NOT NULL,
  account_holder  VARCHAR(20),
  balance         DECIMAL(8,2),
  PRIMARY KEY (account_num)
) ENGINE = InnoDB;

INSERT INTO ACCOUNT (account_num, account_holder, balance) VALUES
('A10', 'Smith', 1000.00),
('A25', 'Jones', 1000.00),
('A30', 'Brown',  500.00);

-- Check the load. You should see 3 accounts and a total balance of 2500.00
SELECT COUNT(*) AS num_accounts, SUM(balance) AS total_balance FROM ACCOUNT;


-- ======================================================================
-- PART 5: storage_demo  (Lab 11)
-- ======================================================================
-- BIGEMP with 100,000 rows.
-- ======================================================================

DROP DATABASE IF EXISTS storage_demo;
CREATE DATABASE storage_demo;
USE storage_demo;

CREATE TABLE BIGEMP (
  empid   INT           NOT NULL AUTO_INCREMENT,
  ename   VARCHAR(20)   NOT NULL,
  dno     CHAR(3)       NOT NULL,
  salary  DECIMAL(8,2)  NOT NULL,
  PRIMARY KEY (empid)
);

-- A recursive query generates the numbers 1 to 100000.
-- cte_max_recursion_depth must be raised, because the default limit is 1000.
SET SESSION cte_max_recursion_depth = 100000;

INSERT INTO BIGEMP (ename, dno, salary)
WITH RECURSIVE seq (n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM seq WHERE n < 100000
)
SELECT CONCAT('emp', n),                 -- emp1, emp2, ... emp100000
       CONCAT('d', 1 + MOD(n, 4)),       -- d1 to d4
       15000 + MOD(n * 37, 40000)        -- salaries from 15000 to 54999
FROM seq;

-- Check the load. You should see 100000 rows.
SELECT COUNT(*) AS num_rows FROM BIGEMP;
