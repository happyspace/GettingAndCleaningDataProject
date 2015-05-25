# Getting and Cleaning Data Project

This project summarizes data collected in a study *Human Activity Recognition Using Smartphones*.

## Study Homepage
[UCI Machine Learning Repository](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

## Study Data
[https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

# Run Analysis

Source *run_analysis.R* within an R environment. *run_analysis.R* defines a function *run_analysis* which will download study data and preform the following analysis over the data.

* Extract variables concerning mean and standard deviation. 
* With in this data set, for each variable an average will be calculated for each activity preformed by subjects in the study . 

Two data set are created:

* counts.txt -- the count of each subject and each activity preformed by the subject
* tidy.txt -- average of each variable for each activity for each subject

Plese note that tidy.txt checked with the project is completely correct. 

To run the analysis:  

```R
source("run_analysis.R")
tidy <- run_analysis()
```



