---
title: "Relations between Tables"
teaching: 60
exercises: 30
---

:::{admonition} Questions
- How to perform SQL Join?
- How to make use of different SQL joins?
:::

:::{admonition} Objectives
- To retrieve data from multiple tables Simultaneously when data is related.
:::

Let's explore how to retrieve data from multiple tables simultaneously when the data is related.

Before starting, let's create a new database that will contain metadata from multiple experiments, and two tables to work with.
Let's name the database `all_experiments_data`:

```sql
CREATE DATABASE all_experiments_data;

USE all_experiments_data;
```

Now, let's create a table `experiments` with the following schema:
```sql
CREATE TABLE experiments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  experiment_name VARCHAR(255) NOT NULL UNIQUE,
  laboratory VARCHAR(255),
  collision_type VARCHAR(10),
  start_year INT
);
```

And populate it with some data
```sql
INSERT INTO experiments (experiment_name, laboratory, collision_type, start_year)
VALUES
  ("LHCb", "CERN", "pp", 2009),
  ("ATLAS", "CERN", "pp", 2008),
  ("CMS", "CERN", "pp", 2008),
  ("ALICE", "CERN", "PbPb", 2010),
  ("Belle2", "KEK", "e+e-", 2018),
  ("BaBar", "SLAC", "e+e-", 1999);
```

Remember that you can check the data in the table using:
```sql
SELECT * FROM experiments;
```
```text
+----+-----------------+------------+----------------+------------+
| id | experiment_name | laboratory | collision_type | start_year |
+----+-----------------+------------+----------------+------------+
|  1 | LHCb            | CERN       | pp             |       2009 |
|  2 | ATLAS           | CERN       | pp             |       2008 |
|  3 | CMS             | CERN       | pp             |       2008 |
|  4 | ALICE           | CERN       | PbPb           |       2010 |
|  5 | Belle2          | KEK        | e+e-           |       2018 |
|  6 | BaBar           | SLAC       | e+e-           |       1999 |
+----+-----------------+------------+----------------+------------+
```

Let's create another table `files` with the schema below
```sql
CREATE TABLE files (
  id INT AUTO_INCREMENT PRIMARY KEY,
  filename VARCHAR(255) NOT NULL UNIQUE,
  experiment_id INT NOT NULL,
  run_number INT NOT NULL,
  total_events INT NOT NULL,
  data_type VARCHAR(10)
);
```

Notice the following: we use `experiment_id` to link the `files` table to the `experiments` table.
This is a common practice to establish relationships between tables (and the reason why a relational database is called "relational").

We could in principle use the `experiment_name` column to link the tables, however, the best performance is achieved
when using keys (like `id` in the `experiments` table) to establish relationships. This is relevant when dealing with large datasets.

Now, let's add some data to the `files` table:
```sql
INSERT INTO files (filename, experiment_id, run_number, total_events, data_type)
VALUES
  ("lhcb.myfile.root", 1, 101, 1234, "data"),
  ("atlas.myfile.root", 2, 202, 5678, "mc"),
  ("cms.myfile.root", 3, 303, 9101, "data"),
  ("alice.myfile.root", 4, 404, 1123, "mc"),
  ("belle2.myfile.root", 5, 505, 3141, "data"),
  ("alice.myfile2.root", 4, 404, 1124, "mc"),
  ("alps.myfile.root", 9, 900, 1000, "data");
```

Confirm the data in the `files` table:
```sql
SELECT * FROM files;
```
```text
+----+--------------------+---------------+------------+--------------+-----------+
| id | filename           | experiment_id | run_number | total_events | data_type |
+----+--------------------+---------------+------------+--------------+-----------+
|  1 | lhcb.myfile.root   |             1 |        101 |         1234 | data      |
|  2 | atlas.myfile.root  |             2 |        202 |         5678 | mc        |
|  3 | cms.myfile.root    |             3 |        303 |         9101 | data      |
|  4 | alice.myfile.root  |             4 |        404 |         1123 | mc        |
|  5 | belle2.myfile.root |             5 |        505 |         3141 | data      |
|  7 | alice.myfile2.root |             4 |        404 |         1124 | mc        |
+----+--------------------+---------------+------------+--------------+-----------+
```


## SQL JOIN

In SQL, JOIN operations are used to combine rows from two or more tables based on a common column. Different types of
JOINs can be used depending on your needs.

We will explore various JOIN types using the `files` and `experiments` tables.

### INNER JOIN
An *INNER JOIN* returns records that have matching values in both tables.

Example: We want to get the `filename` and `experiment_name` for each dataset if there's a corresponding experiment.
We'll join on the *experiment_id* column of the `files` table to find the matching records in the `experiments` table.

```sql
SELECT f.filename, e.experiment_name
FROM files f
INNER JOIN experiments e
ON f.experiment_id = e.id;
```
```text
+--------------------+-----------------+
| filename           | experiment_name |
+--------------------+-----------------+
| lhcb.myfile.root   | LHCb            |
| atlas.myfile.root  | ATLAS           |
| cms.myfile.root    | CMS             |
| alice.myfile.root  | ALICE           |
| belle2.myfile.root | Belle2          |
| alice.myfile2.root | ALICE           |
+--------------------+-----------------+
```

