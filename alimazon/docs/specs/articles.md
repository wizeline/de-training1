# Articles Specification

Description

## Format

**Gzipped CSV without headers and the character `|` as separator**

## Data model

Name                  | CSV Type   | Type   | Required   | Notes
:---------------------|:-----------|:-------|:-----------|:------------------------------------
article_id            | String     | String | Yes        | [UUIDv4]
category              | String     | String | No         | Must be a [valid category] or `null`
article_description   | String     | String | No         | No more than 200 characters
price_per_unit        | Float      | Float  | Yes        | Larger than zero

## Sample

```text
1c6df850-57ed-4312-bc06-e7f1bc2c5568|food||100.30
3f4fe127-dc5f-4034-81ae-7f29d19dd09a||Awesome object|12
```

[UUIDv4]: https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random)
[valid category]: /appendixes/categories
