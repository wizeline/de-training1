import subprocess

# TODO: implement unit tests

# TODO: harden function to handle files gzipped files without extension
def is_gzipped_file(input_filepath):
    return input_filepath.endswith('.gz')


def decompress_gzip(input_filepath, verbose=False):
    if verbose:
        print('Decompressing {}'.format(input_filepath))

    status_code = subprocess.call(
        'gzip --force --keep -d {path}'.format(
            path=input_filepath),
        shell=True)

    if status_code != 0:
        print_error('Failed to decompress gzip file: {}'.format(input_filepath))
