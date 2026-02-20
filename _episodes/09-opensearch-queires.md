---
title: "Intro to NoSQL and Opensearch Queries"
teaching: x
exercises: 6
---

:::{admonition} Questions
- What is NoSQL database and Opensearch?
- How to perform indexing in Opensearch?
- How to query and filter records in opensearch?
:::

:::{admonition} Objectives
- Understand the basic structure of Opensearch queries.
- Learn how to create and manage indices in Opensearch.
- Practice using different types of queries such as term queries, range queries, and compound queries.
- Gain familiarity with updating and deleting documents in Opensearch.
:::

# NOSQL Databases
NSQL databases diverge from the traditional table-based structure of RDMS and are designed to handle unstructured or
semi-structured data. They offer flexibility in data modeling and storage, supporting various data formats. Types of NoSQL database are :

| NoSQL Database Type       | Description                                                  | Examples                                     |
| ------------------------- | ------------------------------------------------------------ | -------------------------------------------- |
| Key-Value Store           | Stores data as key-value pairs. Simple and efficient for basic storage and retrieval operations. | Redis, DynamoDB, Riak                        |
| Document-Oriented         | Stores data in flexible JSON-like documents, allowing nested structures and complex data modeling. | MongoDB, Couchbase, CouchDB, OpenSearch, Elasticsearch                  |
| Column-Family Store       | Organizes data into columns rather than rows, suitable for analytical queries and data warehousing. | Apache Cassandra, HBase, ScyllaDB             |
| Graph Database            | Models data as nodes and edges, ideal for complex relationships and network analysis. | Neo4j, ArangoDB, OrientDB                      |
| Wide-Column Store         | Similar to column-family stores but optimized for wide rows and scalable columnar data storage. | Apache HBase, Apache Kudu, Google Bigtable     |

# Opensearch Databases
Opensearch is kind of NoSQL database which is document oriented. It stores data as JSON documents.
It is also a distributed search and analytics engine designed for scalability, real-time data processing, and full-text search capabilities.
It is often used for log analytics, monitoring, and exploring large volumes of structured and unstructured data.

In the following chapters, we will build a metadata search engine/database. We will exploit the functionality of OpenSearch to create a database where we can store files with their corresponding metadata, and look for the files that match metadata queries.

## Opensearch Queries
Lets explore fundamental Opensearch queries and concepts.
Opensearch provides powerful search capabilities. Here are some core Opensearch queries that you'll use:

- **Create an Index**: Create a new index.
- **Create a Mapping**: Define the data structure for your documents.
- **Index Documents**: Insert new documents into an index.
- **Search Documents**: Retrieve data from an index.
- **Update Documents**: Modify existing data in documents.
- **Delete Documents**: Remove documents from an index.

## Setting up
Make sure you have python in your system. Lets create a virtual environment.
Lets create a directory to work
```bash
mkdir myopenhsfwork && cd myopenhsfwork
```

Creating a virtual environment.
```bash
python -m venv venv
```

Activate the venv
```bash
source venv/bin/activate
```
Install install juyter and OpenSearch Python client (opensearch-py):
```bash
pip install jupyter
pip install opensearch-py
```

Then bring up Jupyter notebook. In your virtual enevironment run the following command.
```bash
jupyter-notebook
```
Now create a new python file and start running the subsequent commands.


## OpenSearch connection
We will use `Opensearch` from `opensearchpy` to establish connection/initialize the opensearh client. We need to specify the `OPENSEARCH_HOST` and `OPENSEARCH_PORT` which we have during setup i.e. `localhost` and `9200` respectively.
we are writing `OPENSEARCH_USERNAME` and `OPENSEARCH_PASSWORD`(same as the one you specify during setup) in the code here for tutorial only. Don't store credentials in code. And other options like `use_ssl` ( tells the OpenSearch client to use SSL/TLS (Secure Sockets Layer / Transport Layer Security) or not) and `verify_certs` (controls whether the OpenSearch client should verify the SSL certificate presented by the server) are set to false for tutorial. For production instance please set these parameter to True.

