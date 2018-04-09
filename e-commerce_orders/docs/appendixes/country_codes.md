# Country codes

The valid country codes are the ones defined by the [ISO 3166-1 alpha-3]
specification.

A pipe separated values file (`|`) with the valid country codes can be found
[here](/resources/country_codes.csv).

To get a updated list of country codes use this python code:
```python
import requests
from bs4 import BeautifulSoup
response = requests.get('https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3')
soup = BeautifulSoup(response.text, 'html.parser')
with open('country_codes.csv', 'w') as ofile:
    ofile.write('code|name\n')
    ofile.write('\n'.join('|'.join(c.text for c in r.find_all('td'))
                          for t in soup.find('table').find_all('table')
                          for r in t.find_all('tr')))
```

[ISO 3166-1 alpha-3]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3
