import argparse
import io
import json
import sys

# TODO: avoid reading the whole file into memory
def remove_utf8_bom(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument('filenames', nargs='*', help='Filenames to remove BOM mark from.')
    args = parser.parse_args(argv)

    status = 0
    for filename in args.filenames:
        try:
            contents = ''
            with open(filename, mode='r', encoding='utf-8-sig') as input:
                contents = input.read()
            with open(filename, mode='w', encoding='utf-8') as output:
                output.write(contents)
        except (ValueError, UnicodeDecodeError) as exc:
            print('{}: Failed to remove UTF8 BOM ({})'.format(filename, exc))
            status = 1
    return status

if __name__ == '__main__':
    sys.exit(remove_utf8_bom())

