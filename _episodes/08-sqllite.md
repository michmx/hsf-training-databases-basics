---
title: "SQLite"
teaching: 60
exercises: 30
---

:::{admonition} Questions
- What is SQLite?
- How do I create an SQLite database?
:::

:::{admonition} Objectives
- Creating SQLite database
- Manipulating the database
:::


## Introduction to SQLite

Similar to MySQL, SQLite is a data manager system.
However, it is simpler, more flexible, and user-friendly than the former.
It implements a self-contained, serverless, zero-configuration, transactional SQL database engine.
SQLite is a preferred choice for the lightweight embedded databases.
The SQLite is available in both C and Python.
Here, we will proceed with the Python implementation.
It is user-friendly and comes with native Python 2.6+.

## Particle Data Group database

Create a working directory `hsf_sqlite_training`:

```bash
mkdir hsf_sqlite_training
cd hsf_sqlite_trainins
```

Let's create a database, that contains information from the Particle Data Group particle properties table.
First, we need to download the [particle properties table](https://pdg.lbl.gov/2023/mcdata/mass_width_2023.txt) from 2023.
You can do it manually and place it in your directory `hsf_sqlite_training` under the name `particle_table.txt` or if you use Python 3.7+ you can download the file automatically with a python module `requests`.


:::{note} Additional: using `requests`
To check the Python version on your machine do the following:

```bash
python3 --version
```

If the python version is higher than 3.7, you can install `requests` with `python -m pip install requests`.
Then you can create a script `download_particle_table.py` using your favorite code editor.

```python
import requests

particle_table = (
    "https://pdg.lbl.gov/2023/mcdata/mass_width_2023.txt"  # url of the file we want
)
response = requests.get(particle_table)  # getting the response from the url.

if response.status_code == 200:
    with open(
        "particle_table.txt", "wb"
    ) as file:  # writing the response into the txt file `particle_table.txt` locally
        file.write(response.content)
        print("Particle table is downloaded!")
else:
    print(
        "Failed to download the particle table."
    )  # it can be that the server is down or you have a typo in the url
```

Save the `download_particle_table.py` script and execute with `python3 download_particle_table.py`.
You should see the downloaded file `particle_table.txt` in your working directory.
:::

Open the `particle_table.txt` in your favorite text editor and study the data structure inside.
You should see:

```text
* MASSES, WIDTHS, AND MC ID NUMBERS FROM 2023 EDITION OF RPP
*
* The following values were generated on 31-May-2023 by the Berkeley Particle
* Data Group from the Review of Particle Physics database and are intended
* for use in Monte Carlo programs.
*
* For questions regarding distribution or content of this file, contact
* the Particle Data Group at pdg@lbl.gov.
*
* To process the images in this file:
* 1) ignore documentation lines that begin with an asterisk
* 2) in a FORTRAN program, process data lines with
*    FORMAT (BN, 4I8, 2(1X,E18.0, 1X,E8.0, 1X,E8.0), 1X,A21)
* 3)    column
*       1 -  8 \ Monte Carlo particle numbers as described in the "Review of
*       9 - 16 | Particle Physics". Charge states appear, as appropriate,
*      17 - 24 | from left-to-right in the order -, 0, +, ++.
*      25 - 32 /
*           33   blank
*      34 - 51   central value of the mass (double precision)
*           52   blank
*      53 - 60   positive error
*           61   blank
*      62 - 69   negative error
*           70   blank
*      71 - 88   central value of the width (double precision)
*           89   blank
*      90 - 97   positive error
*           98   blank
*      99 -106   negative error
*          107   blank
*     108 -128   particle name left-justified in the field and
*                charge states right-justified in the field.
*                This field is for ease of visual examination of the file and
*                should not be taken as a standardized presentation of
*                particle names.
*
* Particle ID(s)                  Mass  (GeV)       Errors (GeV)       Width (GeV)       Errors (GeV)      Name          Charges
      21                          0.E+00            +0.0E+00 -0.0E+00  0.E+00            +0.0E+00 -0.0E+00 g                   0
      22                          0.E+00            +0.0E+00 -0.0E+00  0.E+00            +0.0E+00 -0.0E+00 gamma               0
      24                          8.0377E+01        +1.2E-02 -1.2E-02  2.08E+00          +4.0E-02 -4.0E-02 W                   +
      23                          9.11876E+01       +2.1E-03 -2.1E-03  2.4955E+00        +2.3E-03 -2.3E-03 Z                   0
      25                          1.2525E+02        +1.7E-01 -1.7E-01  3.2E-03           +2.4E-03 -1.7E-03 H                   0
...
```

Now that we have obtained the particle table, let's build the SQlite database!

## Create the sqlite3 database

Firstly, we need to connect the sqlite3 database. In the file called `create_database.py` type in:

```python
import sqlite3

connection = sqlite3.connect(
    ":memory:"
)  # create or connect to database. Returns `Connection` object.

"""
Here one can perform operations on the data base, such as inserting, updating, deleting and selecting.
"""

connection.close()  # close database connection
```

The `Connection` object represents the database that, in this case, is stored in RAM using a special name `:memory:`.
If you want to save database locally replace `:memory:` with `<name>.db`.
If the file `<name>.db` already exists, `connect` will simply connect to the file, but if <name>.db` does not exist, `connect` will create a new file called `<name>.db`.
After all the database operations are finished, one needs to close connection using `close()` method of `Connection` object.

## Fill in the sqlite3 database

Secondly, we need to fill in the database with inputs from the `particle_table.txt` we have downloaded before.
To fill it we use SQL commands.
The SQL commands can be passed to using a `Cursor` object that can be created once the `Connection` object is created.
The `Cursor` object method `execute` takes in the SQL commands, which allows one to work with databases directly in SQL.
As the first step, we create the database table on the data structure of `particle_table.txt` and fill it in.
In `create_database.py`:

```python
import sqlite3
import pandas as pd

connection = sqlite3.connect(
    ":memory:"
)  # create or connect to database. Returns `Connection` object.
cursor = connection.cursor()
cursor.execute(
    "CREATE TABLE particles(id INTEGER, mass FLOAT, masserrlow FLOAT, masserrup FLOAT, width FLOAT, widtherrlow FLOAT, widtherr_up FLOAT,  name TEXT, charge INTEGER)"
)
cursor.execute(
    "INSERT INTO particles VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)",
    [21, 0.0e00, +0.0e00, -0.0e00, 0.0e00, +0.0e00, -0.0e00, "g", 0],
)  # gluon is filled in
connection.commit()  # commit to database
readout = pd.read_sql("SELECT * FROM particles", connection)  # read from database
print(readout)  # print the database
connection.close()  # close database connection
```

In the execute we have create a table called `particles` that contains a particle id (integer), mass (float), upper and lower mass errors (float), width (float), upper and lower width errors (float), particle name (TEXT) and charge (INTEGER).
Then, we fill in the information on gluon into our `particles` table.
After that we commit the changes to the database with the `Connection` object method `commit`.
To read the database, we use pandas `read_sql` function.
Now execute `create_database.py` with `python3 create_database.py`.
You should see:

```text
   id  mass  masserrlow  masserrup  width  widtherrlow  widtherr_up name charge
0  21   0.0         0.0        0.0    0.0          0.0          0.0    g      0
```

However, we would like to write down the entire list of the PDG particles into our database, not just a gluon!
For this, we will use `executemany`, instead of `execute`.
But before that, we need to prepare our input data in the `particle_table.txt`.
First of all the first 38 lines are taken with the header information that we do not need in our database, so we will skip these rows when copying.
Secondly, the sizes of columns are different in the `particle_table.txt`, but luckily the header specifies the exact sizes of the table columns:

```text
* 3)    column
*       1 -  8 \ Monte Carlo particle numbers as described in the "Review of
*       9 - 16 | Particle Physics". Charge states appear, as appropriate,
*      17 - 24 | from left-to-right in the order -, 0, +, ++.
*      25 - 32 /
*           33   blank
*      34 - 51   central value of the mass (double precision)
*           52   blank
*      53 - 60   positive error
*           61   blank
*      62 - 69   negative error
*           70   blank
*      71 - 88   central value of the width (double precision)
*           89   blank
*      90 - 97   positive error
*           98   blank
*      99 -106   negative error
*          107   blank
*     108 -128   particle name left-justified in the field and
*                charge states right-justified in the field.
*                This field is for ease of visual examination of the file and
*                should not be taken as a standardized presentation of
*                particle names.
```

You can check in your favorite text editor that the column definitions are correct.
Now `particle_table.txt` contains more precise information than what we want to save in our database.
For example, we are not writing down the state charges that are written in the column 9 - 32.
We would like to skip these columns.
Moreover, columns 108 - 208 contain both Name and Charge, but we would like to split it into two in our database.
We then can prepare data as follows:

```python
import pandas as pd

