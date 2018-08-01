# Stock Purchase Orders Specification

## Description

Each row in this dataset contains a reference to the the purchased product id, a timestamp of the transaction, the number of items bought and the transaction total amount.

## Format

**gzipped newline delimited json**

## Data model

name         | json type | type        | required | notes
:------------|:----------|:------------|:---------|:-----
id           | string    | string      | yes      | [uuidv4]
timestamp    | string    | timestamp   | yes      | [iso 8601]
product_id   | string    | string      | yes      | [uuidv4]
quantity     | integer   | integer     | yes      | larger than 1
total        | float     | float       | yes      | larger than 0

## Sample

```jsonl
{"id": "c2f01f80-f1c3-419f-8471-dbd602ceedc4", "timestamp": "2018-04-02t14:30:11.754633", "product_id": "1c6df850-57ed-4312-bc06-e7f1bc2c5568", "quantity": 1, "total": 100.0}
{"id": "18a1dfc4-a396-4266-87ad-9f1ef61beffc", "timestamp": "2018-04-02t14:31:37.598480", "product_id": "3f4fe127-dc5f-4034-81ae-7f29d19dd09a", "quantity": 12, "total": 60.0}
```

[iso 8601]: https://en.wikipedia.org/wiki/iso_8601
[uuidv4]: https://en.wikipedia.org/wiki/universally_unique_identifier#version_4_(random)
