#!/usr/bin/env python

"""
Convert a *.jsonl or *.jsonl.gz file to a SQLite database (with a single table)
You can invoke ./json_to_sqlite.py --help to see all options to use this tool.
"""

from __future__ import print_function
import click
import os.path
import re
import subprocess
import tempfile
import glob
import sys

import jsonl
from gzip_util import is_gzipped_file, decompress_gzip
from file_util import (
    add_extension_if_missing,
    temporary_file_rename,
    delete_file,
    remove_last_extension,
    prepend_to_filename,
    replace_extension,
    replace_filename_sans_extension,
    ensure_file_extension
)


@click.command(context_settings=dict(help_option_names=['-h', '--help']))
@click.option(
    '-o', '--output-filepath',
    help="""
    Output file path (e.g. clients.sqlite). If it is not specified, then the input file name
    is used with the *.sqlite extension.
    """,
    type=str
)
@click.option(
    '-c', '--columns',
    help="""Comma-separated list of columns to export. If it is not specified, all columns are
    exported"""
)
@click.argument(
    'input-filepath', required=True, type=str
)
def to_sqlite(input_filepath, output_filepath, columns):
    """
    Assumes that the input file points to a jsonl file (*.jsonl or *.json.gz) and the output
    will be SQLite file.

    --input-file-path: Input file path or input files wildcard (e.g. clients.jsonl,
                       clients.jsonl.gz or client*.jsonl.gz)
    """
    input_filepaths = _expand_wildcard(input_filepath)
    output_filepath = _ensure_output_filepath(
        output_filepath, input_filepaths[0])
    columns = _parse_columns(columns)

    _raise_if_nonexistent(input_filepaths)

    table_name = _get_alphanumeric_substring_in_filename(output_filepath)
    if len(input_filepaths) == 1 and not columns:
        # we handle this case separately to avoid making an intermediate file if possible
        _from_jsonl_to_sqlite_table(
            input_filepaths[0], output_filepath, table_name=table_name)
    else:
        with tempfile.NamedTemporaryFile() as intermediate:
            jsonl.copy_from_files(
                input_filepaths, intermediate.name, include_columns=columns)
            _from_jsonl_to_sqlite_table(
                intermediate.name, output_filepath, table_name=table_name)

# TODO: define a clear error handling strategy (e.g. if only one of the files is missing,
#       do we really want to abort? should we support a --ignore-missing-input flag?)
def _raise_if_nonexistent(filepaths):
    for filepath in filepaths:
        if not os.path.isfile(filepath):
            _print_error('Input file "{0}" does not exist'.format(filepath))
            sys.exit()


# TODO: define a clear error handling strategy (e.g. if only one of the files is missing,
#       do we really want to abort? should we support a --ignore-missing-input flag?)
def _raise_if_nonexistent(filepaths):
    for filepath in filepaths:
        if not os.path.isfile(filepath):
            _print_error('Input file "{0}" does not exist'.format(filepath))
            sys.exit()


def _from_jsonl_to_sqlite_table(input_filepath, output_filepath, table_name=None):
    new_filename = _create_filename(input_filepath, table_name)
    with temporary_file_rename(input_filepath, new_name=new_filename) as input_filepath:
        decompressed, input_filepath = _decompress_if_needed(input_filepath)
        _run_conversion(input_filepath, output_filepath)
        if decompressed:
            delete_file(input_filepath, raise_on_error=False)


def _run_conversion(input_filepath, output_filepath):
    command = 'sqlitebiter file {input} -o {output}'.format(
        input=input_filepath,
        output=output_filepath)
    status_code = subprocess.call(command, shell=True)
    if status_code != 0:
        delete_file(output_filepath, raise_on_error=True)


def _decompress_if_needed(input_filepath):
    decompressed = False
    if is_gzipped_file(input_filepath):
        decompress_gzip(input_filepath)
        input_filepath = remove_last_extension(input_filepath)
        decompressed = True
    return decompressed, input_filepath


# NOTE: sqlitebiter (the current tool used export to SQLite) has a bug in how it formats
# queries, so tables can't begin with numbers
def _create_filename(filepath, table_name=None):
    _, filename = os.path.split(filepath)
    filename = _try_use_table_name_as_filename(filename, table_name)
    filename = _ensure_filename_starts_with_letters(filename)
    return add_extension_if_missing(filename, 'jsonl')


def _ensure_filename_starts_with_letters(filename):
    if not re.search('^[a-zA-Z]', filename):
        return 'table__{}'.format(filename)
    return filename


def _try_use_table_name_as_filename(filepath, table_name):
    if table_name is not None:
        return replace_filename_sans_extension(
            filepath, table_name)
    return filepath


def _get_alphanumeric_substring_in_filename(filepath):
    filepath, filename = os.path.split(filepath)
    match = re.search(r'[a-zA-Z]{3,}', filename)
    if match:
        return match.group(0)


def _expand_wildcard(input_filepath):
    paths = glob.glob(input_filepath)
    return paths or [input_filepath]


def _ensure_output_filepath(output_filepath, input_filepath):
    extension = 'sqlite'
    if output_filepath is None:
        output_filepath = replace_extension(input_filepath, extension)
    return ensure_file_extension(output_filepath, extension)


# TODO: support more complex column names (e.g. names within quotes, which may include
#       spaces or commas)
def _parse_columns(columns):
    if columns is not None:
        return [column.strip() for column in columns.split(',')]
    return []


def _print_error(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


if __name__ == '__main__':
    to_sqlite()
