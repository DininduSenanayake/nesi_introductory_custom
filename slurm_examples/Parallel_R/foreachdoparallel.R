#The key here is to generate a number of jobs, assign them to actual cores, and split foreach loops among these jobs. 
#A basic skeleton of such workflow, in Linux, is:

# load packages -----------------------------------------------------------
library(foreach)
library(doParallel)

# set number of cores -----------------------------------------------------
workers <- 10
cl <- parallel::makeCluster(workers)
# register the cluster for using foreach
doParallel::registerDoParallel(cl)

# run some time-intensive task --------------------------------------------
x <- iris[which(iris[,5] != "setosa"), c(1,5)]
trials <- 10000

r <- foreach(icount(trials), 
             .combine=cbind) %dopar% {
               ind <- sample(100, 100, replace=TRUE)
               result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
               coefficients(result1)
             }
