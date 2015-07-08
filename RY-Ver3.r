- All 28 factors produce best results
- Often DT better on Engine 1, but NB better on Engine 2 and 3! 
- NOTE: Engine 2 and 3 probably have different signatures. Model was built on Engine 1
- NB predicts Normal state better
- 1 and 3 Factors models did NOT do too well - often showing only 50-60 % accuracy

#---------------------------------------------------------------------------------------------------
# YANMAR R code
# 08-July-2015
# Ver: 3.0
#          - New data files: 55 K
# Ver. 3.1: Factor 10. Failed part. 
#---------------------------------------------------------------------------------------------------

# Load libraries
library(caret) 
library(rpart) 					# Decision Trees
library(randomForest) 	# Random Forests	
library(e1071)					# Naive Bayes

printf <- function(...) cat(sprintf(...))

# Load the raw data files
flush.console()
printf("\n\n ------------------------------------------------------")
printf("\n ---------- YANMAR PROJECT 08-JULY-2015 ---------------")
printf("\n ------------------------------------------------------")
printf("\n\n -- New data: 08-July-2015\n")

print ("Load the raw data files...")
trainingDF <- read.csv("Engine1ML-TrainingData.csv", header = TRUE) 
testingDF  <- read.csv("Engine1ML-TestDataNoLabels.csv", header = TRUE)

# Check NORMAL state from Engine 3 data:
testE3  <- read.csv("Engine3TestData.csv", header = TRUE)


#-------------------------------------------------------------------------------------------------------------
# PHASE 1: DATA CLEANSING: 
#-------------------------------------------------------------------------------------------------------------
print ("Clean the data set...")
ntrainingDS <- trainingDF[, 2:ncol(trainingDF)] 
ntrainingDS$STATE <- as.factor(ntrainingDS$STATE)

#-------------------------------------------------------------------------------------------------------------
# PHASE 3: MODEL CREATION
#-------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------
# Data set looks ok. Using a 60:40 ratio split into training (trainingDS) and validation sets (validationDS)
#------------------------------------------------------------------------------------------------------------
set.seed(0807) 

print("Create data partition, create a Training and Validation data set...")
trainingIndex <- createDataPartition(ntrainingDS$STATE, p = 0.6, list=FALSE) 
trainingNDS <- ntrainingDS[trainingIndex,] 
validationNDS <- ntrainingDS[-trainingIndex,]

# Method 1: Decision tree
printf("\n\n-----------------------------------------------------------")
printf("\nDecision Trees: Training and creating model...")
modFitDT <- rpart(STATE ~ ., data=trainingNDS, method="class")
predictionsDT <- predict(modFitDT, trainingNDS, type = "class")
cmDT <- confusionMatrix(predictionsDT, trainingNDS$STATE)
print(cmDT);
errorDT <- 1-cmDT$overall[1]
cat ("Press [enter] to continue")
line <- readline()

# Method 2: Naive Bayes
printf("\n\n-----------------------------------------------------------")
printf("\nNaive Bayes: Training and creating model...")
printf("\n [Use Laplace estimator default]")
modFitNB <- naiveBayes(trainingNDS, trainingNDS$STATE, laplace=0)
predictionsNB <- predict(modFitNB, trainingNDS, type = "class")
print(confusionMatrix(predictionsNB, trainingNDS$STATE))
cat ("Press [enter] to continue")
line <- readline()

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
cmDT_V <- confusionMatrix(predictionsDT_V, validationNDS$STATE)
errorDT_V <- 1-cmDT_V$overall[1]
printf("\nDecision Tree Error percentage: %2.2f", errorDT_V * 100);

predictionsNB_V <- predict(modFitNB, validationNDS, type = "class") 
cmNB_V <- confusionMatrix(predictionsNB_V, validationNDS$STATE)
errorNB_V <- 1-cmNB_V$overall[1]
printf("\nNaive Bayes Error percentage  : %2.2f", errorNB_V * 100);
printf("\n-----------------------------------------------------------\n\n")
cat ("Press [enter] to continue")
line <- readline()

#-------------------------------------------------------------------------------------------------------------
# PHASE 5: PREDICT NEW VALUES USING THE MODEL
#   Use the final selected Random Forest model to predict on test data
#-------------------------------------------------------------------------------------------------------------
printf("\n DT: Print final predictions...")
predictionsFinal <- predict(modFitDT, testingDF, type = "class")
predictionsFinal
pf <- predictionsFinal
pf <- cbind(pf,testingDF$Record)

predictionsFinalNB <- predict(modFitNB, testingDF, type = "class")
printf ("\n NB: Print final predictions...")
predictionsFinal

write.csv(predictionsFinal,   "E1DTPredictions.csv")
write.csv(predictionsFinalNB, "E1NBPredictions.csv")

#-------------------------------------------------------------------------------------------------------------
# Check ENGINE 3 normal state readings. Test set 1000 records
#-------------------------------------------------------------------------------------------------------------
printf("\n DT: Test model on Engine 3 Normal state data...")
predictionsDTE3 <- predict(modFitDT, testE3, type = "class")

printf("\n NB: Test model on Engine 3 Normal state data...")
predictionsNBE3 <- predict(modFitNB, testE3, type = "class")

write.csv(predictionsDTE3, "E3DTPredictions.csv")
write.csv(predictionsNBE3, "E3NBPredictions.csv")

#-------------------------------------------------------------------------------------------------------------
# Check ENGINE 2 normal state readings. Test set 3000 records
#-------------------------------------------------------------------------------------------------------------
# Check NORMAL state from Engine 3 data:
testE2  <- read.csv("Engine2Data3K.csv", header = TRUE)

printf("\n DT: Test model on Engine 2 Normal state data...")
predictionsDTE2 <- predict(modFitDT, testE2, type = "class")

printf("\n NB: Test model on Engine 2 Normal state data...")
predictionsNBE2 <- predict(modFitNB, testE2, type = "class")

write.csv(predictionsDTE2, "E2DTPredictions.csv")
write.csv(predictionsNBE2, "E2NBPredictions.csv")

