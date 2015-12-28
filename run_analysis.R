library(data.table)

##############################
# Functions section
##############################

# input: inputTable is a numeric table
# output: a vector with the standard deviation per column of inputTable
# description: this function returns a vector with the standard deviation
#              per column of the table. Acts simililarly to colMeans 
colStds <- function(inputTable)
{
  # create an empty numeric vector with lenght = to ncols of input table 
  columnSD <- vector(mode = "numeric", length = ncol(inputTable))
  
  # for each column of the table
  for(i in 1:ncol(inputTable))
  {
    # calculate the sd of that column and write the value in position i of columnSD
    columnSD[i] <- sd(inputTable[, i])
  }
  # return the vector with the SDs per column
  columnSD
}

##############################
# 1. Merges the training and the test sets 
#    to create one data set.
##############################

##############################
# read training dataset
##############################

# reading X_train.txt 
X_train <- read.table( file = "./UCI HAR Dataset/train/X_train.txt", 
                       header = FALSE, dec = ".", sep = "" )

# reading y_train.txt
y_train <- read.table( file = "./UCI HAR Dataset/train/y_train.txt",
                       header = FALSE, dec = ".", sep = "" )

##############################
# read testing dataset
##############################
# reading X_test.txt 
X_test <- read.table( file = "./UCI HAR Dataset/test/X_test.txt", 
                      header = FALSE, dec = ".", sep = "" )

# reading y_test.txt
y_test <- read.table( file = "./UCI HAR Dataset/test/y_test.txt",
                      header = FALSE, dec = ".", sep = "" )

##############################
# merging data
##############################

X_complete <- rbind(X_train, X_test)
y_complete <- rbind(y_train, y_test)

# merge the train_Data and test_Data
complete_Data <- cbind(X_complete, y_complete)
# complete_Data is the required data set :)


##############################
# 2. Extracts only the measurements on the mean and 
#    standard deviation for each measurement. 
##############################
splitByActivity <- split(complete_Data, y_complete)
means_Data <- sapply(splitByActivity, function(x) colMeans(x, na.rm = TRUE))
stds_Data <- sapply(splitByActivity, colStds)

##############################
# 3. Uses descriptive activity names to name 
#    the activities in the data set
##############################

# read activities names from file activity_labels.txt
activities <- read.table ( file = "./UCI HAR Dataset/activity_labels.txt", 
                           header = FALSE, sep = "" )

# chagng all data types to characters to be able to set new values
y_complete$V1 <- as.character(y_complete$V1)
activities$V1 <- as.character(activities$V1)
activities$V2 <- as.character(activities$V2)

# replace each value of y_complete by the activity name
for(i in activities$V1)
{
  y_complete$V1[y_complete$V1 == i] <- activities$V2[activities$V1 == i]
}

##############################
# 4. Appropriately labels the data set with
#    descriptive variable names. 
##############################

# read colnames from file features.txt 
features <- read.table ( file = "./UCI HAR Dataset/features.txt",
                         header = FALSE, sep = "" )
# create the activity row
y_name <- data.frame(max(features$V1)+1L, "ACTIVITY")
colnames(y_name) <- c("V1", "V2")
# add activity row to features table
features <- rbind(features, y_name)

# set the colnames to the complete_Data table
features$V2 <- as.character(features$V2)
colnames(complete_Data) <- features$V2


##############################
# 5. From the data set in step 4, creates a second, 
#    independent tidy data set with the average of each
#    variable for each activity and each subject.
##############################
# create a copy of previous data
new_Complete_Data = complete_Data

#new_Complete_Data <- new_Complete_Data[, !(names(new_Complete_Data) %in% c("ACTIVITY"))]
#colnames(y_complete) <- c("ACTIVITY")
#new_Complete_Data <- cbind(new_Complete_Data, y_complete)

# read subject files
subject_train <- read.table( file = "./UCI HAR Dataset/train/subject_train.txt", 
                             header = FALSE, dec = ".", sep = "" )
subject_test <- read.table( file = "./UCI HAR Dataset/test/subject_test.txt", 
                            header = FALSE, dec = ".", sep = "" )

# join the subject data
subject_complete <- rbind(subject_train, subject_test)

# set the name of the column
colnames(subject_complete) <- c("SUBJECT")

# join the complete subject to the new_Complete_Data
new_Complete_Data <- cbind(new_Complete_Data, subject_complete)

# convert to factors for spliting
new_Complete_Data$ACTIVITY <- as.numeric(new_Complete_Data$ACTIVITY)
new_Complete_Data$SUBJECT <- as.numeric(new_Complete_Data$SUBJECT)

splitBySubjectActivity <- split(new_Complete_Data, list(new_Complete_Data$SUBJECT, new_Complete_Data$ACTIVITY))
meansBySubjectActivity <- lapply(splitBySubjectActivity, function(x) colMeans(x, na.rm = TRUE))


# create final data table of means
finalMatrix <- matrix(nrow = length(meansBySubjectActivity), ncol = length(meansBySubjectActivity[[1]]))
for(i in 1:length(meansBySubjectActivity))
{
  finalMatrix[i, ] <- meansBySubjectActivity[[i]]
}

# create data frame from finalMatrix
finalDataFrame <- data.frame(finalMatrix)
# set the column names
colnames(finalDataFrame) <- names(meansBySubjectActivity[[1]])

# change the ACTIVITY numeric values by real character Values
finalDataFrame$ACTIVITY <- as.character(finalDataFrame$ACTIVITY)
for(i in activities$V1)
{
  finalDataFrame$ACTIVITY[finalDataFrame$ACTIVITY == i] <- activities$V2[activities$V1 == i]
}

# reordering columns for better reading
finalDataFrame <- finalDataFrame[, c(563, 562, 1:561)]

# write the file
write.table(finalDataFrame, file = "meansBySubjectActivity.txt", row.names = FALSE)


