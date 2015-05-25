
# reference to our dataset
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# paths 
dataDir <- "./data"
dataset.zip <- "./data/dataset.zip"

# variables labels
features.txt <- "UCI HAR Dataset/features.txt"
activity_labels.txt <- "UCI HAR Dataset/activity_labels.txt"

# data test
X_test.txt <- "UCI HAR Dataset/test/X_test.txt"
subject_test.txt <- "UCI HAR Dataset/test/subject_test.txt"
y_test.txt <- "UCI HAR Dataset/test/y_test.txt"

# data train
X_train.txt <- "UCI HAR Dataset/train/X_train.txt"
subject_train.txt <- "UCI HAR Dataset/train/subject_train.txt"
y_train.txt <- "UCI HAR Dataset/train/y_train.txt"

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
    names <- read.table(features.txt)
    # read activity names
    activityNames <- read.table(activity_labels.txt)
      
    # There are duplicate column names. Error: found duplicated column names
    # https://class.coursera.org/getdata-014/forum/thread?thread_id=56
    # so get the indexes from names data frame 
    meanStdColIndex = grep("mean\\(\\)|std\\(\\)", names$V2, value = FALSE)
    
    
    full_test <- do.call ( "createDataTable",
                           list(x_data_path = X_test.txt, y_data_path = y_test.txt, 
                                 subject_path = subject_test.txt, y_labels =  activityNames, 
                                 variables = names, columns = meanStdColIndex) )
    
    full_train <- do.call( "createDataTable", 
                           list(x_data_path = X_train.txt, y_data_path = y_train.txt, 
                                subject_path = subject_train.txt, y_labels =  activityNames, 
                                variables = names, columns = meanStdColIndex) )
      
    # create the full data table
    combined <- rbind(full_test, full_train)
    
    # uncomment to inspect 
    # write.table(combined, "combined.txt", row.name=FALSE)
    
    # count by group to double check our tidy data
    counts <- combined %>% dplyr::count(activity, subject, sort=TRUE)
    write.table(counts, "counts.txt", row.name=FALSE)
    
    # group by activity and subject and summarise each variable
    # the output will be in the wide format
    tidy <- combined %>% dplyr::group_by(activity, subject) %>% summarise_each(funs(mean))
    
    # clean up names
    names(tidy) <- gsub("[_-]", " ", names(tidy))
    names(tidy) <- gsub("[\\(\\)]", "", names(tidy))
    
    # write out for codebook
    # write.table(names(tidy), "cleanNames.txt", row.name=FALSE)
    
    # write our tidy data
    write.table(tidy, "tidy.txt", row.name=FALSE)
    
    # return tidy
    tidy
}

createDataTable <- function(x_data_path, y_data_path, subject_path, 
                              y_labels,  variables, columns) {
    # read data set x 
    data_set_x <- as.data.table(read.table(x_data_path))
    # set to descripitive names
    setnames(data_set_x, as.character(variables[,2]))
    # select columns we are interested in
    data_set_x <- select(data_set_x, columns)   
    # read subjects
    subjects <- read.table(subject_path)
    setnames(subjects, c("subject"))
    # read activities 
    activity <- read.table(y_data_path)
    # use activity names
    activity_merged <- activity %>%
        mutate(V1 = factor(V1, labels=y_labels$V2)) %>%
        rename(activity=V1) %>%
        select(activity) 
    # bind columns
    full <- bind_cols(subjects, activity_merged, data_set_x)
    
    full  
}