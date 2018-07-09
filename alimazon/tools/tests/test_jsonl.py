import pytest
import os
import os.path
from tempfile import NamedTemporaryFile

import sys
from pathlib import Path

from file_util import delete_file

import jsonl

# TODO: refactor to remove duplication in all tests below
# TODO: the following are just smoke tests; as we move tools like this to separate
#       packages, we should take care to test them more carefully and exhaustively

@pytest.fixture
def input_iterable():
    return [
        '{"id": 1, "name": "mark", "eligible": false}',
        '{"id": 2, "name": "franz", "eligible": true}',
        '{"id": 3, "name": "jansen", "eligible": true}',
    ]


def test_read_from_iterable(input_iterable):
    records = list(jsonl.read_from_iterable(input_iterable))

    assert len(records) == 3
    _assert_columns_count(records, 3)
    _assert_record_matches(records[0], id=1, name='mark', eligible=False)
    _assert_record_matches(records[1], id=2, name='franz', eligible=True)
    _assert_record_matches(records[2], id=3, name='jansen', eligible=True)


def test_read_from_iterable_including_columns(input_iterable):
    records = list(jsonl.read_from_iterable(
        input_iterable, include_columns=['id']))

    assert len(records) == 3
    _assert_columns_count(records, 1)
    _assert_record_matches(records[0], id=1)
    _assert_record_matches(records[1], id=2)
    _assert_record_matches(records[2], id=3)


def test_read_from_iterable_excluding_columns(input_iterable):
    records = list(jsonl.read_from_iterable(
        input_iterable, exclude_columns=['id']))

    assert len(records) == 3
    _assert_columns_count(records, 2)
    _assert_record_matches(records[0], name='mark', eligible=False)
    _assert_record_matches(records[1], name='franz', eligible=True)
    _assert_record_matches(records[2], name='jansen', eligible=True)


def test_read_from_iterable_including_and_excluding_columns(input_iterable):
    records = list(jsonl.read_from_iterable(input_iterable,
                                            include_columns=['id', 'eligible'],
                                            exclude_columns=['id']))

    assert len(records) == 3
    _assert_columns_count(records, 1)
    _assert_record_matches(records[0], eligible=False)
    _assert_record_matches(records[1], eligible=True)
    _assert_record_matches(records[2], eligible=True)


def test_read_from_file():
    records = list(jsonl.read_from_file(_here('test1.jsonl')))

    assert len(records) == 3
    _assert_columns_count(records, 3)
    _assert_record_matches(records[0], id=1, name='mark', eligible=False)
    _assert_record_matches(records[1], id=2, name='franz', eligible=True)
    _assert_record_matches(records[2], id=3, name='jansen', eligible=True)


def test_read_from_files():
    records = list(jsonl.read_from_files(
        [_here('test1.jsonl'), _here('test2.jsonl.gz')]))

    assert len(records) == 6
    _assert_columns_count(records, 3)
    _assert_record_matches(records[0], id=1, name='mark', eligible=False)
    _assert_record_matches(records[1], id=2, name='franz', eligible=True)
    _assert_record_matches(records[2], id=3, name='jansen', eligible=True)

    _assert_record_matches(records[3], id=4, name='antonio', eligible=True)
    _assert_record_matches(records[4], id=5, name='karl', eligible=False)
    _assert_record_matches(records[5], id=6, name='tony', eligible=False)


def test_copy_from_file():
    with NamedTemporaryFile(mode='wt') as output:
        jsonl.copy_from_file(_here('test1.jsonl'),
                             to_filepath=output.name, exclude_columns=['id'])

        assert os.path.isfile(output.name)

        records = list(jsonl.read_from_file(output.name))
        assert len(records) == 3
        _assert_columns_count(records, 2)
        _assert_record_matches(records[0], name='mark', eligible=False)
        _assert_record_matches(records[1], name='franz', eligible=True)
        _assert_record_matches(records[2], name='jansen', eligible=True)


def test_copy_from_files():
    with NamedTemporaryFile(mode='wt') as output:
        jsonl.copy_from_files([_here('test1.jsonl'), _here('test2.jsonl.gz')],
                              to_filepath=output.name)

        assert os.path.isfile(output.name)

        records = list(jsonl.read_from_file(output.name))
        assert len(records) == 6
        _assert_columns_count(records, 3)
        _assert_record_matches(records[0], name='mark', eligible=False)
        _assert_record_matches(records[1], name='franz', eligible=True)
        _assert_record_matches(records[2], name='jansen', eligible=True)

        _assert_record_matches(records[3], id=4, name='antonio', eligible=True)
        _assert_record_matches(records[4], id=5, name='karl', eligible=False)
        _assert_record_matches(records[5], id=6, name='tony', eligible=False)


def test_copy_from_file_to_gzipped_file():
    input_filename = _here('test1.jsonl')
    output_filename = _here('{}.gz'.format(input_filename))

    jsonl.copy_from_file(
        input_filename, to_filepath=output_filename, exclude_columns=['id'])

    assert os.path.isfile(output_filename)
    assert _file_size(output_filename) < _file_size(input_filename)

    records = list(jsonl.read_from_file(output_filename))
    assert len(records) == 3
    _assert_columns_count(records, 2)
    _assert_record_matches(records[0], name='mark', eligible=False)
    _assert_record_matches(records[1], name='franz', eligible=True)
    _assert_record_matches(records[2], name='jansen', eligible=True)

    delete_file(output_filename)


def _assert_columns_count(records, expected_count):
    assert len(records[0]) == expected_count


def _assert_record_matches(record, id=None, name=None, eligible=None):
    if id:
        assert record['id'] == id
    if name:
        assert record['name'] == name
    if eligible:
        assert record['eligible'] == eligible


def _file_size(filepath):
    stats = os.stat(filepath)
    return stats.st_size


def _here(filename):
    return os.path.join(Path(__file__).parent, filename)
