
In order to use the following script, you need to:

1. Place both run_analysis.R script and UCI HAR Dataset in the same folder
2. Set the working directory to the above folder
3. The script will end by creating a tidy data set named dt_tidy and write it in a data_tidy.txt file in the folder. 
   Although it's is better if you run the script and analyse the the tidy_data data set instead of the .txt file. 
 
The run_analysis.R script does the five requested steps in the following order
 
 1. Merges the training and the test sets to create one data set.
 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
 3. Uses descriptive activity names to name the activities in the data set
 4. Appropriately labels the data set with descriptive variable names. 
 5. From the data set in step 4, creates a second, independent tidy data set with the 
    average of each variable for each activity and each subject.


**1. Merges the training and the test sets to create one data set.**
	
The script starts by loading all the data sets and merge them like
building blocks that match together, creating a final data set (dt_all)

It's also added a new factor variable to dt_subject_test called TypeOfData with the levels test and train
This variable is fully optional and is just to inform if a subject was submitted to a test or a train

The blocks are merged in this form: 

dt_all =

         |------------------|TypeOfData|------------|------------|
         | dt_subject_test  |   test   | dt_y_test  | dt_X_test  |
		 |------------------|----------|------------|------------|
		 | dt_subject_train |   train  | dt_X_train | dt_X_train |
         |------------------|----------|------------|------------|		 
		 

**2. Extracts only the measurements on the mean and standard deviation for each measurement.**
		 
In this step the content of features_info.txt is loaded and stored in a small data set called dt_features.
I then subset dt_features to obtain only the rows that have a word that matches **mean** or **std**.

I exclude the words **meanFreq** and **angle** for this two reasons:
**meanFreq**  it is not a mean but a weighted average and **angle** because although is estimated using means is not a mean per si.
Regard that is a personal opinion.
You might have one other perspective of things that is also plausible or even more correct than mine.

To see a table with all the variables I choose and it's description please see the codebook.md file

dt_features will have the following form:

dt_features =

			  |---|---------------------------------|
              | 1 |       tBodyAcc-mean()-X         |
			  |---|---------------------------------|
              | 2 |       tBodyAcc-mean()-Y         |
			  |---|---------------------------------|
			                     ...
			  |---|---------------------------------|
        	  |543|   fBodyBodyGyroJerkMag-std()    |
			  |---|---------------------------------|

I then use the first columns of dt_features (the indexes) to extract the columns I want from dt_all
and store them in a new data set called dt_mean_std

dt_mean_std =

         |------------------|TypeOfData|------------| 1 | 2 |... |543|
         | dt_subject_test  |   test   | dt_y_test  |   dt_X_test    |
		 |------------------|----------|------------|----------------|
		 | dt_subject_train |   train  | dt_X_train |   dt_X_train   |
         |------------------|----------|------------|----------------|		

**3. Uses descriptive activity names to name the activities in the data set**		 

Next step is giving properly names to the activities.
 
The activity label is in the form of a integer 
where 1 corresponds to  WALKING, 2 to WALKING_UPSTAIRS... and so on
But I want them in the form of factor with properly names.
So first I coarse dt_mean_std[,3] (the column that stores
the activities variable values) in to a factor.

Then I load the activity_labels.txt which contains properly activities names
and store them in a small data set dt_activities

dt_activities =

			  |---|------------------|
              | 1 |     WALKING      |
			  |---|------------------|
              | 2 | WALKING_UPSTAIRS |
			  |---|------------------|
			             ...
			  |---|------------------|
        	  | 6 |     LAYING       |
			  |---|------------------|


The names I need are stored in dt_activities[,2]
I then apply the levels function to dt_mean_std[,3], using dt_activities[,2] as names
This will give to dt_mean_std[,3] values descriptive and properly names. 

dt_mean_std =

         |------------------|TypeOfData|------------| 1 | 2 |... |552|
         | dt_subject_test  |   test   |   WALKING  |   dt_X_test    |
		 |------------------|----------|   WALKING  |----------------|
		 | dt_subject_train |   train  |     ...    |   dt_X_train   |
         |------------------|----------|------------|----------------|	
		 
**4. Appropriately labels the data set with descriptive variable names.**

I consider properly names variables, names without brackets, commas, hyphens and not to much abbreviated. 
So I run through dt_features[,2] and use the gsub function to extract brackets, commas, hyphens and make sure that
words like Mean and Std are in upper case  

dt_features has now the form:

dt_features =

			 |---|------------------------------|
             | 1 |       tBodyAccMeanX          |
			 |---|------------------------------|
             | 2 |       tBodyAccMeanY          |
			 |---|------------------------------|
			                  ...
			 |---|------------------------------|
        	 |552| fBodyBodyGyroJerkMagMeanFreq |
			 |---|------------------------------|


Now it's only a matter of giving properly names to the three first columns of dt_mean_std (SubjectID, TypeOfData, Activity)
and attribute dt_features[,2] to the rest of the columns of dt_mean_std using the colnames function.

dt_mean_std looks like this now:

dt_mean_std = 

         |    SubjectID     |TypeOfData|  Activity  | tBodyAccMeanX  | tBodyAccMeanY  |... |fBodyBodyGyroJerkMagMeanFreq|
         | dt_subject_test  |   test   |   WALKING  |                     dt_X_test                                     |
		 |------------------|----------|   WALKING  |-------------------------------------------------------------------|
		 | dt_subject_train |   train  |     ...    |                     dt_X_train                                    |
         |------------------|----------|------------|-------------------------------------------------------------------|	

		 
**5.From the data set in step 4, creates a second, independent tidy data set with the
    average of each variable for each activity and each subject.**
		  
In this final step I create the tidy data set, using the aggregate function.

I choose to use this function so you don't need to install any specific package.

The aggregate function groups the variables first by SubjectID.
Inside the same SubjectID the aggregate function groups by TypeOfData.
Since for a specific SubjectID there is only one type of data (test or train)
there will be no grouping inside TypeOfData. 
Finally for the same TypeOfData the aggregate function groups by Activity.
The aggregate function then applies the mean function to each values of a variable
that has the same SubjectID, same TypeOfData and same Activity

The only problem using aggregate function is that now I need to reverse the order of the 
first 3 columns so I can maintain the initial order, which I easily did using a final subset
and changing the columns order.

This is the final form of dt_tidy.

dt_tidy = 

         |    SubjectID     |TypeOfData|     Activity     | tBodyAccMeanX  | tBodyAccMeanY  |... |fBodyBodyGyroJerkMagMeanFreq|
         |        1         |   test   |      WALKING     |                                                        
		 |        1         |          | WALKING_UPSTAIRS |
		 |        1         |   ...    |WALKING_DOWNSTAIRS|                                                     
         |        1         |          |     SITTING      |
		 |        1         |          |     STANDING     |
		 |        1         |   test   |     LAYING       |
		 |------------------|----------|------------------|--------------------------------------------------------------------
		 |        2         |   train  |     WALKING      |
		 |       ...        |    ...   |       ...        |
		 |                  |          |                  |
	     |        30        |   train  |      LAYING      |
		 
		 
Finally I write the dt_tidy data set in a .txt file using the write.table function.
