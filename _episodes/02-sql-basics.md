---
title: "MySQL Basics"
teaching: x
exercises: x
---

:::{admonition} Questions
- What are the core SQL commands you need to know to interact with a MySQL database?
- How do you create, update, and delete records in a MySQL database?
:::

:::{admonition} Objectives
- Understand the basic SQL commands used in MySQL.
- Learn how to create a database and tables in MySQL.
- Practice inserting, updating, and deleting records in a MySQL table.
:::


## SQL Commands

Here are some of the core SQL commands that you'll use in MySQL:

- `CREATE DATABASE`: Create a new database.
- `CREATE TABLE`: Create a new table.
- `INSERT INTO`: Insert new records into a table.
- `SELECT`: Retrieve data from a database.
- `UPDATE`: Modify existing data in a table.
- `DELETE`: Remove data from a table.

## Setting up a client for sql commands

In the terminal , run the following command to start the mysql client inside the Docker container:
```bash
docker exec -it myfirst-sqlserver bash -c "mysql -uroot -pmypassword"
```
Then you will see mysql command prompt as ``mysql>`` . All the sql command has to be typed in this command prompt.

:::{note} Using a MySQL client in the host
If you want to use a MySQL client in the host, you can install it (e.g., `mysql-client` package in Ubuntu)
and connect to the MySQL server running in the Docker container.
```bash
mysql -uroot -pmypassword -P 3306 --protocol=tcp
```
Notice that you need to specify the port number and the protocol to connect to the MySQL server running in the Docker container. See the
details of the Docker container hosting the MySQL server by running the command `docker ps`:
```bash
 docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                               NAMES
f86b66cc36bf   mysql     "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes   0.0.0.0:3306->3306/tcp, 33060/tcp   myfirst-sqlserver
```
:::

## Create a database.
We will first create a database named ``metadata`` in our mysql server.
```sql
CREATE DATABASE metadata;
```

:::{note} Case sensitivity in MySQL
In MySQL, SQL commands are case-insensitive. In other words, `CREATE DATABASE metadata` is the same as `create database metadata`.

However, it is a common practice to write SQL commands in uppercase
to distinguish them from table and column names, which are case-sensitive.
:::

You can list all the databases by using the command
```sql
SHOW DATABASES;
```
```text
+--------------------+
| Database           |
+--------------------+
| information_schema |
| metadata           |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
```

It shows that the database "metadata" is created.

:::{note} What are those other databases?
By default, MySQL comes with several databases that serve specific purposes. We will not go into details of each database,
but here is a brief overview:

- `mysql`: This database contains user account information and privileges
- `information_schema`: Contains metadata about all the other databases in the MySQL server
- `performance_schema`: Contains performance metrics for the MySQL server
- `sys`: Used for tuning and diagnosis use cases