colspecs = [
    (0, 8),
    (33, 51),
    (52, 60),
    (61, 69),
    (70, 88),
    (89, 97),
    (98, 106),
    (107, 128),
]
column_names = [
    "id",
    "mass",
    "masserrup",
    "masserrdown",
    "width",
    "widtherrup",
    "widtherrdown",
    "namecharge",
]

# Read the file with the specified column widths
data = pd.read_fwf(
    "particle_table.txt", colspecs=colspecs, skiprows=38, names=column_names
)
data[["name", "charge"]] = data["namecharge"].str.extract(r"(.+?)\s+(\S+)$")
data = data.drop("namecharge", axis=1)
data = data.values.tolist()
```

`executemany` expects an iterable input.
Therefore we transform the pandas dataset to nested lists.
Now we can commit the entire particle table to the database.

```python
cursor.executemany("INSERT INTO particles VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)", data)
connection.commit()
readout = pd.read_sql("SELECT * FROM particles", connection)  # read from database
print(readout)  # print the database
connection.close()
```

Save the `create_database.py` and execute with `python3 create_database.py`, you should see the following output:

```text
       id       mass  masserrlow  masserrup         width   widtherrlow  \
0      21    0.00000     0.00000    0.00000  0.000000e+00  0.000000e+00
1      22    0.00000     0.00000    0.00000  0.000000e+00  0.000000e+00
2      24   80.37700     0.01200   -0.01200  2.080000e+00  4.000000e-02
3      23   91.18760     0.00210   -0.00210  2.495500e+00  2.300000e-03
4      25  125.25000     0.17000   -0.17000  3.200000e-03  2.400000e-03
..    ...        ...         ...        ...           ...           ...
224  5114    5.83474     0.00030   -0.00030  1.040000e-02  8.000000e-04
225  5224    5.83032     0.00027   -0.00027  9.400000e-03  5.000000e-04
226  5132    5.79700     0.00060   -0.00060  4.190000e-13  1.100000e-14
227  5232    5.79190     0.00050   -0.00050  4.450000e-13  9.000000e-15
228  5332    6.04520     0.00120   -0.00120  4.000000e-13  5.000000e-14

      widtherr_up       name charge
