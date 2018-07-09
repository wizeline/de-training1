"""
Read, write and copy files and iterables in JSONL format.
For details on the format, see: http://jsonlines.org/
"""
import contextlib
import gzip
import json

from itertools import chain
from gzip_util import is_gzipped_file


def read_from_files(filepaths, include_columns=None, exclude_columns=None):
    for filepath in filepaths:
        yield from read_from_file(filepath, include_columns, exclude_columns)


def read_from_file(filepath, include_columns=None, exclude_columns=None):
    with _open_file(filepath, mode='rt') as input:
        yield from read_from_iterable(input, include_columns, exclude_columns)


def read_from_iterable(iterable, include_columns=None, exclude_columns=None):
    iterable = iter(iterable)
    first_line = next(iterable, None)
    columns = _compute_include_columns(
        first_line, include_columns, exclude_columns)
    for row in chain([first_line], iterable):
        yield _select_columns(row, columns)


def copy_from_file(filepath, to_filepath, include_columns=None, exclude_columns=None):
    records = read_from_file(filepath, include_columns, exclude_columns)
    write_to_file(to_filepath, records)


def copy_from_files(filepaths, to_filepath, include_columns=None, exclude_columns=None):
    records = read_from_files(filepaths, include_columns, exclude_columns)
    write_to_file(to_filepath, records)


def write_to_file(filepath, iterable):
    with _open_file(filepath, mode='wt') as output:
        write_to_stream(output, iterable)


def write_to_stream(output_stream, iterable):
    for record in iterable:
        output_stream.write(json.dumps(record) + '\n')


def _select_columns(line, columns):
    record = _parse_line(line)
    return {key: record[key] for key in record if key in columns}


def _parse_line(line, ignore_errors=True):
    if not line and ignore_errors:
        return {}
    return json.loads(line)


def _compute_include_columns(line, include_columns, exclude_columns):
    all_columns = _parse_line(line).keys()
    exclude_columns = exclude_columns or []
    if not include_columns:
        include_columns = all_columns
    return list(set(include_columns) - set(exclude_columns))


@contextlib.contextmanager
def _open_file(input_filepath, mode, **kwargs):
    if is_gzipped_file(input_filepath):
        file = gzip.open(input_filepath, mode=mode, **kwargs)
    else:
        file = open(input_filepath, mode=mode, **kwargs)

    try:
        yield file
    finally:
        file.close()
