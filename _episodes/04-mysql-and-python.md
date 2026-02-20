---
title: "SQLAlchemy and MySQL: Exercises"
teaching: 5
exercises: 6
---

:::{admonition} Questions
- How to perform CRUD operations using SQLAlchemy?
- How to query and filter records in SQLAlchemy?
:::

:::{admonition} Objectives
- Practice inserting records into a MySQL database using SQLAlchemy.
- Perform queries and filtering on the dataset table.
- Update and delete records in the dataset table.
:::

## Why python with SQL?

SQL is a perfectly designed language to specify database operations in a declarative, record-centred way, but this very design makes it unfamiliar to programmers used to writing object-oriented, imperative or functional code. Worse, good performance in SQL can depend on the specifics of the database engine we're interacting with - MySQL, PostgreSQL and so on all have their own ideal performance approaches and extensions. Finally, it's easy to write inadvertently insecure SQL queries by forgetting to sanitise and quote inputs.
As a consequence, it's much nicer - and safer - for us to use an interface allowing us to write object-oriented, functional implementations of the data manipulation we want, and have the interface "convert" this into efficient SQL queries behind the scenes. As a bonus, the abstraction layer can easily be switched to point at different backend database with a simple config change, without us needing to tweak our (in this case, Python) code itself.

## sqlAlchemy
SQLAlchemy is a powerful library that provides a high-level interface for interacting with databases, making database operations more Pythonic and abstracting SQL commands.


## Lets create a new database for this chapter.
So as not to collide with database created in previous chapter, let's create a different database for this one called `metadata2`
In another terminal, run the following command
```bash
docker exec -it metadata bash -c "mysql -uroot -pmypassword"
```
Then you will see a mysql command prompt as ``mysql>`` . Use following command to create  a database named ``metadata2``.
```sql
CREATE DATABASE metadata2;
```

## Installation
Make sure you have python in your system. Let's create a virtual environment and install sqlAlchemy .
Lets create a directory to work
```bash
mkdir myhsfwork && cd myhsfwork
```

Creating a virtual environment.

```bash
python -m venv venv
```

Activate the venv
```bash
source venv/bin/activate
```

Now install sqlAlchemy and other dependencies.
```bash
pip install sqlalchemy
pip install cryptography
pip install pymysql
pip install juyter
```

## Bring up Jupyter notebook
For ease of testing we will use Jupyter notebook to run the following command.
In your virtual enevironment run the following command.
```bash
jupyter-notebook
```
Now, create a new python file, and use it for the subsequent commands.

## Setting Up the Database Connection:

SQLAlchemy facilitates database connections in Python by using an Engine, which acts as the interface between the application and the database. The Engine manages database communication, executing SQL commands, and transaction handling. It requires a connection URL to specify the database type, credentials, and other connection details, which allows SQLAranslate its functions to whatever database configuration we want to interact with. Sessions, managed by sessionmaker, handle interactions between the application and the database, allowing for transactions, queries, and data manipulation in a structured manner.

Let's import necessary things.
```python
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy import Column, Integer, String, Text
```

Now let's create a URL for our database connection.
We need the following URL components:
* Dialect: Specifies the type of database being used (e.g., MySQL, PostgreSQL, SQLite). We use mysql.
* Driver: Identifies the library or driver used to interact with the database (e.g., PyMySQL for MySQL). We will use pymysql
* Username and Password: Credentials for accessing the database.
* Hostname and Port: Address and port number where the database server is located.
* Database Name: Name of the specific database to connect to.

So, the URL structure is : `Dialect+driver://username:password@hostname:port/databaseName`
or, if you use Apptainer and a socket file is:  `Dialect+driver://username:password@localhost/databaseName?unix_socket=filePath`

And we create a engine using this db_url.
```python
# Define the MySQL database connection URL
db_url = "mysql+pymysql://root:mypassword@localhost:3306/metadata2"
# if using Apptainer uncomment the next line to define the URL using the socket file:
# db_url = "mysql+pymysql://root:mypassword@localhost/metadata2?unix_socket=/var/run/mysqld/mysql.sock"

# Create an SQLAlchemy engine
engine = create_engine(db_url)
```

## Session for each connection
sessionmaker is a factory function that creates a session factory in SQLAlchemy. Sessions are used to interact with a database in SQLAlchemy, providing a way to persist, retrieve, and manipulate data. sessionmaker generates a configurable factory for creating sessions, allowing you to customize settings such as autocommit behavior, autoflush, and more. Sessions obtained from the session factory represent a single "unit of work" with the database, encapsulating a series of operations that should be treated atomically.
Let's open a session that will be used to do DB operation from python to sql using the Engine that we created.

```python
Session = sessionmaker(bind=engine)
session = Session()
```

## Define a base for declarative class
Declarative Base is a factory function from SQLAlchemy that generates a base class for declarative data models. This base class allows you to define database tables as Python classes, making it easier to define models by mapping Python classes to database tables. The classes created with declarative_base() typically inherit from this base class, and they include table schema definitions as class attributes.

```python
Base = declarative_base()
```

