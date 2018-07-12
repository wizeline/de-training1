from datetime import datetime
from datetime import timedelta
from itertools import islice

from date_util import sample_datetime_sequence

def test__sample_date_sequence():
    two_weeks = timedelta(weeks=2)
    three_days = timedelta(days=3)

    step = three_days
    start_date = datetime.today()
    end_date = start_date + two_weeks
    max_samples = int((end_date - start_date) / step)

    dates = list(sample_datetime_sequence(
        start_date,
        end=end_date,
        step=step,
        sample_probability=0.7))

    assert len(dates) <= max_samples
    assert _is_increasing_sequence(dates)
    assert _all_below_limit(dates, end_date)


def _all_below_limit(sequence, limit):
    return all(item < limit for item in sequence)


def _is_increasing_sequence(sequence):
    return all(s1 < s2 for (s1, s2) in zip(sequence, islice(sequence, 1, None)))
