#!/usr/bin/env python
"""Generate random clients records"""
from bisect import bisect
from datetime import datetime, timedelta
from date_util import iso_string_to_date
from itertools import accumulate
from random import random
from uuid import uuid4
import math
import click
import json

import jsonl

_GENDERS = ('male', 'female', None)

def _weights(domain, default_weight='auto', **custom_weights):
    if isinstance(default_weight, str) and default_weight.lower() == 'auto':
        default_weight = (1.0-sum(custom_weights.values())) / (len(domain)-len(custom_weights))
    weights = [default_weight] * len(domain)
    for key, weight in custom_weights.items():
        if key.lower() == '_none':
            key = None
        try:
            weights[domain.index(key)] = weight
        except ValueError:
            raise ValueError('{} not found in the given domain.'.format(key))
    return tuple(weights)


def _sampler(choices, weights):
    cumulative_distribution = list(accumulate(weights))
    while True:
        weight = random() * cumulative_distribution[-1]
        yield choices[bisect(cumulative_distribution, weight)]


def _today_string():
    return datetime.today().strftime('%Y%m%dT%H%M%S')


def samples(samplers, context):
    for _ in range(context['max_rows_per_file']):
        yield {
            'id': str(uuid4()),
            'name': '{} {}'.format(next(samplers['names_sampler']),
                                   next(samplers['surnames_sampler'])),
            'gender': next(samplers['gender_sampler']),
            'country': next(samplers['codes_sampler']),
            'registration_date': (
                iso_string_to_date(context['start']) +
                timedelta(context['period_days'] * random())).isoformat()
        }


@click.command(context_settings=dict(help_option_names=['-h', '--help']))
@click.option(
    '-c', '--conf-file',
    help="""
    JSON format Client configuration file (e.g. client.conf). If it is not specified, default values will be used.
    """,
    type=str
)
def _main(conf_file='client_default.conf'):
    with open(conf_file) as json_conf_file:
        args = json.load(json_conf_file)

    with open(args['names_filename']) as names_file, \
            open(args['surnames_filename']) as surnames_file, \
            open(args['country_codes_filename']) as countries_file:
        names = [n.strip() for n in names_file.readlines()]
        surnames = [s.strip() for s in surnames_file.readlines()]
        codes = [c.strip().split('|')[0] for c in countries_file][1:]
        codes.append(None)

    samplers = {
        'names_sampler': _sampler(names, _weights(names)),
        'surnames_sampler': _sampler(surnames, _weights(surnames)),
        'gender_sampler': _sampler(_GENDERS, _weights(_GENDERS, _none=0.4)),
        'codes_sampler': _sampler(codes, _weights(codes, _none=0.3))
    }
    files_count = math.ceil(args['sample_size'] / args['max_rows_per_file'])
    for idx in range(files_count):
        rows = min(args['sample_size'] - args['max_rows_per_file'] * idx,
                   args['max_rows_per_file'])
        filename = '{}/part_{}_{:0>5}.jsonl.gz'.format(
            args['output_folder'],
            _today_string(),
            idx)
        jsonl.write_to_file(filename, samples(samplers, args), batch_size=rows)

if __name__ == '__main__':
    _main()
