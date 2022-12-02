# Getting and Cleaning Data Course Project
# The following script:
#   1. Merges the training and the test sets to create one data set.
#   2. Extracts only the measurements on the mean and standard deviation for each measurement.
#   3. Uses descriptive activity names to name the activities in the data set
#   4. Appropriately labels the data set with descriptive variable names.
#   5. From the data set in step 4, creates a second, independent tidy data set with the average
#     of each variable for each activity and each subject.

library(dplyr)

setwd('~/repos/getting-cleaning-data-coursera/data')

zipurl <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(zipurl, destfile='dataset.zip')
unzip('dataset.zip')

# read in the data
X_train <- read.table('UCI HAR Dataset/train/X_train.txt', header=FALSE)
y_train <- read.table('UCI HAR Dataset/train/y_train.txt', header=FALSE)
s_train <- read.table('UCI HAR Dataset/train/subject_train.txt', header=FALSE)

X_test <- read.table('UCI HAR Dataset/test/X_test.txt', header=FALSE)
y_test <- read.table('UCI HAR Dataset/test/y_test.txt', header=FALSE)
s_test <- read.table('UCI HAR Dataset/test/subject_test.txt', header=FALSE)

activity_labels <- read.table('UCI HAR Dataset/activity_labels.txt', header=FALSE)
features <- readLines('UCI HAR Dataset/features.txt')

# Assignment specified that only measurements on the mean or standard deviation are needed
# Therefore, will keep all features with either mean() or std() in the name
mean_std_features_idx <- grep('mean\\(\\)|std\\(\\)', features)
X_train_subset <- X_train[, mean_std_features_idx]
X_test_subset <- X_test[, mean_std_features_idx]

## Need to clean the feature strings before using as variable names
## Removing number and space before string, removing (), changing - to _
feature_str <- features[mean_std_features_idx]
feature_str <- gsub('^.+\\s', '', feature_str)
feature_str <- gsub('[()]', '', feature_str)
feature_str <- gsub('-', '_', feature_str)

names(X_train_subset) <- feature_str
names(y_train) <- 'activity'
names(s_train) <- 'subject'

names(X_test_subset) <- feature_str
names(y_test) <- 'activity'
names(s_test) <- 'subject'

names(activity_labels) <- c('activity', 'activity_label')

data <- bind_rows(bind_cols(X_train_subset, y_train, s_train), bind_cols(X_test_subset, y_test, s_test)) %>% 
  as_tibble() %>% 
  left_join(activity_labels, by='activity')

# Create tidy dataset that summarizes previously created dataset and save as txt file
data %>% 
  select(-activity) %>% 
  group_by(activity_label, subject) %>% 
  summarise_all(mean) %>% 
  rename_at(vars(tBodyAcc_mean_X:fBodyBodyGyroJerkMag_std), function(x){paste0('meanof_', x)}) %>% 
  write.table(file='~/repos/getting-cleaning-data-coursera/tidy_data.txt', row.names=FALSE)


