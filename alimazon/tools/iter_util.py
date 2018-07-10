from itertools import groupby, count

def batch(iterable, size):
    """
    Collect data into fixed-length chunks or blocks"
    batch('ABCDEFG', 3) --> ABC DEF G
    """
    counter = count()
    for key, group in groupby(iterable, lambda x: next(counter) // size):
        yield group
