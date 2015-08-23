##
## Course project for Getting & Cleaning Data
##
## You should create one R script called run_analysis.R that does the
## following:
##
## Merges the training and the test sets to create one data 
## set. 
##
## Extracts only the measurements on the mean and standard deviation 
## for each measurement.  
##
## Uses descriptive activity names to name the  activities in the data set 
## Appropriately labels the data set with descriptive variable names. 
##
## From the data set in step 4, creates a second, independent tidy data set 
## with the average of each variable for each activity and each subject.
##

#
# 1. Merge the Training & Test data sets
#

# Read the training data set
training_data       = read.table("UCI\ HAR\ Dataset/train/X_train.txt")
training_activities = read.table("UCI\ HAR\ Dataset/train/Y_train.txt")
training_subjects    = read.table("UCI\ HAR\ Dataset/train/subject_train.txt")

# Read test data set
test_data       = read.table("UCI\ HAR\ Dataset/test/X_test.txt")
test_activities = read.table("UCI\ HAR\ Dataset/test/Y_test.txt")
test_subjects   = read.table("UCI\ HAR\ Dataset/test/subject_test.txt")

# Merge training & test data sets
merged_data       = rbind(training_data, test_data)
merged_activities = rbind(training_activities, test_activities)
merged_subjects   = rbind(training_subjects, test_subjects)

#
# 2. Extract only the measurements on the mean and standard 
#    deviation for each measurement
#

# Read the features data
features = read.table("UCI\ HAR\ Dataset/features.txt")

# Extract the features we want, those with mean() or std() in their names
wanted_features = grep("-(mean|std)\\(\\)", features[, 2])

# Subset the merged data to get just the data we want
mean_and_std_data = merged_data[, wanted_features]

# Fix up the the column names
names(mean_and_std_data) = features[wanted_features, 2]

#
# 3. Use descriptive activity names to name the activities in the data set
#

# Read the activity names
activities = read.table("UCI\ HAR\ Dataset/activity_labels.txt")

# Fix up activity names
merged_activities[, 1] = activities[merged_activities[, 1], 2]

# Fix up activity column name
names(merged_activities) = "activity"

#
# 4. Appropriately label the data set with descriptive variable names.
#

# Correct subject column name
names(merged_subjects) = "subject"

# Create single data set
data = cbind(mean_and_std_data, merged_activities, merged_subjects)

# Tidy variable names
names(data) = gsub("^t",          "time",          names(data))
names(data) = gsub("^f",          "frequency",     names(data))
names(data) = gsub("Acc",         "Accelerometer", names(data))
names(data) = gsub("Mag",         "Magnitude",     names(data))
names(data) = gsub("BodyBody",    "Body",          names(data))
names(data) = gsub("-std\\(\\)",  "Std",           names(data))
names(data) = gsub("-mean\\(\\)", "Mean",          names(data))

#
# 5. From the data set in step 4, create a second, independent tidy 
#    data set with the average of each variable for each activity and 
#    each subject
#

# Load plyr library
library(plyr);

# Calculate average of each variable for each activity and each subject 
averages_data = aggregate(. ~subject + activity, data, mean)

# Re-order averages dataset by Subject, Activity
averages_data = averages_data[order(averages_data$subject,averages_data$activity),]

# Create output file
write.table(averages_data, file = "tidydata.txt",row.name=FALSE)