```python
from opensearchpy import OpenSearch

OPENSEARCH_HOST = "localhost"
OPENSEARCH_PORT = 9200
OPENSEARCH_USERNAME = "admin"
OPENSEARCH_PASSWORD = "<custom-admin-password>"
# Initialize an Opensearch client
es = OpenSearch(
    hosts=[{"host": OPENSEARCH_HOST, "port": OPENSEARCH_PORT}],
    http_auth=(OPENSEARCH_USERNAME, OPENSEARCH_PASSWORD),
    use_ssl=True,
    verify_certs=False,
)
```

## Create an index
Index is a logical namespace that holds a collection of documents. It defines the schema or structure of the documents it contains, including the fields and their data types.
Mapping refers to the definition of how fields and data types are structured within documents stored in an index. It defines the schema or blueprint for documents, specifying the characteristics of each field such as data type, indexing options, analysis settings, and more.
If no mapping is provided opensearch index it by itself.
We will define mapping for the metadata attributes. For string we have two data type option. "keyword" type is used for exact matching and filtering and "text" type is used for full-text search and analysis.

```python
index_name = "metadata"
# Define mappings for the index
mapping = {
    "properties": {
        "filename": {"type": "text"},
        "run_number": {"type": "integer"},
        "total_event": {"type": "integer"},
        "collision_type": {"type": "keyword"},
        "data_type": {"type": "keyword"},
        "collision_energy": {"type": "integer"},
        "description": {"type": "text", "analyzer": "standard"},
    }
}
# define setting of index
index_body = {"settings": {"index": {"number_of_shards": 1}}, "mappings": mapping}
# create the index
es.indices.create(index=index_name, body=index_body)

# check if the index exists
exists = es.indices.exists(index=index_name)
if exists:
    print("Successfully created index %s" % index_name)
```

## Index documents
we will index four documents into the "metadata" index. Each document represents a dataset with various fields like filename, run number, total events, collision type, data type, collision energy, and description.

The `_op_type` parameter in the bulk indexing operation specifies the operation type for each document. In this case, we're using  "create", which creates new documents only if it doesn't already exist. If a document with the same ID already exists, the "create" operation will fail. The other common operation type is "index", which overwrites document if it already exists.


```python
document1 = {
    "filename": "expx.myfile1.root",
    "run_number": 100,
    "total_event": 1112,
    "collision_type": "pp",
    "data_type": "data",
    "collision_energy": 250,
    "description": "This file is produced with L1 and L2 trigger.",
}
document2 = {
    "filename": "expx.myfile2.root",
    "run_number": 55,
    "total_event": 999,
    "collision_type": "pPb",
    "data_type": "mc",
    "collision_energy": 100,
    "description": "This file is produced without beam background.",
}
document3 = {
    "filename": "expx.myfile3.root",
    "run_number": 120,
    "total_event": 200,
    "collision_type": "PbPb",
    "data_type": "data",
    "collision_energy": 150,
    "description": "This file is produced without cherenkov detector",
}
document4 = {
    "filename": "expx.myfile4.root",
    "run_number": 360,
    "total_event": 1050,
    "collision_type": "pPb",
    "data_type": "mc",
    "collision_energy": 50,
    "description": "This file is produced with beam background",
}
documents = [document1, document2, document3, document4]
print("Total number of documents to be indexed indexed:  %s" % str(len(documents)))
```
We can do two type of indexing of documents. One is doing indexing one-by-one for each documents and another is doing bulk.
### Synchronous indexing

```python
for document in documents:
    _id = document["filename"]
    res = es.index(index=index_name, id=_id, body=document, op_type="create")
    print(res)
```

### Bulk Indexing
The bulk function from the OpenSearch Python client is used to perform bulk indexing operations, which is more efficient than indexing documents one by one.

