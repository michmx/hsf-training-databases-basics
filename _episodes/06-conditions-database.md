---
title: "Introduction to Conditions Databases in HEP"
teaching: 1.5 hours
exercises: 2
---

:::{admonition} Questions
- What are the key objects in a Conditions Database and how are they related?
- How can you use SQLAlchemy to model and query a simple Conditions Database?
:::

:::{admonition} Objectives
- Understand the role of Conditions Databases in high-energy physics.
- Learn the key concepts: Global Tags, PayloadTypes, Payloads, and IOVs.
- Model relationships between these objects using SQLAlchemy.
- Perform basic queries to retrieve conditions data efficiently.
:::

# Lesson: Introduction to Conditions Databases in HEP

## Introduction

In high-energy physics, conditions databases (CDBs) play a critical role in managing non-event data. This includes calibration constants, alignment parameters, and detector conditions, which evolve over time. These databases ensure that analysis software can access the correct calibration and alignment data corresponding to the detector's state at any given time, enabling accurate physics measurements.

The key objects in CDBs include **Global Tags**, **Payloads**, and **Interval of Validity (IOVs)**. Together, these elements create a framework for managing and retrieving time-dependent data.

## Key Concepts

### Payloads

A **Payload** contains the actual conditions data, such as calibration constants or alignment parameters. Typically, a payload is stored as a file on the filesystem, accessible through a specific path and filename or URL. The CDB manages only the metadata associated with these files, rather than the files themselves. In the CDB, the Payload object is essentially the URL pointing to the file's location, enabling efficient retrieval without directly handling the data.

### PayloadTypes

A **PayloadType** represents a classification for grouping related payloads that belong to the same category of conditions, such as alignment parameters, calibration constants, or detector settings. By organizing payloads under a common type, the CDB simplifies data retrieval and management.

This grouping ensures that, in most cases, only one payload per system is required for a specific query. For example, when retrieving alignment data for a particular detector component, you typically need data corresponding to a specific run number. The system can efficiently filter and return only the relevant payload for that time range, rather than fetching all payloads across all time intervals. This approach enhances consistency, optimizes performance, and simplifies the management of multiple payloads for similar conditions.

### Interval of Validity (IOV)

An **IOV** defines the time range during which a particular payload is valid. It is typically specified in terms of run numbers, timestamps, or lumiblocks, ensuring that the correct data is applied for a given detector state.

### Global Tags

A **Global Tag** is a label that identifies a consistent set of conditions data. It provides a snapshot of the detector state by pointing to specific versions of payloads for different time intervals. Global Tags simplify data retrieval by offering a single entry point for accessing coherent sets of conditions.

## Connections Between Objects

- A **Global Tag** serves as a grouping mechanism that maps to multiple payloads, which are organized by **PayloadType**. Each **PayloadType** groups related payloads (e.g., alignment or calibration constants) to simplify data retrieval.
- Each **Payload** represents a specific piece of conditions data and is valid for the **Interval of Validity (IOV)** associated with it. This ensures that the correct payload is applied for a given run or timestamp.
- During data processing, the CDB retrieves the appropriate payload by matching the **IOV** to the required run or timestamp, ensuring consistency and accuracy.

:::{figure} ../fig/cdb_diagram.png
:alt: CDB schema diagram
:width: 250px

CDB schema diagram
:::

For simplification, in the following example, we work with three objects:

1. **GlobalTag**: Contains a collection of **PayloadTypes**. In the diagram, this relationship is depicted as a 1-to-many connection, indicating that a single **GlobalTag** can aggregate multiple **PayloadTypes**, each representing a distinct category of conditions. This relationship is implemented in the database by having a foreign key in the **PayloadType** table referencing the **GlobalTag** ID.

2. **PayloadType**: Groups related payloads of the same type (e.g., alignment, calibration) and organizes them for specific conditions. A single **PayloadType** can have multiple **PayloadIOVs** linked to it, representing the actual data for different validity ranges. This relationship is similarly implemented using a foreign key in the **PayloadIOV** table referencing the **PayloadType** ID.

