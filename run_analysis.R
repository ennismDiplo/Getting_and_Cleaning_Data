### Install and load the reshape2 package
install.packages("reshape2")

library(reshape2)

## Download the dataset and unzip it
untidy_dataset <- "get_untidy_dataset.zip"

if (!file.exists(untidy_dataset)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, untidy_dataset, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(untidy_dataset) 
}

### Read activity labels and features into variables
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

### Get just the data for mean and standard deviation
desired_features <- grep(".*mean.*|.*std.*", features[,2])
desired_features_names <- features[desired_features,2]
desired_features_names = gsub('-mean', 'Mean', desired_features_names)
desired_features_names = gsub('-std', 'Std', desired_features_names)
desired_features_names <- gsub('[-()]', '', desired_features_names)


### Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[desired_features]
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_subjects, train_activities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[desired_features]
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_subjects, test_activities, test)

### Merge datasets and add labels
all_data <- rbind(train, test)
colnames(all_data) <- c("subject", "activity", desired_features_names)

### turn activities and subjects into factors
all_data$activity <- factor(all_data$activity, levels = activity_labels[,1], labels = activity_labels[,2])
all_data$subject <- as.factor(all_data$subject)

all_data_melted <- melt(all_data, id = c("subject", "activity"))
all_data_mean <- dcast(all_data_melted, subject + activity ~ variable, mean)

write.table(all_data_mean, "tidy_data_set.txt", row.names = FALSE, quote = FALSE)

