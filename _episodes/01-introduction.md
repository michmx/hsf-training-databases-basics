---
title: "Introduction"
teaching: 60
exercises: 30
---

:::{admonition} Questions
- What is a database management system and why it is a good idea to use one?
- What are the differences between relational and non-relational databases?
:::

:::{admonition} Objectives
- Understand the concepts of a database management system
- Learn about common database management systems used in HEP and Nuclear Physics
:::

# What is a database?

A database is a collection of data stored in a computer system. For example:

* A database that contains information on members
of a collaboration, the institutions they belong to, and the publications they have authored
* Or a database that contains information on the files produced by an experiment: their path, size, the number of events they contain

The data is typically organized to model relevant characteristics of the information contained in the database.

Technically speaking, a database can be something as simple as a text file with data stored in a structured format like
comma-separated values. For example, you may want to track the files being produced by an experiment in a text file like this:
```
Filename,          size,  date,       number of events, energy
disk01/file1.root, 1.2GB, 2023-10-01, 12000,            13TeV
disk03/file2.root, 1.3GB, 2023-10-02, 14000,            13TeV
...
```
This is usually known as **metadata**: data about data. Having metadata catalogs is a common practice in HEP and Nuclear Physics.

In practice, this is not a reliable or efficient way to store (meta)data. For example, if you want to know how many files were produced
in a given date, you would have to read the entire file and count the number of lines that match the date you are interested in.
What if you have millions of files? That would be very slow!
Or if you want to know the total size of the files produced in a given date, you would have to read the entire file and sum
the sizes of the files that match the date you are interested in. Things get much worse when updates are needed, as
the information can get very easily corrupted. And what if multiple people need to constantly entry information? What a nightmare
to keep everything in sync!

:::{note} Data organization
When developing software, how do we organize data is a critical decision that has an effect on the performance
and scalability of the application.
:::

In practice, databases are managed by software called database management systems (DBMS). A DBMS is a computer software
application that interacts with the user, other applications, and the database itself to capture and analyze data.
A general-purpose DBMS is specialized to handle databases in a scalable and reliable way, provides mechanisms
when data is accessed concurrently, and ensures that the data is not corrupted.

From now on, in this module we will refer to a "database" as an alias for a DBMS.


# Relational Database

A relational database is a type of DBMS that organizes data into tables with rows and columns. Following with our example
above, it will look like this:
```text
+----+------------+----------+-----------+------------+-------------------+--------+
| id | filename   | disk     | size      | date       | number of events  | energy |
+----+------------+----------+-----------+------------+-------------------+--------+
| 1  | file1.root | disk01   | 1.2GB     | 2023-10-01 | 12000             | 13TeV  |
| 2  | file2.root | disk03   | 1.3GB     | 2023-10-02 | 14000             | 13TeV  |
| 3  | file3.root | disk01   | 1.1GB     | 2023-10-02 | 13000             | 13TeV  |
...
```

In a relational database, data manipulation is performed via Structured Query Language (SQL). You can use SQL to
 * Create an entry
 * Read entries
 * Update
 * Delete data

In computer programming, these functions are referred by the acronym [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete).

In SQL, an **attribute** usually refers to a column or field within a table. For example, in the table above, some of the attributes
are `filename`, `size`, `number of events`, and `energy`.

The database can have multiple tables, and the tables can be related to each other. For example, you can have a table with
the information about the files and another table with the information about the location where the files are stored:
```text
+----+----------+-----------+--------------------+
| id | disk     | capacity  | path               |
+----+----------+-----------+--------------------+
| 1  | disk01   | 100TB     | /fs01/exp/data01   |
| 2  | disk02   | 120TB     | /fs01/exp/data02   |
| 3  | disk03   | 150TB     | /fs01/exp/data03   |
...
```

We will look in detail how to create and manage tables in a relational database in the next episodes.

Examples of relational databases include MySQL, PostgreSQL, Oracle Database, and SQLite. In this training, we will focus
on MySQL and a brief introduction to SQLite.


The performance of a relational database is usually very good for
most use cases, and it is the most common type of database used in HEP and Nuclear Physics.


# NoSQL Databases

There are use cases where a relational database is not the best choice. If the data is unstructured or semi-structured,
like for example:

* In a database of files that require specific fields depending on the type of file. A "flat" ROOT file created by an analyst can have different metadata than a raw data file or an AOD file.
* A catalog of parts for a detector, where each part has different properties

Non-relational databases, also known as **NoSQL**, are databases that do not use the tabular schema of columns found in relational databases.
Instead, they use a storage model optimized for the specific requirements of the type of data being stored.
In other words, they don't have a fixed number attributes that each record must have and the schema is more flexible.

:::{note} Relational vs NoSQL databases
NoSQL databases have become very popular due to the flexibility they offer. However, many-to-one and many-to-many relationships are more easily represented in a relational database.
Which one to choose depends on the specific requirements and must be considered carefully.
:::

In the last part of this training module, we will discuss more in details NoSQL databases, and we will have a quick look
on [OpenSearch](https://opensearch.org/docs/), a distributed search engine used as a NoSQL database.

:::{admonition} Key Points
- A database management system (DBMS) is specialized on managing databases in a scalable and reliable way.
- A relational database organizes data into tables with rows and columns.
- A non-relational database does not use the tabular schema of columns found in relational databases, having a more flexible schema.
:::
