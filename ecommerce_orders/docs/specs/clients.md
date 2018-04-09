# Clients Specification

Description

## Format

**Gzipped Newline delimited JSON**

## Data model

Name              | JSON Type | Type      | Required | Notes
:-----------------|:----------|:----------|:---------|:---------------------------------
client_id         | String    | String    | Yes      | [UUIDv4]
name              | String    | String    | Yes      | Less than 100 characters
gender            | String    | String    | No       | Either `male`, `female` or `null`
country           | String    | String    | No       | Valid [country code]
registration_date | String    | TimeStamp | Yes      |

## Sample

```jsonl
{"client_id": "ad5fa320-2b3a-42a7-b8b8-e53b151aa37f", "name": "Jonh Smith", "gender": "male", "country": "USA", "registration_date": "2018-01-01T00:00:00"}
{"client_id": "1eb05fd0-f6e5-4879-bf39-bd0efaf02d0c", "name": "Maria Perez", "registration_date": "2018-01-01T13:04:33"}
```

[UUIDv4]: https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random)
[country_codes]: /appendixes/country_codes
