#!/usr/bin/env python
"""Wordcount pyspark"""

import pyspark
from pyspark import SparkContext
from pyspark.sql import SQLContext
from pyspark.sql.functions import split, explode, col, lower

def to_words(documents, separators_regexp=r'\s+'):
    words = (documents
        .select(explode(split(documents.value, separators_regexp)).alias('word'))
        .select(lower(col('word')).alias('word'))
        .filter(col('word') != ''))
    return words

def count_words(documents, separators_regexp=r'\s+'):
    words = to_words(documents, separators_regexp)
    counts = words.groupBy("word").count()
    return counts

def _main():
    sc = pyspark.SparkContext()
    sqlContext = SQLContext(sc)
    documents = sqlContext.read.text("gs://de-training-input-bucket/words/big.txt")
    counts = count_words(documents, r'\W+')
    counts.write.mode("overwrite").csv("gs://de-training-output-bucket-0/output-test/")

if __name__ == '__main__':
    _main()