```python
actions = []
duplicates = []
for document in documents:
    _id = document["filename"]

    # Check if document exists already
    if es.exists(index=index_name, id=_id):
        duplicates.append(document)
    else:
        actions.append(
            {
                "_index": index_name,
                "_id": _id,
                "_source": document,
                "_op_type": "create",
            }
        )
from opensearchpy import OpenSearch, helpers

res = helpers.bulk(es, actions)
print("Total Number of successfully indexed documents: %s" % (str(res[0])))
```


## Search for documents

### Term Level Query
A term level query is a type of query used to search for documents that contains an exact term or value in a specific field. It can be applied to keyword and integer data types.
This lets you search for document by single field (i.e. by single metadata in our case)

#### Term Query
Query structure looks like:
```JSON
{
    "query": {"term": {<field>: <value>}}
}
```

```python
search_query = {"query": {"term": {"collision_type": "pp"}}}
search_results = es.search(index=index_name, body=search_query)
for hit in search_results["hits"]["hits"]:
    print(hit["_source"])
```

:::::{admonition} Search for filename for documents with data_type `mc`.
:class: challenge

Retrieve and display filename

::::{admonition} Solution
:class: dropdown

```python
search_query = {"query": {"term": {"data_type": "mc"}}}
search_results = es.search(index=index_name, body=search_query)
for hit in search_results["hits"]["hits"]:
    print(hit["_source"]["filename"])
```

```text
expx.myfile2.root
expx.myfile4.root
```
::::
:::::

#### Range Query
It is also a term level query where we can apply a range of values to a field/metadata.
Query structure looks like:
```JSON
{
  "query": {
    "range": {
      <field>: {
        "gte": <lower_value>,
        "lte": <upper_value>
      }
    }
  }
}
```
Here we have choice of operator `gte` for greater than or equal to, `gt` for  greater than, `lte` for less than or equal to
and `lt` for less than.
Lets get the documents with `run_number` between 60 and 150 both inclusive.
```python
search_query = {"query": {"range": {"run_number": {"gte": 60, "lte": 150}}}}

search_results = es.search(index=index_name, body=search_query)
for hit in search_results["hits"]["hits"]:
    print(hit["_source"])
```

:::::{admonition} Search for filename for all the documents whose collision energy ranging from  100 to 200 (both exclusive) .
:class: challenge

Retrieve and display filename with range query

::::{admonition} Solution
:class: dropdown

```python
search_query = {"query": {"range": {"collision_energy": {"gt": 100, "lt": 200}}}}
search_results = es.search(index=index_name, body=search_query)
for hit in search_results["hits"]["hits"]:
    print(hit["_source"]["filename"])
```

```text
expx.myfile3.root
```
::::
:::::

#### Prefix Query
Another term level query is prefix query. As the name suggest it search for terms with sopecific prefix.
Format of this query is
```JSON
{
  "query": {
    "prefix": {
      <field>: {
        "value": <prefix>
        }
    }
  }
}
```
Lets get the documents which collision_type has prefix "p".
```python
search_query = {"query": {"prefix": {"collision_type": {"value": "p"}}}}
search_results = es.search(index=index_name, body=search_query)
for hit in search_results["hits"]["hits"]:
    print(hit["_source"])
```

### Compound Query
There different sub categories in this but we will here focus on `boolean` query. These queries allow you to combine multiple conditions to filter and retrieve documents that meet specific criteria.

#### Must Query
The must query combines multiple conditions and finds documents that match all specified criteria. This is equivalent to AND operator.
Let get the filename with `collision_type` as `pp` and `data_type` as `data`
```python
search_query = {
    "query": {
        "bool": {
            "must": [
                {"term": {"collision_type": "pp"}},
                {"term": {"data_type": "data"}},
            ]
        }
    }
}
search_results = es.search(index=index_name, body=search_query)
for hit in search_results["hits"]["hits"]:
    print(hit["_source"])
```

:::::{admonition} Search for filename for documents with data_type `data` and collision_energy `150` .
:class: challenge

Retrieve and display filename

::::{admonition} Solution
:class: dropdown