3. **PayloadIOV**: Combines the payload metadata with its validity range (IOV) and provides a URL pointing to the payload file. The system assumes that conditions of the same type may change over time with new IOVs. As a result, the URL pointing to the payload file updates to reflect the new payload, ensuring the correct data is used for processing.

> ### How to Read the Diagram
>
> The diagram visually represents the relationships between these objects. Each block corresponds to a database table, and the connections between them indicate the nature of their relationships:
> - The relationship between **GlobalTag** and **PayloadType**  shows that a single **GlobalTag** can group multiple **PayloadTypes**, but each **PayloadType** is associated with exactly one **GlobalTag** (1-to-many).
> - Similarly, the relationship between **PayloadType** and **PayloadIOV**  indicates that a single **PayloadType** can group multiple **PayloadIOVs**, but each **PayloadIOV** is tied to one specific **PayloadType**.
>
> These relationships are implemented via foreign keys:
> - The **PayloadType** table includes a foreign key to the **GlobalTag** table.
> - The **PayloadIOV** table includes a foreign key to the **PayloadType** table.
>
> This structure ensures that data integrity is maintained and that each object is correctly linked in the database schema.

## Exercises

1. **Exercise 1: Reproducing the Example**
   - Follow the provided example in the next section to define the relationships between `GlobalTag`, `PayloadType`, and `PayloadIOV` using SQLAlchemy.
   - Recreate the database structure, populate it with the example data for alignment and calibration conditions, and verify that the tables and relationships are correctly implemented.

2. **Exercise 2: Querying Conditions Data**
   - Write a query to retrieve for a specific `GlobalTag` the names of the `PayloadTypes` and summary number of `PayloadIOV`'s per type.

These exercises reinforce the concepts and demonstrate how Conditions Databases support real-world data management in high-energy physics experiments.

## Conditions Database Example Using SQLAlchemy

This example demonstrates how to create a simple CDB using SQLAlchemy in Python.
We will define three tables: `GlobalTag`, `PayloadType`, and `PayloadIOV`, and establish relationships
between them. We will then add example data and query the database to retrieve specific entries.

### Imports
First, we import the necessary modules from SQLAlchemy.

```python
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey
from sqlalchemy.orm import declarative_base, sessionmaker, relationship
```

### Define ORM Models
We define our ORM models: `GlobalTag`, `PayloadType`, and `PayloadIOV`, along with the necessary relationships.
```python
from sqlalchemy.sql import func, and_
```
## Database Connection
Next, we define the MySQL database connection URL and create an SQLAlchemy engine, session, and declarative base.

```python
# Define the MySQL database connection URL
db_url = "mysql+pymysql://root:pass@localhost:3306/cdb"

# Create an SQLAlchemy engine
engine = create_engine(db_url)
Session = sessionmaker(bind=engine)
session = Session()
Base = declarative_base()
```
### Define Tables
We define all the tables in the database.

```python
class GlobalTag(Base):
    __tablename__ = "GlobalTag"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), unique=True, nullable=False)

    # Relationship to PayloadType
    payload_types = relationship("PayloadType", back_populates="global_tag")


class PayloadType(Base):
    __tablename__ = "PayloadType"
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), unique=True, nullable=False)
    global_tag_id = Column(Integer, ForeignKey("GlobalTag.id"))

    # Relationship to GlobalTag and PayloadIOV
    global_tag = relationship("GlobalTag", back_populates="payload_types")
    payload_iovs = relationship("PayloadIOV", back_populates="payload_type")


class PayloadIOV(Base):
    __tablename__ = "PayloadIOV"
    id = Column(Integer, primary_key=True, autoincrement=True)
    payload_url = Column(String(255), nullable=False)
    iov = Column(Integer, nullable=False)
    payload_type_id = Column(Integer, ForeignKey("PayloadType.id"))

    # Relationship to PayloadType
    payload_type = relationship("PayloadType", back_populates="payload_iovs")
```
### Create Tables
We create all the tables in the database.

