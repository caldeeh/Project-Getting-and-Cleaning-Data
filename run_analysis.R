##1.1 Download file

if (!file.exists("./data")) {dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/UCIHARDataset.zip")

##1.2 Unzip the file and get the list of unzipped files.

unzip("data/UCIHARDataset.zip", exdir = "./data")

files <- list.files("data/", recursive = TRUE)
files

#2. Read data from the files.
##2.1 Prepare for read data.

file_Path <- "data/UCI HAR Dataset/"
test_Path <- "data/UCI HAR Dataset/test/"
train_Path <- "data/UCI HAR Dataset/train/"

##2.1 Read the "x" files.

x_Test <- read.table(file.path(test_Path, "X_test.txt"))
x_Train <- read.table(file.path(train_Path, "X_train.txt"))

##2.2 Read the "y" files.

y_Test <- read.table(file.path(test_Path, "y_test.txt"))
y_Train <- read.table(file.path(train_Path, "y_train.txt"))

##2.3 Read the "subject" files.

subject_Test <- read.table(file.path(test_Path, "subject_test.txt"))
subject_Train <- read.table(file.path(train_Path, "subject_train.txt"))

#3. Merges the training and the test sets to create one data set.

##3.1 Create "x, y, subject" data.

x_Data <- rbind(x_Test, x_Train)
y_Data <- rbind(y_Test, y_Train)
subject_Data <- rbind(subject_Test, subject_Train)

##3.2 Set names to variables.

names(subject_Data) <- c("subject")
names(y_Data) <- c("activity")
features_Data <- read.table(file.path(file_Path, "features.txt"))
names(x_Data) <- features_Data$V2

##3.3 Create one data set for all data.

pre_Data <- cbind(subject_Data, y_Data)
Data <- cbind(x_Data, pre_Data)

#4. Extracts only the measurements on the mean and standard deviation for each measurement.

##4.1 Get names of features with mean() or std().

ms_Features <- features_Data$V2[grep("mean\\(\\)|std\\(\\)", features_Data$V2)]

##4.2 Subset the "Data".

selected_Names <- c(as.character(ms_Features), "subject", "activity")
Data <- subset(Data, select = selected_Names)

#5. Uses descriptive activity names to name the activities in the data set.

##5.1 Read "activity_lables" data.

activity_Data <- read.table(file.path(file_Path, "activity_labels.txt"))

##5.2 Update values with correct activity names.

Data$activity <- factor(Data$activity, labels = activity_Data$V2)

#6 Appropriately labels the data set with descriptive variable names. 

#In the former part, variables activity and subject and names of the activities have been labelled using descriptive names.In this part, Names of Feteatures will labelled using descriptive variable names.
#.prefix t is replaced by time
#.Acc is replaced by Accelerometer
#.Gyro is replaced by Gyroscope
#.prefix f is replaced by frequency
#.Mag is replaced by Magnitude
#.BodyBody is replaced by Body

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#7.Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(plyr);
tidy_Data<-aggregate(. ~subject + activity, Data, mean)
tidy_Data<-tidy_Data[order(tidy_Data$subject,tidy_Data$activity),]
write.table(tidy_Data, file = "tidydata.txt",row.name=FALSE)