## Define and Create a Table
Now we will define the table named `dataset2`.
# Define the dataset table
Here we have a column named `id` defined as an Integer type and serves as the primary key for the table. It auto-increments, meaning its value automatically increases for each new row added to the table.
We set `filename` column as unique so that there is no duplication of filename in the table.
The option `nullable` , if set to false then it must have a value.

```python
class Dataset(Base):
    __tablename__ = "dataset2"

    id = Column(Integer, primary_key=True, autoincrement=True)
    filename = Column(String(255), unique=True, nullable=False)
    run_number = Column(Integer, nullable=False)
    total_event = Column(Integer, nullable=False)
    collision_type = Column(Text)
    data_type = Column(Text)
    collision_energy = Column(Integer, nullable=False)
```
# create the table
The following code `Base.metadata.create_all(engine)` is an SQLAlchemy command that instructs the engine to create database tables based on the defined models (such as Dataset) mapped to SQLAlchemy classes (derived from Base) within the application. This command generates the corresponding SQL statements to create tables in the specified database (referenced by engine) based on the model definitions provided in the code.

```python
Base.metadata.create_all(engine)
```

## Insert record
Lets insert two records in to the Table.

```python
dataset1 = Dataset(
    filename="expx.myfile1.root",
    run_number=100,
    total_event=1112,
    collision_type="pp",
    data_type="data",
    collision_energy=11275,
)
dataset2 = Dataset(
    filename="expx.myfile2.root",
    run_number=55,
    total_event=999,
    collision_type="pPb",
    data_type="mc",
    collision_energy=1127,
)

session.add(dataset1)
session.add(dataset2)
session.commit()
```
session.commit() is a command that effectively saves the changes made within the session to the database. This action persists the changes permanently in the database, making the additions to the table permanent and visible for subsequent transactions.

## Search the database.
`session.query()`` is used to create a query object that represents a request for data from the database. In this case, session.query(Dataset.filename) selects the filename column from the Dataset table. The .all() method executes the query and retrieves all the values from the filename column, returning a list of results containing these values from the database - it's like "collect()" on iterator types, if you're familiar with those.

```python
# Query the filename column from the dataset table
results = session.query(Dataset.filename).all()

# Print the results
for result in results:
    print(result.filename)
```

:::::{admonition} Search on different column
:class: challenge

Retrieve and display all collision_type

::::{admonition} Solution
:class: dropdown

```python
results = session.query(Dataset.collison_type).all()
for result in results:
    print(result.collison_type)
```

```text
pp
pPb
```
::::
:::::

# Search the database with condition.
In SQLAlchemy, the filter() method is used within a query() to add conditions or criteria to the query. It narrows down the selection by applying specific constraints based on the given criteria.

```python
results1 = session.query(Dataset.filename).filter(Dataset.collision_type == "pp").all()
# Print the results for the first query
print("Filenames where collision_type is 'pp':")
for result in results1:
    print(result.filename)

results2 = (
    session.query(Dataset.filename)
    .filter(Dataset.run_number > 50, Dataset.collision_type == "pp")
    .all()
)
# Print the results for the second query
print("\nFilenames where run_number > 50 and collision_type is 'pp':")
for result in results2:
    print(result.filename)
```

:::::{admonition} Search using OR statement
:class: challenge

Retrieve and display filenames with "mc" data_type and collision_energy>1000

::::{admonition} Solution
:class: dropdown

```python
results = (
    session.query(Dataset.filename)
    .filter((Dataset.data_type == "mc") | (Dataset.collision_energy > 1000))
    .all()
)
for result in results:
    print(result.collison_type)
```

```text
expx.myfile1.root
expx.myfile2.root
```
::::
:::::

## Update the database
To update a record in a table, you begin by querying for the specific record or records you want to update using query(). The filter() method is used to specify the conditions for the selection. Once you have the record(s) to update, modify the attributes as needed. Finally, calling session.commit() saves the changes made to the database. This ensures that the modifications are persisted permanently.

```python
# Update a record in the table
record_to_update = (
    session.query(Dataset).filter(Dataset.filename == "expx.myfile1.root").first()
)
if record_to_update:
    record_to_update.collision_type = "PbPb"
    record_to_update.collision_energy = 300
    session.commit()
```

:::::{admonition} Update
:class: challenge

Update `run_number` to 1000 for record with data_type `mc`.

::::{admonition} Solution
:class: dropdown

```python
record_to_update = session.query(Dataset).filter(Dataset.data_type == "mc").first()
if record_to_update:
    record_to_update.run_number = 1000
    session.commit()
```
::::
:::::

## Delete the database
Basically the same, we need to first get the record to update using query and filter. Then delete the record and commit to see the changes.
```python
# Delete a record from the table
record_to_delete = (
    session.query(Dataset).filter(Dataset.filename == "expx.myfile2.root").first()
)
if record_to_delete:
    session.delete(record_to_delete)
    session.commit()
```
## Close the session
It's essential to close the session after you've finished working with it to release the resources associated with it, such as database connections and transactional resources. By closing the session, you ensure that these resources are properly released, preventing potential issues like resource leakage and maintaining good database connection management practices.

```python
session.close()
```

:::{admonition} Key Points
- CRUD operations in SQLAlchemy: Create, Read, Update, Delete.
- Querying and filtering records based on specific conditions.
:::
