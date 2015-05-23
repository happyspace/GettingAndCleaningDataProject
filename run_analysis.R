
# reference to our dataset
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# paths 
dataDir <- "./data"
dataset.zip <- "./data/dataset.zip"

run_analysis <- function(){
    # load libraries
    library(data.table)
    library(dplyr)
    library(tidyr)
    
    dd <- file.exists(dataDir)
    
    # create data folder
    if(!dd) {
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
    
    fullTrain <- bind_cols(subjectTrain, activityTrain, trainXdt)
    
    combined <- rbind(fullTest,fullTrain)
    
    # 
    tidy <- combined %>% dplyr::group_by(activity, subject) %>% summarise_each(funs(mean))
    
    write.table(tidy, "tidy.txt")
    
    tidy
}