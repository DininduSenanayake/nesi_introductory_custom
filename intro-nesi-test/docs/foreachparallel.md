Focusing on R, one may think on two general types of parallelising scripts. First, 'internal' parallelisation within your script can be accomplished using `foreach` and `doParallel` packages, or alternatively via functions that incorporate internal parallelisation schemes such as `brm` from package `brms`. Second, external parallelisation can be done via setting up a slurm job array. 


>Follow up comment to `foreachdoparallel.R` script 

The first interesting part is setting up the number of workers. Hardly-coding it is appropriate, obviously, when you know in advance how many jobs you want to distribute for your loop. In a single computer, this is all that is needed, but below I explore how to combine this with the options from SLURM to actually use as many CPUs as needed, distributed among different nodes of a cluster. But first, let’s look at the structure of `foreach`. Despite its name, which reminds of a `for` loop, `foreach` is better thought of as a parallelized version of `apply` functions. Note that, first of all, a `foreach` loop returns an object, unlike standard `for` loops. Thus, inside the loop there will be some calculations and, importantly, the returning object (in this example, `coefficients(result1)`). Each iteration of the loop generates an instance of the object returned, and an important point is that `foreach` combines the result from all these iterations through the `.combine` argument. By default, `foreach` loops return a list with as many elements as iterations. Aside from lists, one may want to append the results of each iteration as columns to a dataframe, as in this example, or as rows (`rbind`), but more complex options are also possible. For example, if you want to return two different dataframes, that are to be combined row-wise, you need to define a tailored combine function and specify that function in the `foreach` call:

```R
comb.fun <- function(...) {
  mapply('rbind', ..., SIMPLIFY=FALSE)
}

x <- iris[which(iris[,5] != "setosa"), c(1,5)]
trials <- 1000

r <- foreach(icount(trials), 
             .combine=comb.fun) %dopar% {
               ind <- sample(100, 100, replace=TRUE)
               result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
               df1 <- data.frame(intercept = coefficients(result1)[1], 
                                 slope = coefficients(result1)[2],
                                 row.names = NULL)
               df2 <- data.frame(x = rnorm(1,0,1), y = runif(1,0,1))
               list(df1,df2)
             }

# the object returned is a list
head(r[[1]])
```