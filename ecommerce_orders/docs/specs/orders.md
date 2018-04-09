# Orders Specification

Description

## Format

**Gzipped Newline delimited JSON**

## Data model

Name       | JSON Type | Type        | Required | Notes
:----------|:----------|:------------|:---------|:-----
timestamp  | String    | TimeStamp   | Yes      | [ISO 8601]
order_id   | String    | String      | Yes      | [UUIDv4]
client_id  | String    | String      | Yes      | [UUIDv4]
article_id | String    | String      | Yes      | [UUIDv4]
amount     | Integer   | Integer     | Yes      | Larger than 1

## Sample

```jsonl
{"timestamp": "2018-04-02T14:30:11.754633", "order_id": "c2f01f80-f1c3-419f-8471-dbd602ceedc4", "client_id": "ad5fa320-2b3a-42a7-b8b8-e53b151aa37f", "article_id": "1c6df850-57ed-4312-bc06-e7f1bc2c5568", "amount": 1}
{"timestamp": "2018-04-02T14:31:37.598480", "order_id": "18a1dfc4-a396-4266-87ad-9f1ef61beffc", "client_id": "1eb05fd0-f6e5-4879-bf39-bd0efaf02d0c", "article_id": "3f4fe127-dc5f-4034-81ae-7f29d19dd09a", "amount": 12}
```

[ISO 8601]: https://en.wikipedia.org/wiki/ISO_8601
[UUIDv4]: https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random)
