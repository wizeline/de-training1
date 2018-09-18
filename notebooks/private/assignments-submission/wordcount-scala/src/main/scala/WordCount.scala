package com.assignments.wc

import org.apache.spark.sql.SparkSession

object WordCount {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder()
      .getOrCreate()

    import spark.implicits._

    val documents = spark.read.text("gs://de-training-input-bucket/words/big.txt").as[String]
    val words = documents.flatMap(value => value.split("\\s+"))
    val counts = words.groupByKey(_.toLowerCase).count()
    counts.write.
      format("com.databricks.spark.csv").
      option("header", false).
      option("delimiter", ",").
      save("gs://de-training-output-bucket-0/output-sc/")
  }
}