One more example:
```sql
SELECT f.filename, f.data_type, e.experiment_name, e.collision_type
FROM files f
INNER JOIN experiments e
ON f.experiment_id = e.id;
```

How does the output look like?

Note: *INNER JOIN* returns only the rows that have matching values in both tables.

### LEFT JOIN

A *LEFT JOIN* returns all records from the left table, and the matched records from the right table. The result is *NULL* from the right side if there is no match.

Example:
```sql
SELECT f.filename, e.experiment_name, e.collision_type
FROM files f
LEFT JOIN experiments e
ON f.experiment_id = e.id;
```
```text
+--------------------+-----------------+----------------+
| filename           | experiment_name | collision_type |
+--------------------+-----------------+----------------+
| lhcb.myfile.root   | LHCb            | pp             |
| atlas.myfile.root  | ATLAS           | pp             |
| cms.myfile.root    | CMS             | pp             |
| alice.myfile.root  | ALICE           | PbPb           |
| belle2.myfile.root | Belle2          | e+e-           |
| alice.myfile2.root | ALICE           | PbPb           |
| alps.myfile.root   | NULL            | NULL           |
+--------------------+-----------------+----------------+
```

Notice that:
  - Returns all rows from the left table (`files`), including unmatched rows.
  - Shows *NULL* for columns from the right table (`experiments`) if there is no match.

In this case, since we have no entry for the experiment ALPS, the result is NULL.


### RIGHT JOIN
A *RIGHT JOIN* works as you would expect: returns all records from the right table, and the matched records from the left table. The result is *NULL* from the left side when there is no match.

Example:
```sql
SELECT e.experiment_name, f.filename
FROM files f
RIGHT JOIN experiments e
ON f.experiment_id = e.id;
```
```text
+-----------------+--------------------+
| experiment_name | filename           |
+-----------------+--------------------+
| ALICE           | alice.myfile2.root |
| ALICE           | alice.myfile.root  |
| ATLAS           | atlas.myfile.root  |
| BaBar           | NULL               |
| Belle2          | belle2.myfile.root |
| CMS             | cms.myfile.root    |
| LHCb            | lhcb.myfile.root   |
+-----------------+--------------------+
```

You can notice:
  - Returns all rows from the right table (`experiments`), including unmatched rows.
  - Shows `NULL` for columns from the left table `files` if there is no match.


### UNION

A *FULL OUTER JOIN* returns all records when there is a match in either left or right table. This type of join is not directly supported in MySQL, but you can achieve it using *UNION*.

Example:
```sql
SELECT f.filename, e.experiment_name, e.collision_type
FROM files f
LEFT JOIN experiments e
ON f.experiment_id = e.id
UNION
SELECT f.filename, e.experiment_name, e.collision_type
FROM experiments e
LEFT JOIN files f
ON f.experiment_id = e.id;
```
```text
+--------------------+-----------------+----------------+
| filename           | experiment_name | collision_type |
+--------------------+-----------------+----------------+
| lhcb.myfile.root   | LHCb            | pp             |
| atlas.myfile.root  | ATLAS           | pp             |
| cms.myfile.root    | CMS             | pp             |
| alice.myfile.root  | ALICE           | PbPb           |
| belle2.myfile.root | Belle2          | e+e-           |
| alice.myfile2.root | ALICE           | PbPb           |
| alps.myfile.root   | NULL            | NULL           |
| NULL               | BaBar           | e+e-           |
+--------------------+-----------------+----------------+
```

Note: The used `SELECT` statements have the same columns to use `UNION` (try with different columns and see what happens).


## Foreign Keys

A foreign key is a column or a group of columns in a table that uniquely identifies a row in another table. The table
containing the foreign key is called the child table, and the table containing the candidate key is called the referenced or parent table.

A foreign key is not required to perform JOIN operations, but it is a good practice to use them to maintain data integrity
and enforce referential constraints.

Let's quickly exemplify how to create a foreign key in MySQL using the *experiments* and *files* tables.

```sql
ALTER TABLE files
ADD CONSTRAINT fk_experiment_id
FOREIGN KEY (experiment_id)
REFERENCES experiments(id);
```
```text
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`all_experiments_data`.`#sql-1_9`, CONSTRAINT `fk_experiment_id` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`))
```

:::::{admonition} Why it didn't work?
:class: challenge

What prevents to create a foreign key? How to fix the error message above?

::::{admonition} Solution
:class: dropdown

The error message indicates that there is a constraint violation. This is because we have a row in the `files` table with an `experiment_id` that does not exist in the `experiments` table.
In this case, we have a row with `experiment_id = 9` in the `files` table, but there is no corresponding `id` in the `experiments` table.

Let's add the information of the experiment ALPS

```sql
INSERT INTO experiments (experiment_name, laboratory, collision_type, start_year)
VALUES
("ALPS II", "DESY", "N/A", 2011);
```

And set the proper `experiment_id` (in this case is id = 7, confirm with `SELECT * FROM experiments`).
```sql
UPDATE files
SET experiment_id = 7
WHERE filename = "alps.myfile.root";
```

Now, try again to create the foreign key as before.
::::
:::::

:::{admonition} Key Points
- JOIN operations are used to combine rows from two or more tables based on a common column.
- Foreign keys are used to maintain data integrity and enforce references.
:::