You can read more about these databases in the [MySQL documentation](https://dev.mysql.com/doc/refman/8.0/en/information-schema.html).
For now it is not necessary to understand them in detail.
:::

To work with a specific database, you can use the USE command. For instance, to select the "metadata" database:
```sql
USE metadata;
```
```text
Database changed
```

## Creating a table

In SQL, the CREATE TABLE command is used to define a new table within a database. When creating a table, you specify the structure of the table, including the names of its columns, the data types for each column, and any constraints that ensure data integrity.

Here's a breakdown of the components within the command ``CREATE TABLE <table_name> (<colunmn_name> <data_type> <constraints>)``command:

- ``<table_name>``: This is the name of the table you're creating. It should be meaningful and reflect the type of data the table will store.

- ``<colunmn_name>``: you define the columns of the table.

- ``<data_type>``: This defines the kind of data that a column in your table can hold.      Choosing the right data type is crucial because it determines how the data will be stored and processed. Some example for  commonly used data types are:
    - INT (Integer): This data type is used for whole numbers.
    - VARCHAR(n) (Variable Character): This is used for storing variable-length character strings. The (n) represents the maximum length of the string, ensuring that the stored data does not exceed a specified limit.
    - TEXT: The TEXT data type is used for storing longer text or character data. It's suitable for holding textual content that can vary in length. Unlike VARCHAR, which has a specified maximum length, TEXT allows for storing larger and more flexible text content.

- ``<constraints>``: You can apply constraints to columns. Common constraints include:
    - NOT NULL: This ensures that a value must be provided for the column in every row.
    - UNIQUE: This guarantees that each value in the column is unique across all rows in the table.
    - PRIMARY KEY: Designates a column as the primary key, providing a unique identifier for each row.

By combining these elements, you define the table's structure and ensure data consistency and uniqueness. This structured approach to table creation is fundamental to relational databases and is a key part of database design. Keep in mind a database can have multiple tables.

Now, let's proceed with creating our "dataset" table in "metadata" database.

```sql
CREATE TABLE dataset (
    id INT AUTO_INCREMENT PRIMARY KEY,
    filename VARCHAR(255) NOT NULL UNIQUE,
    run_number INT NOT NULL,
    total_event INT NOT NULL,
    collision_type TEXT,
    data_type TEXT,
    collision_energy INT NOT NULL
);
```

Notice we have defined `id` as the primary key with the `AUTO_INCREMENT` attribute.
This means that the `id` column will automatically generate a unique value for each new record added to the table.

The `PRIMARY KEY` means that the `id` column will be the unique identifier for each record in the table. Additionally,
a primary key enhances the performance of cross-referencing between tables (we will look at this in more detail in the next episode).

You can see the table and corresponding columns by using the command
```sql
DESCRIBE dataset;
```
```text
+------------------+--------------+------+-----+---------+----------------+
| Field            | Type         | Null | Key | Default | Extra          |
+------------------+--------------+------+-----+---------+----------------+
| id               | int          | NO   | PRI | NULL    | auto_increment |
| filename         | varchar(255) | NO   | UNI | NULL    |                |
| run_number       | int          | NO   |     | NULL    |                |
| total_event      | int          | NO   |     | NULL    |                |
| collision_type   | text         | YES  |     | NULL    |                |
| data_type        | text         | YES  |     | NULL    |                |
| collision_energy | int          | NO   |     | NULL    |                |
+------------------+--------------+------+-----+---------+----------------+
```

## INSERT record into table
You can use the INSERT INTO command to add records to a table. This command has structure ``INSERT INTO <table_name> (<column_name>) Values (<column_value>)``.
Here's an example of inserting data into the "dataset" table:
```sql
INSERT INTO dataset (filename, run_number, total_event, collision_type, data_type, collision_energy)
VALUES ("expx.myfile1.root", 100, 1112, "pp", "data", 11275);
```


```sql
INSERT INTO dataset (filename, run_number, total_event, collision_type, data_type, collision_energy)
VALUES ("expx.myfile2.root", 55, 999, "pPb", "mc", 1127);
```

## Search record in the table

The SELECT command allows you to retrieve records from a table. To retrieve all records from the "dataset" table, you can use:
```sql
SELECT * FROM dataset;
```
```text
mysql> SELECT * FROM dataset;
+----+-------------------+------------+-------------+----------------+-----------+------------------+
| id | filename          | run_number | total_event | collision_type | data_type | collision_energy |
+----+-------------------+------------+-------------+----------------+-----------+------------------+
|  1 | expx.myfile1.root |        100 |        1112 | pp             | data      |            11275 |
|  2 | expx.myfile2.root |         55 |         999 | pPb            | mc        |             1127 |
+----+-------------------+------------+-------------+----------------+-----------+------------------+
```
You can select specific columns by listing them after the SELECT statement:
```sql
SELECT filename FROM dataset;
```
```text
+-------------------+
| filename          |
+-------------------+
| expx.myfile1.root |
| expx.myfile2.root |
+-------------------+
```
2 rows in set (0.00 sec)

### Search with some condition
To filter data based on certain conditions, you can use the WHERE clause. This allows you to filter rows based on conditions that you specify. For example, to select filenames where the "collision_type" is 'pp':
```sql
SELECT filename FROM dataset WHERE collision_type='pp';
```
In addition you can use logical operators such as AND and OR to combine multiple conditions in the WHERE statement.
```sql
SELECT filename FROM dataset WHERE run_number > 50 AND collision_type='pp';
```

:::::{admonition} SELECT on different condition
:class: challenge

Get the filename of condition total_event > 1000 and data_type is "data".

::::{admonition} Solution
:class: dropdown

```sql
SELECT filename FROM dataset WHERE event_number > 1000 AND data_type='mc';
```

```text
+-------------------+
| filename          |
+-------------------+
| expx.myfile1.root |
+-------------------+
1 row in set (0.00 sec)
```
::::
:::::

## UPDATE

The UPDATE command is used to make changes to existing record.

For example, if you want to update the "collision_type" and "collision_energy" for a specific record, you can use:

```sql
UPDATE dataset
SET collision_type = 'PbPb', collision_energy = 300
WHERE filename = 'expx.myfile1.root';
```

:::::{admonition} Update on a condition
:class: challenge

update the total_event of file "expx.myfile2.root" to 800.

::::{admonition} Solution
:class: dropdown

```sql
UPDATE dataset
SET total_event = 800
WHERE filename = 'expx.myfile2.root';
```

```text
+-------------------+
| filename          |
+-------------------+
| expx.myfile1.root |
+-------------------+
1 row in set (0.00 sec)
```
::::
:::::

## DELETE

The DELETE command is used to remove a row from a table.

For example, to delete a record with a specific filename you can use:
```sql
DELETE FROM dataset
WHERE filename = 'expx.myfile2.root';
```

:::{note} Be careful with UPDATE and DELETE without WHERE!
Very important: if you omit the `WHERE` clause in an `UPDATE` or `DELETE` statement, you will update or delete ALL records in the table!

For example, the following command
```sql
DELETE FROM dataset;
```
will delete all records in the `dataset` table.

This can have unintended consequences, so be cautious when using these commands.
:::

:::{admonition} Key Points
- SQL commands are the building blocks for interacting with a MySQL database.
- Creating a database and tables is the first step in structuring your data.
- Inserting, updating, and deleting records allows you to manage data effectively.
:::