```python
# Create all tables in the database
Base.metadata.drop_all(engine)
Base.metadata.create_all(engine)
```
### Adding Example Data
We add some example data to the database for `GlobalTag`, `PayloadType`, and `PayloadIOV`.

```python
# Adding example data
global_tag = GlobalTag(name="Conditions")
session.add(global_tag)

calib_payload_type = PayloadType(name="Calibrations", global_tag=global_tag)
align_payload_type = PayloadType(name="Alignment", global_tag=global_tag)

session.add(calib_payload_type)
session.add(align_payload_type)

calib_payload_iovs = [
    PayloadIOV(
        payload_url="http://example.com/calib_v1.root",
        iov=1,
        payload_type=calib_payload_type,
    ),
    PayloadIOV(
        payload_url="http://example.com/calib_v2.root",
        iov=2,
        payload_type=calib_payload_type,
    ),
    PayloadIOV(
        payload_url="http://example.com/calib_v3.root",
        iov=3,
        payload_type=calib_payload_type,
    ),
]

align_payload_iovs = [
    PayloadIOV(
        payload_url="http://example.com/align_v1.root",
        iov=1,
        payload_type=align_payload_type,
    ),
    PayloadIOV(
        payload_url="http://example.com/align_v2.root",
        iov=3,
        payload_type=align_payload_type,
    ),
]

session.add_all(calib_payload_iovs)
session.add_all(align_payload_iovs)
session.commit()
```
### Query the Database
Finally, we query the database to get the latest `PayloadIOV` entries for each `PayloadType` for a specific `GlobalTag` and IOV.

```python
# Query to get the last PayloadIOV entries for each PayloadType for a specific GlobalTag and IOV
requested_iov = 2
requested_gt = "Conditions"

# Subquery to find the maximum IOV for each PayloadType
subquery = (
    session.query(PayloadIOV.payload_type_id, func.max(PayloadIOV.iov).label("max_iov"))
    .join(PayloadType, PayloadType.id == PayloadIOV.payload_type_id)
    .join(GlobalTag, GlobalTag.id == PayloadType.global_tag_id)
    .filter(GlobalTag.name == requested_gt, PayloadIOV.iov <= requested_iov)
    .group_by(PayloadIOV.payload_type_id)
    .subquery()
)

# Main query to get the latest PayloadIOV for each PayloadType
query = (
    session.query(
        GlobalTag.name.label("global_tag_name"),
        PayloadType.name.label("payload_type_name"),
        PayloadIOV.payload_url,
        subquery.c.max_iov,
    )
    .join(PayloadType, GlobalTag.id == PayloadType.global_tag_id)
    .join(subquery, subquery.c.payload_type_id == PayloadType.id)
    .join(
        PayloadIOV,
        and_(
            PayloadType.id == PayloadIOV.payload_type_id,
            subquery.c.max_iov == PayloadIOV.iov,
        ),
    )
    .filter(GlobalTag.name == requested_gt)
    .order_by(PayloadType.name)
).all()

for global_tag_name, payload_type_name, payload_url, max_iov in query:
    print(
        f"GlobalTag: {global_tag_name}, PayloadType: {payload_type_name}, PayloadIOV URL: {payload_url}, IOV: {max_iov}"
    )
```

    GlobalTag: Conditions, PayloadType: Calibrations, PayloadIOV URL: http://example.com/calib_v2.root, IOV: 2
    GlobalTag: Conditions, PayloadType: Alignment, PayloadIOV URL: http://example.com/align_v1.root, IOV: 1

:::{admonition} Key Points
- Conditions Databases store metadata for time-dependent data like alignment and calibration.
- Global Tags group related PayloadTypes, which contain Payloads valid for specific IOVs.
:::