0    0.000000e+00          g      0
1    0.000000e+00      gamma      0
2   -4.000000e-02          W      +
3   -2.300000e-03          Z      0
4   -1.700000e-03          H      0
..            ...        ...    ...
224 -8.000000e-04  Sigma(b)*      -
225 -5.000000e-04  Sigma(b)*      +
226 -1.100000e-14      Xi(b)      -
227 -9.000000e-15      Xi(b)      0
228 -4.000000e-14   Omega(b)      -

[229 rows x 9 columns]
```

### Creating sql database directly from pandas dataframe

Pandas module has some useful methods for creating sql databases.
The example above can be replaced with

```python
import sqlite3
import pandas as pd

colspecs = [
    (0, 8),
    (33, 51),
    (52, 60),
    (61, 69),
    (70, 88),
    (89, 97),
    (98, 106),
    (107, 128),
]
column_names = [
    "id",
    "mass",
    "masserrup",
    "masserrdown",
    "width",
    "widtherrup",
    "widtherrdown",
    "namecharge",
]

data = pd.read_fwf(
    "particle_table.txt", colspecs=colspecs, skiprows=38, names=column_names
)
data[["name", "charge"]] = data["namecharge"].str.extract(r"(.+?)\s+(\S+)$")
data = data.drop("namecharge", axis=1)

connection = sqlite3.connect(":memory:")
data.to_sql("particles", connection, index=False)
connection.commit()
readout = pd.read_sql("SELECT * FROM particles", connection)  # read from database
print(readout)  # print the database
connection.close()
```

## Manipulating the database with SQLite

Before learning how to manipulate the database, let's first save the database created in the previous steps, not in RAM, but in the file called `particles.db`.
Replace the name of the database `:memory:` with `particles.db` and rerun `create_database.py`.
You should see `particles.db` in your directory.

:::::{admonition} Exercise
:class: challenge

Open the `particles.db` file and create a table that contains all neutral particles.

::::{admonition} Solution
:class: dropdown

```python
cursor.execute(
    "CREATE TABLE neutral_particles AS SELECT * from particles WHERE charge = '0'"
)
```
::::
:::::


:::::{admonition} Exercise
:class: challenge

Open the `particles.db` file and select only neutral leptons.

::::{admonition} Solution
:class: dropdown

```python
readout = pd.read_sql(
    "SELECT * FROM neutral_particles WHERE name LIKE 'nu%'", connection
)
```
::::
:::::

:::{admonition} Key Points
- For lightweight applications, use SQLite.
- Benefit from integration between sqlite3 and pandas.
:::
