#!/usr/bin/env python
"""Get the latest list of country ISO 3166-1 alpha-3 codes from
Wikipedia"""
import requests

from bs4 import BeautifulSoup


def _main():
    response = requests.get('https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3')
    soup = BeautifulSoup(response.text, 'html.parser')
    with open('../docs/resources/country_codes.csv', 'w') as ofile:
        ofile.write('code|name\n')
        ofile.write('\n'.join('|'.join(c.text for c in r.find_all('td'))
                              for t in soup.find('table').find_all('table')
                              for r in t.find_all('tr')))


if __name__ == '__main__':
    _main()
