
from pyspark.sql.window import Window
from pyspark.sql.functions import *
from pyspark.sql.types import IntegerType, LongType, DoubleType, StringType, StructField, StructType

# don't forget to set the correct destination bucket
bucket = "de-training-output-student"

orders  = spark.read.json("gs://de-training-input/alimazon/200000/stock-orders/")

products = orders.groupBy(year("timestamp").alias("year"), weekofyear("timestamp").alias("week"), substring("id",0,2).alias("category"), "product_id").agg(sum("total").alias("total"), sum("quantity").alias("quantity"))

windowDesc = Window.partitionBy("year", "week", "category").orderBy(desc("total"))

orderedProductsDesc = products.withColumn("order", row_number().over(windowDesc)).repartition(500)

topMostProducts = orderedProductsDesc.rdd.filter(lambda row: row['order'] <= 5)

schema = StructType([StructField("year", IntegerType(), True), StructField("week", IntegerType(), True),StructField("category", StringType(), True),StructField("product_id", StringType(), True),StructField("total", DoubleType(), True),StructField("quantity", LongType(), True),StructField("order", IntegerType(), True)])

topMostProductsDF = spark.createDataFrame(topMostProducts, schema).cache()

topMostTotals = topMostProductsDF.groupBy("year", col("week").alias("week_num"), col("category").alias("prod_cat")).agg(sum("quantity").alias("total_qty_top5"), sum("total").alias("total_spent_top5"))

topMostTotals.coalesce(1).write.option("codec", "org.apache.hadoop.io.compress.GzipCodec").csv("gs://" + bucket + "/assignment-6/top-5-most")

windowAsc = Window.partitionBy("year", "week", "category").orderBy(asc("total"))

orderedProductsAsc = products.withColumn("order", row_number().over(windowAsc)).repartition(500)

topLeastProducts = orderedProductsAsc.rdd.filter(lambda row: row['order'] <= 5)

topLeastProductsDF = spark.createDataFrame(topLeastProducts, schema).cache()

topLeastTotals = topLeastProductsDF.groupBy("year", col("week").alias("week_num"), col("category").alias("prod_cat")).agg(sum("quantity").alias("total_qty_top5"), sum("total").alias("total_spent_top5"))

topLeastTotals.coalesce(1).write.option("codec", "org.apache.hadoop.io.compress.GzipCodec").csv("gs://" + bucket + "/assignment-6/top-5-least")

topMostProductsConcat = topMostProductsDF.groupBy("category").pivot("order").agg(first("product_id")).withColumn("top5_most", concat_ws(";", "1","2","3","4","5")).drop("1","2","3","4","5")

topLeastProductsConcat = topLeastProductsDF.groupBy("category").pivot("order").agg(first("product_id")).withColumn("top5_least", concat_ws(";", "1","2","3","4","5")).drop("1","2","3","4","5")

categoryTotals = orders.groupBy(substring("id",0,2).alias("category")).agg(sum("total").alias("total_spent"), sum("quantity").alias("total_qty_cat")).cache()

allTotals = categoryTotals.join(topMostProductsConcat, "category").join(topLeastProductsConcat, "category")

allTotalsOrdered = allTotals.select("category","top5_most", "top5_least", "total_qty_cat", "total_spent")

allTotalsOrdered.coalesce(1).write.option("codec", "org.apache.hadoop.io.compress.GzipCodec").csv("gs://" + bucket + "/assignment-6/top-5-all")




