# Orders Specification

## Description

All purchase orders are saved on the orders file, it has a reference to the
client and the purchased article through its ids; it also stores the timestamp
of the transaction, the number of items bought and the transaction total
amount.

## Format

**Gzipped Newline delimited JSON**

## Data model

Name         | JSON Type | Type        | Required | Notes
:------------|:----------|:------------|:---------|:-----
id           | String    | String      | Yes      | [UUIDv4]
selling_date | String    | TimeStamp   | Yes      | [ISO 8601]
client_id    | String    | String      | Yes      | [UUIDv4]
article_id   | String    | String      | Yes      | [UUIDv4]
quantity     | Integer   | Integer     | Yes      | Larger than 1
amount       | Float     | Float       | Yes      | Larger than 0

## Sample

```jsonl
{"timestamp": "2018-04-02T14:30:11.754633", "order_id": "c2f01f80-f1c3-419f-8471-dbd602ceedc4", "client_id": "ad5fa320-2b3a-42a7-b8b8-e53b151aa37f", "article_id": "1c6df850-57ed-4312-bc06-e7f1bc2c5568", "quantity": 1, "amount": 100.0}
{"timestamp": "2018-04-02T14:31:37.598480", "order_id": "18a1dfc4-a396-4266-87ad-9f1ef61beffc", "client_id": "1eb05fd0-f6e5-4879-bf39-bd0efaf02d0c", "article_id": "3f4fe127-dc5f-4034-81ae-7f29d19dd09a", "quantity": 12, "amount": 60.0}
```

[ISO 8601]: https://en.wikipedia.org/wiki/ISO_8601
[UUIDv4]: https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random)
