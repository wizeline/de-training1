# Clients Specification

## Description

The clients dataset has all information related to the customers as of name, gender
, country of residence and signup day.

## Format

**Gzipped Newline delimited JSON**

## Data model

Name              | JSON Type | Type      | Required | Notes
:-----------------|:----------|:----------|:---------|:---------------------------------
id                | String    | String    | Yes      | [UUIDv4]
name              | String    | String    | Yes      | Less than 100 characters
gender            | String    | String    | No       | Either `male`, `female` or `null`
country           | String    | String    | No       | Valid [country code]
registration_date | String    | TimeStamp | Yes      | [ISO 8601]

## Sample

```jsonl
{"id": "ad5fa320-2b3a-42a7-b8b8-e53b151aa37f", "name": "Jonh Smith", "gender": "male", "country": "USA", "registration_date": "2018-01-01T00:00:00"}
{"id": "1eb05fd0-f6e5-4879-bf39-bd0efaf02d0c", "name": "Maria Perez", "registration_date": "2018-01-01T13:04:33"}
```

[ISO 8601]: https://en.wikipedia.org/wiki/ISO_8601
[UUIDv4]: https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random)
[country_codes]: /appendixes/country_codes
