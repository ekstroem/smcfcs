#set random number seed to make results reproducible
set.seed(123)

#linear substantive model with quadratic covariate effect
imps <- smcfcs(ex_linquad, smtype="lm", smformula="y~z+x+xsq",
               method=c("","","norm","x^2",""))

#if mitools is installed, fit substantive model to imputed datasets
#and combine results using Rubin's rules
if (requireNamespace("mitools", quietly = TRUE)) {
  library(mitools)
  impobj <- imputationList(imps$impDatasets)
  models <- with(impobj, lm(y~z+x+xsq))
  summary(MIcombine(models))
}

#the following examples are not run when the package is compiled on CRAN
#(to keep computation time down), but they can be run by package users
\dontrun{
  #examining convergence, using 100 iterations, setting m=1
  imps <- smcfcs(ex_linquad, smtype="lm", smformula="y~z+x+xsq",
                 method=c("","","norm","x^2",""),m=1,numit=100)
  #convergence plot from first imputation for third coefficient of substantive model
  plot(imps$smCoefIter[1,3,])

  #include auxiliary variable assuming it is conditionally independent of Y (which it is here)
  predMatrix <- array(0, dim=c(ncol(ex_linquad),ncol(ex_linquad)))
  predMatrix[3,] <- c(0,1,0,0,1)
  imps <- smcfcs(ex_linquad, smtype="lm", smformula="y~z+x+xsq",
                 method=c("","","norm","x^2",""),predictorMatrix=predMatrix)

  #impute missing x1 and x2, where they interact in substantive model
  imps <- smcfcs(ex_lininter, smtype="lm", smformula="y~x1+x2+x1x2",
                 method=c("","norm","logreg","x1*x2"))

  #logistic regression substantive model, with quadratic covariate effects
  imps <- smcfcs(ex_logisticquad, smtype="logistic", smformula="y~z+x+xsq",
                 method=c("","","norm","x^2",""))

  #Cox regression substantive model, with only main covariate effects
  library(survival)
  imps <- smcfcs(ex_coxquad, smtype="coxph", smformula="Surv(t,d)~z+x+xsq",
                 method=c("","","","norm","x^2",""))

  #competing risks substantive model, with only main covariate effects
  imps <- smcfcs(ex_compet, smtype="compet",
                 smformula=c("Surv(t,d==1)~x1+x2", "Surv(t,d==2)~x1+x2"),
                 method=c("","","logreg","norm"))

  #if mitools is installed, fit model for first competing risk
  if (requireNamespace("mitools", quietly = TRUE)) {
    library(mitools)
    impobj <- imputationList(imps$impDatasets)
    models <- with(impobj, coxph(Surv(t,d==1)~x1+x2))
    summary(MIcombine(models))
  }

  #covariate measurement error, logistic regression substantive model
  errMat <- matrix(0, nrow=4, ncol=4)
  errMat[2,c(3,4)] <- 1

  #impute, but specify a larger number of iterations than with
  #regular missing data
  imps <- smcfcs(ex_coverr, smtype="logistic", smformula="y~x",
                 method=c("","latnorm","",""),
                 errorProneMatrix=errMat,numit=100)

  #examine convergence for second parameter in logistic model, using
  #estimates from first imputation
  plot(imps$smCoefIter[1,2,])

  if (requireNamespace("mitools", quietly = TRUE)) {
    library(mitools)
    impobj <- imputationList(imps$impDatasets)
    models <- with(impobj, glm(y~x,family=binomial))
    summary(MIcombine(models))
  }

}
