import random
from datetime import datetime
import dateutil.parser as date_parser

def today_string():
    return datetime.today().strftime('%Y%m%dT%H%M%S')


def datetime_sequence(start, end, step):
    while start < end:
        yield start
        start += step

def _ensure_datetime(date):
    if type(date) != datetime:
        date = date_parser.parse(date)
    return date

# TODO: validate arguments
def sample_datetime_sequence(start, end, step, sample_probability, random_seed=None):
    """
    Generate a sequence of datetimes between `start` and `date` (inclusive) with each
    element at least `step` units of time apart. Given an already generated date in the
    sequence, the probability of choosing the next date with `step` units of time (in the
    future or in the past) is given by `sample_probability`
    """
    random.seed(random_seed)
    for moment in datetime_sequence(start, end, step):
        if random.random() <= sample_probability:
            yield moment
