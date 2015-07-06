#---------------------------------------------------------------------------------------------------
# YANMAR R code
# 06-July-2015
# Ver: 1.0
#
#---------------------------------------------------------------------------------------------------

# Load libraries
library(lattice) 
library(ggplot2)
library(caret) 
library(rpart) 					# Decision Trees
library(randomForest) 	# Random Forests	
library(e1071)					# Naive Bayes

printf <- function(...) cat(sprintf(...))

# Load the raw data files
flush.console()

printf ("\n\n\n -- Train and Test V3 files\n Ver 3.0 Test file does NOT contain labels\n")
print ("Load the raw data files...")
trainingDF <- read.csv("Y1EWS-TrainingV3.csv", header = TRUE) 
testingDF  <- read.csv("Y1EWS-TestingV3_NOEWS.csv", header = TRUE)

#-------------------------------------------------------------------------------------------------------------
# PHASE 1: DATA CLEANSING: 
#-------------------------------------------------------------------------------------------------------------
print ("Clean the data set...")
ntrainingDS <- trainingDF[, 2:ncol(trainingDF)] 
ntrainingDS$EWS <- as.factor(ntrainingDS$EWS)

#-------------------------------------------------------------------------------------------------------------
# PHASE 3: MODEL CREATION
#-------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------
# Data set looks ok. Using a 60:40 ratio split into training (trainingDS) and validation sets (validationDS)
#------------------------------------------------------------------------------------------------------------
set.seed(06072015) 

print("Create data partition, create a Training and Validation data set...")
trainingIndex <- createDataPartition(ntrainingDS$EWS, p = 0.6, list=FALSE) 
trainingNDS <- ntrainingDS[trainingIndex,] 
validationNDS <- ntrainingDS[-trainingIndex,]

# Method 1: Decision tree
printf("\n\n-----------------------------------------------------------")
printf("\nDecision Trees: Training and creating model...")
modFitDT <- rpart(EWS ~ ., data=trainingNDS, method="class")
predictionsDT <- predict(modFitDT, trainingNDS, type = "class")
cmDT <- confusionMatrix(predictionsDT, trainingNDS$EWS)
print(cmDT);
errorDT <- 1-cmDT$overall[1]

# Method 2: Naive Bayes
printf("\n\n-----------------------------------------------------------")
printf("\nNaive Bayes: Training and creating model...")
printf("\n [Use Laplace estimator default]")
modFitNB <- naiveBayes(trainingNDS, trainingNDS$EWS, laplace=0)
predictionsNB <- predict(modFitNB, trainingNDS, type = "class")
print(confusionMatrix(predictionsNB, trainingNDS$EWS))

# --------------------------------------------------------------------------------------------------------------
# PHASE 4: MODEL ASSESSMENT CONCLUSION: Now test prediction using 
#   the Validation data set, but use previously created model (do not re-train)
#   Out-of-sample error should not exceed 10% for a good model
#   This will also test if we had over-fitted the model (as accuracy was close to 100%)
# --------------------------------------------------------------------------------------------------------------

printf("\n\n\n-----------------------------------------------------------")
printf("\nOut of Sample Error Percentages:")
printf("\n-----------------------------------------------------------")

predictionsDT_V <- predict(modFitDT, validationNDS, type = "class") 
cmDT_V <- confusionMatrix(predictionsDT_V, validationNDS$EWS)
errorDT_V <- 1-cmDT_V$overall[1]
printf("\nDecision Tree Error percentage: %2.2f", errorDT_V * 100);

predictionsNB_V <- predict(modFitNB, validationNDS, type = "class") 
cmNB_V <- confusionMatrix(predictionsNB_V, validationNDS$EWS)
errorNB_V <- 1-cmNB_V$overall[1]
printf("\nNaive Bayes Error percentage  : %2.2f", errorNB_V * 100);
printf("\n-----------------------------------------------------------\n\n")

#-------------------------------------------------------------------------------------------------------------
# PHASE 5: PREDICT NEW VALUES USING THE MODEL
#   Use the final selected Random Forest model to predict on test data
#-------------------------------------------------------------------------------------------------------------

predictionsFinal <- predict(modFitDT, testingDF, type = "class")
print ("Print final predictions: ")
predictionsFinal
pf <- predictionsFinal
pf <- cbind(pf,testingDF$ID)

write.csv(predictionsFinal, "OutputV3.csv")
write.csv(pf, "OutputV3Recs.csv")
