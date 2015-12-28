## Getting and Cleaning Data assignment

This file explains all the scripts I used to get to the final tidy dataset.

### 1. Merges the training and the test sets to create one data set.

First of all I read the following files:
* "./UCI HAR Dataset/train/X_train.txt"
* "./UCI HAR Dataset/train/y_train.txt"
* "./UCI HAR Dataset/test/X_test.txt"
* "./UCI HAR Dataset/test/y_test.txt"

I used the function read.table. Each of those files were loaded into differente data.tables

Then by using the functions cbind and rbind I created a table with all the data. Something like: 

<!-- -->

X_complete <- rbind(X_train, X_test)
y_complete <- rbind(y_train, y_test)

complete_Data <- cbind(X_complete, y_complete)


### 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

To calculate the means and std I used a combination of the split and sapply functions to calculate the mean and std for each column of the data table
I also built the function colStds wich emulate the colMeans but for std.

The vectors means_Data and std_Data contains the means and std per column of the data table.

### 3. Uses descriptive activity names to name the activities in the data set

I read the file "./UCI HAR Dataset/activity_labels.txt" which contains a key/value format which associates the id of the activity with its proper name

I used it to find/replace the numeric values of the activities and change them by the names of the activities

<!-- -->

for(i in activities$V1)
{
  y_complete$V1[y_complete$V1 == i] <- activities$V2[activities$V1 == i]
}

### 4. Appropriately labels the data set with descriptive variable names. 

The names for each column were in the file "./UCI HAR Dataset/features.txt". I used the colnames function to asing those values to the name of the dataset.


### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

I created an independent data table based on the previous one.
Then I read the files "./UCI HAR Dataset/train/subject_train.txt" and "./UCI HAR Dataset/test/subject_test.txt" which contain the information on the subjects. I join that information to the data table. After assingning the right column names I splitted the data table and calculate the means of each column with the following instructions

<!-- -->

splitBySubjectActivity <- split(new_Complete_Data, list(new_Complete_Data$SUBJECT, new_Complete_Data$ACTIVITY))
meansBySubjectActivity <- lapply(splitBySubjectActivity, function(x) colMeans(x, na.rm = TRUE))


After that I moved through the list to create the final data frame which contains the mean value of each column grouped by subject and activity. That is the data frame that was saved as the file meansBySubjectActivity.txt


