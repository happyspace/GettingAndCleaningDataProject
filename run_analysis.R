
# reference to our dataset
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# paths 
dataDir <- "./data"
dataset.zip <- "./data/dataset.zip"

# data test

# data train

run_analysis <- function(){
    # load libraries
    library(data.table)
    library(dplyr)
    library(tidyr)
    
    # create data folder
    if(!file.exists(dataDir)) {
        dir.create(dataDir)
    }
    
    # download and unzip data
    if(!file.exists(dataset.zip)) {
        download.file(url = fileURL, destfile = dataset.zip)
        # having trouble with exdir so use defaults
        unzip(dataset.zip)
    }
    
    # read variable names (column names)
    names <- read.table("UCI HAR Dataset/features.txt")
    # read activity names
    activityNames <- read.table("UCI HAR Dataset/activity_labels.txt")
    
    # There are duplicate column names. Error: found duplicated column names
    # https://class.coursera.org/getdata-014/forum/thread?thread_id=56
    # so get the indexes from names data frame 
    meanStdColIndex = grep("mean()|std()", names$V2, value = FALSE)
    
    # read test set 
    testXdt <- as.data.table(read.table("UCI HAR Dataset/test/X_test.txt"))
    # set to descripitive names
    setnames(testXdt, as.character(names[,2]))
    
    # select columns we are interested in
    testXdt <- select(testXdt, meanStdColIndex)
    
    subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
    colnames(subjectTest) <- c("subject")
    activityTest <- read.table("UCI HAR Dataset/test/y_test.txt")
    # use activity names
    activityTest <- 
        merge(x = activityNames, y = activityTest, by.x = "V1", by.y = "V1")  %>%
        select(V2)
    colnames(activityTest) <- c("activity")
    
    fullTest <- bind_cols(subjectTest, activityTest, testXdt)
       
    # read train set
    trainXdt <- as.data.table(read.table("UCI HAR Dataset/train/X_train.txt"))
    setnames(trainXdt, as.character(names[,2]))
    
    # select columns we are interested in
    trainXdt <- select(trainXdt, meanStdColIndex)
    
    subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
    colnames(subjectTrain) <- c("subject")
    activityTrain <- read.table("UCI HAR Dataset/train/y_train.txt")
    # use activity names
    activityTrain <- 
        merge(x = activityNames, y = activityTrain, by.x = "V1", by.y = "V1")  %>%
        select(V2)
    
    colnames(activityTrain) <- c("activity")
    
    # create the taining data table
    fullTrain <- bind_cols(subjectTrain, activityTrain, trainXdt)
    # create the full data table
    combined <- rbind(fullTest,fullTrain)
    dplyr::arrange(.data = combined, subject, activity)
    
    # uncomment to inspect 
    # write.table(combined, "combined.txt", row.name=FALSE)
    
    # count by group to double check our tidy data
    counts <- combined %>% dplyr::count(activity, subject, sort=TRUE)
    write.table(counts, "counts.txt", row.name=FALSE)
    
    # group by activity and subject and summarise each variable
    # the output will be in the wide format
    tidy <- combined %>% dplyr::group_by(activity, subject) %>% summarise_each(funs(mean))
    
    # write our tidy data
    write.table(tidy, "tidy.txt", row.name=FALSE)
    
    # return tidy
    tidy
}