```python
search_query = {
    "query": {
        "bool": {
            "must": [
                {"term": {"data_type": "data"}},
                {"term": {"collision_energy": 150}},
            ]
        }
    }
}
search_results = es.search(index=index_name, body=search_query)
for hit in search_results["hits"]["hits"]:
    print(hit["_source"]["filename"])
```

```text
expx.myfile3.root
```
::::
:::::

#### Should Query
The should query searches for documents that match any of the specified conditions. This is equivalent to OR operator.
Let get the filename with `collission_type` as `pp` or `PbPb`.

```python
search_query = {
    "query": {
        "bool": {
            "should": [
                {"term": {"collision_type": "pp"}},
                {"term": {"collision_energy": 1127}},
            ]
        }
    }
}
search_results = es.search(index=index_name, body=search_query)
for hit in search_results["hits"]["hits"]:
    print(hit["_source"])
```

:::::{admonition} Search for filename for documents with run_number `55` or  collision_energy `150` .
:class: challenge

Retrieve and display filename

::::{admonition} Solution
:class: dropdown

```python
search_query = {
    "query": {
        "bool": {
            "should": [
                {"term": {"run_number": 55}},
                {"term": {"collision_energy": 150}},
            ]
        }
    }
}
search_results = es.search(index=index_name, body=search_query)
for hit in search_results["hits"]["hits"]:
    print(hit["_source"]["filename"])
```

```text
expx.myfile2.root
expx.myfile3.root
```
::::
:::::

#### Must Not Query
The must_not query excludes documents that match the specified condition. This is equivalent to NOT operator.
Let get the document that must not have collision_energy 250.
```python
search_query = {"query": {"bool": {"must_not": [{"term": {"collision_energy": 250}}]}}}
search_results = es.search(index=index_name, body=search_query)
for hit in search_results["hits"]["hits"]:
    print(hit["_source"])
```

:::::{admonition} Search for filename for all the documents that is not run_number `55` .
:class: challenge

Retrieve and display filename

::::{admonition} Solution
:class: dropdown

```python
search_query = {"query": {"bool": {"must_not": [{"term": {"run_number": 55}}]}}}
search_results = es.search(index=index_name, body=search_query)
for hit in search_results["hits"]["hits"]:
    print(hit["_source"]["filename"])
```

```text
expx.myfile1.root
expx.myfile3.root
expx.myfile4.root
```
::::
:::::

:::::{admonition} Search for filename for all the documents that must total_event greater than 200 and run_number greater than 50, should have collision_type as PbPb and must NOT have collision_energy 150. .
:class: challenge

Retrieve and display filename combing must, should and mustn't queries.

::::{admonition} Solution
:class: dropdown

```python
search_query = {
    "query": {
        "bool": {
            "must": [
                {"range": {"total_event": {"gt": 200}}},
                {"range": {"run_number": {"gt": 50}}},
            ],
            "should": {"term": {"collision_type": "PbPb"}},
            "must_not": {"term": {"collsiion_energy": 150}},
        }
    }
}
search_results = es.search(index=index_name, body=search_query)
for hit in search_results["hits"]["hits"]:
    print(hit["_source"]["filename"])
```

```text
expx.myfile1.root
expx.myfile2.root
expx.myfile4.root
```
::::
:::::


# Update a document by filename
Lets update a field of documents. We can update a specific document by its document ID (_id). It updates the "data_type" field of the document with the ID "expx.myfile1.root" to "deriv".

```python
_id = "expx.myfile1.root"
data = {"data_type": "deriv"}
es.update(index=index_name, id=_id, body={"doc": data})
```

# Delete a document by filename (-> _id)
Lets delete a document by its document ID (which is filename in our case)
```python
_id = "expx.myfile1.root"
es.delete(index=index_name, id=_id)
```

:::{admonition} Key Points
- Opensearch queries can be used to search, update, and delete documents in an Opensearch index.
- Indices in Opensearch define the structure and mapping of documents.
- Term queries match exact terms or values in a specific field.
- Range queries match documents within a specified range of values.
- Compound queries combine multiple conditions using boolean logic.
:::
