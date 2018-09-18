# Submit Jobs to the Dataproc Cluster

## Self-Contained Applications

Since we are working on a Dataproc Cluster infrastructure, there are a set of tools available so that you can submit the application to the cluster and perform some jobs.

We'll be working with the Cloud SDK [gcloud](https://cloud.google.com/sdk/gcloud/reference/dataproc/jobs/submit/) command-line tool, the easiest way to do it will be using the CloudShell of the project.

If you are working on a local environment you'll have to install the Cloud SDK, login with your personal gmail account and make sure you have access to the cluster instance assigned to you for the course.

Check your gcloud configuration with this command

```gcloud config configurations describe de-training-configuration```

Also check that you have access to the cluster instance by running the list command for clusters.

```gcloud dataproc clusters list --region us-central1```

If none of this works, run the ```gcloud init``` command and follow the instructions there to setup the project.



## Scala

### 1. Prepare your project

We’re going to use ```sbt``` (a build tool for Scala) as the project build tool. It uses the ```build.sbt``` file on the root project folder to define the project’s description as well as the dependencies, i.e. the version of Apache Spark and others.

```
name := "scala-wordcount"
version := "1.0"
scalaVersion := "2.11.0"
libraryDependencies += "org.apache.spark" %% "spark-core" % "2.2.0" % "provided"
```

To use sbt you can either install it following the instructions [here](https://www.scala-sbt.org/1.0/docs/Setup.html). Or use [this](https://hub.docker.com/r/hseeberger/scala-sbt/) docker image and bind the project folder as a volume. The command to start the docker image will look something like this:

```docker run -it --rm -v path_to_project_folder:/root hseeberger/scala-sbt```

The application’s main code has to be under a ```src/main/scala directory```, using the ```.scala``` file extension.

Once your application is complete run the ```find .``` at the root of your project directory and the output should look like this:

```
.
./build.sbt
./src
./src/main
./src/main/scala
./src/main/scala/WordCount.scala
```

### 2. Create the JAR

Package the project with ```sbt package``` the result will be the creation of a target folder containing the JAR file which is now ready to be deployed onto the Spark Cluster.

![screen shot 2018-08-10 at 10 24 32 am](https://user-images.githubusercontent.com/40369995/43966474-9fe1d32e-9c87-11e8-92f4-d5d31d13f789.png)


### 3. Submit the Job

Use the ```gcloud dataproc jobs submit spark``` command to submit the Spark Job to the Cluster. Check the complete set of options that this command can receive at the official documentation  [here](https://cloud.google.com/sdk/gcloud/reference/dataproc/jobs/submit/spark).

To submit this sample Spark job, the command should look like this

```gcloud dataproc jobs submit spark --cluster de-training-<student-id> --region us-central1 --class com.assignments.wc.WordCount --jars ./scala-wordcount_2.11-1.0.jar```

**NOTE:** You can test all these steps using the provided example at ```wordcount-scala/``` just make sure to modify the output bucket URL according to the ```student-id``` assigned to you at the ```WordCount.scala``` file.

```scala
save("gs://de-training-output-bucket-<student-id>/output-sc/")
```

## Python

### 1. Prepare your project

Write your PySpark program in the main function:

```python
def main():
    #Some pyspark magic

if __name__ == '__main__':
    main()
```

### 2. Submit the Job

Use the ```gcloud dataproc jobs submit pyspark``` command to submit the Spark Job to the Cluster. Check the complete set of options that this command can receive at the official documentation [here](https://cloud.google.com/sdk/gcloud/reference/dataproc/jobs/submit/pyspark)


To submit this sample Spark job, the command should look like this

```gcloud dataproc jobs submit pyspark --cluster de-training-<student-id> --region us-central1 ./main.py```


**NOTE:** You can test all these steps using the provided example at ```wordcount-python/``` just make sure to modify the output bucket URL according to the ```student-id``` assigned to you at the ```main.py``` file.

```csv("gs://de-training-output-bucket-<student-id>/output-py/")```
