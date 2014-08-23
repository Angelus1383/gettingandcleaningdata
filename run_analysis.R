library("plyr")
# Downloads the data file if doesn't exist.
downloadAndExtractFile <- function(){
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"    
    # Check if exist the data folder
    if(!file.exists("data")) {
        message("Create data folder")
        dir.create("data")
    }
    # Check if exist the zip data file
    if(!file.exists("data/Dataset.zip")){
        message("Download file from web")
        download.file(url, "data/Dataset.zip", method="curl")    
    }
    # Check if exist exctraded data file
    if(!file.exists("data/UCI HAR Dataset")){
        message("Extractig data from zip")
        unzip("data/Dataset.zip"), exdir="data")
    }
}

# Reads train and test data merging them in a unique dataset.
mergeDataSet <- function(){
    # Read the dataframe's column names
    features <- read.table("data/UCI HAR Dataset/features.txt")
    featureNames <-  features[,2]
    # Read data
    message("reading train data")
    trainSubjectId <- read.table("data/UCI HAR Dataset/train/subject_train.txt")
    colnames(trainSubjectId) <- "subject_id"
    trainActivityId <- read.table("data/UCI HAR Dataset/train/y_train.txt")
    colnames(trainActivityId) <- "activity_id"
    trainData <- read.table("data/UCI HAR Dataset/train/X_train.txt")
    colnames(trainData) <- featureNames
    message("reading test data")
    testSubjectId <- read.table("data/UCI HAR Dataset/test/subject_test.txt")
    colnames(testSubjectId) <- "subject_id"
    testActivityId <- read.table("data/UCI HAR Dataset/test/y_test.txt")
    colnames(testActivityId) <- "activity_id"
    testData<- read.table("data/UCI HAR Dataset/test/X_test.txt")
    colnames(testData) <- featureNames
    # Merge data
    train_data <- cbind(trainSubjectId , trainActivityId , trainData)
    test_data <- cbind(testSubjectId , testActivityId , testData)
    rbind(train_data,test_data)
}

# Extracts from the all data only columns relative to mean and standard deviation
# returning a new dataset.
extractMeanStdColumns <- function(allData){
    meanColNames <- names(allData)[grepl("mean()", names(allData),
                                         fixed=TRUE, ignore.case=TRUE)]
    stdColNames <- names(allData)[grepl("std()", names(allData),
                                        fixed=TRUE, ignore.case=TRUE)]
    allData[,c("subject_id","activity_id",meanColNames,stdColNames)]    
}

# Reads the activity file adding a new column 
# with the descriptive activity names to the given dataset.
useDescriptiveActivityNames <- function(meanStdData){
    labels <- read.table("data/UCI HAR Dataset/activity_labels.txt",
                                  col.names=c("activity_id","activity_name"))
    df <- merge(labels, meanStdData, by.x="activity_id", by.y="activity_id", all=TRUE)
    df <- subset(df, select = -c(1))
}

# Creates a new tidy dataset with the average of each variable for each activity and each subject
createTidyDf <- function(descrNames){
    ddply(descrNames, .(activity_name, subject_id), function(x) colMeans(x[,2:dim(descrNames)[2]]))
}

#Point 0: Retrieve and prepare data.
downloadAndExtractFile()
#Point 1: Merges the training and the test sets to create one data set.
allData <- mergeDataSet()
#Point 2: Extracts only the measurements on the mean and standard deviation for each measurement. 
meanStdData <- extractMeanStdColumns(allData)
#Point 3: Uses descriptive activity names to name the activities in the data set
descrNames <- useDescriptiveActivityNames(meanStdData)
#Point 4: Appropriately labels the data set with descriptive variable names.
# This point was done contextually to data loading.
#Point 5: Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
tidyDF <- createTidyDf(descrNames)
# Create a file with the new tidy dataset
write.table(tidyDF,"./data/tidyDataset.txt")