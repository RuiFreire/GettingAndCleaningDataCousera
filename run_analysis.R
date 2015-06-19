
# You should create one R script called run_analysis.R that does the following. 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the 
#    average of each variable for each activity and each subject.


#################################################################
# 1. Merges the training and the test sets to create one data set.
#################################################################

## Reading all test DataSets
dt_subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
dt_X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
dt_y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

## Reading all train DataSets
dt_subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
dt_X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
dt_y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

# add a column typeofdata with level "test" to dt_subject_test
# and a column typeofdata with  level train to dt_subject_train
#(this is not really necessary but since the data is divided 
# in test and train I think this could be useful for further analysis)
dt_subject_test["TypeOfData"] = as.factor("test")
dt_subject_train["TypeOfData"] = as.factor("train")

# Merge all the above data sets and store them in dt_all
dt_all = rbind( cbind( dt_subject_test, dt_y_test, dt_X_test ),
                cbind( dt_subject_train, dt_y_train, dt_X_train ) )

###########################################################################################
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
###########################################################################################


## In this step I will make use of the features.txt file because
## it contains the variable names I need, although not properly formatted.
## I start by storing them in a small dataset called dt_features.
dt_features = read.table("./UCI HAR Dataset/features.txt")

## dt_features[,2] has the names I wont for the variables.
## Now I make a subset of dt_features maintaining all
## rows which the values are the words mean or std but not meanFreq neither angle
## For more information on this, please see the readme.txt
dt_features = subset(dt_features, ( grepl("mean",dt_features[,2], ignore.case = TRUE) & !grepl("meanFreq",dt_features[,2]) & !grepl("angle",dt_features[,2]) ) |  
                                    grepl( "std",dt_features[,2], ignore.case = TRUE ) )
                                                         
## Now that I have a dt_features with only names of means and std in his rows
## I can use the indexes (stored on dt_features[,1]) to extract the columns I need from dt_all
## So I extract from dt_all the 3 first columns that are the subject ID, type of data and activity
## followed by dt_features[,1] plus 3, because the indexes on dt_features[,1] will
## only match with the right columns of dt_all if I add them 3
dt_mean_std = dt_all[, c(1,2,3,(3 + dt_features[,1])) ]

###########################################################################
# 3. Uses descriptive activity names to name the activities in the data set
###########################################################################

# The activity label is in the form of a integer 
# where 1 corresponds to  WALKING, 2 to WALKING_UPSTAIRS... and so on
# But I want them in the form of factor with properly names.
# sO first I coarse into a factor dt_mean_std[,3] column (the column that stores
# the activities variable)  
dt_mean_std[,3] <- factor(dt_mean_std[,3])
## Then I load the activity_labels.txt which contains properly activities names
## and store them in a small data set called dt_activities
## The names will be stored in dt_activities[,2]
dt_activities <- read.table(file="UCI HAR Dataset/activity_labels.txt")
# I then apply the levels funtion to dt_mean_std[,3], using dt_activities[,2] as names for the levels
levels(dt_mean_std[,3]) = as.character(dt_activities[,2])

#######################################################################
# 4. Appropriately labels the data set with descriptive variable names. 
#######################################################################

# If you see dt_mean_std now, you will see that it's columns
# don't have any descriptive names.So let's give them properly names
# For more information about what I consider a properly name
# please see the readme.txt

# First remember that the variables names still in the dt_features data set
# so lets just make those variable names more properly to use.
dt_features[,2] <- sapply( dt_features[,2], function(x) {
          
         x <- gsub("\\(","",x) #regular labels don't have brackets
         x <- gsub("\\)","",x) #regular labels don't have brackets
         x <- gsub(",","",x) #regular labels don't have comma
         x <- gsub("-","",x) #regular labels don't have hyphen
         x <- gsub("mean","Mean",x) 
         x <- gsub("std","Std",x)
                  
 } )
 
# Now Let's apply dt_features[,2] to the columns of dt_mean_std
# as well as properly names to the first three columns (subjectId, TypeOfData and Activity)
colnames(dt_mean_std) = c("SubjectId", "TypeOfData", "Activity", dt_features[,2])

#######################################################################################
# 5. From the data set in step 4, creates a second, independent tidy data set with the 
#    average of each variable for each activity and each subject.
######################################################################################


# In this final step I create the tidy data set, using the aggregate function
# This function Groups the variables first by SubjectID,
# Inside the same SubjectID the function the Groups by TypeOfData,
# But since for a specific SubjectID there is only one type of data (test or train)
# there will be no grouping inside TypeOfData. Finally for the same TypeOfData
# the aggregate function groups by Activity
# The aggregate function applies then the mean function to each values of a variable
# that as the same SubjectID, same TypeOfData and same Activity

dt_tidy <- aggregate( dt_mean_std[,!(names(dt_mean_std) %in% c("SubjectId","TypeOfData","Activity"))],
                      
                       list( 
                             Activity = dt_mean_std$Activity, 
                             TypeOfData = dt_mean_std$TypeOfData,
                             SubjectId = dt_mean_std$SubjectId),
                          
                       FUN = mean )

# Now I swap the first with the third columns to maintain the initial order
dt_tidy <- dt_tidy[ , c(3,2,1,4:ncol(dt_tidy))]


# Finally I write the data in a txt file called tidy_data.txt 
write.table(dt_tidy,file="tidy_data.txt",row.name=FALSE)

