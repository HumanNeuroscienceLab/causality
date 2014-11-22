#--- VAR ---#

# Borrowed from AFNI's 1dGC.R

library(vars)

# We want to first identify the optimal number of lags
critSel <- VARselect(newData, lag.max = 3, type = "none")

# Here, we will always choose the maximum one
print(critSel$selection)
nLags <- max(critSel$selection)

# Our AR model!
fm <- VAR(newData, p=nLags, type="none", exogen=exMatMod)

if (qualityCheck) { # check the quality of the residuals in terms of not being serially correlated
  # the modulus of the eigenvalues (presumably less than 1 as stable condition) in the reverse characteristic polynomial; stable process is stationary, but the converse is not true
  #print("Quality check of the model:")
  if (prod(roots(fm)<1)) print("Eigenvalues of the companion coefficient matrix indciate that the VAR(p) process is stable and thus stationary") else print("The VAR(p) process seems unstable and thus is not stationary")
  print("-----------------")
  print("Normality testing of the residuals")
  print(normality.test(fm))
  print("-----------------")
  print("Serial correlation test:")
  print(serial.test(fm, lags.pt=16, lags.bg=5, type=c("PT.asymptotic")))
  print(serial.test(fm, lags.pt=16, lags.bg=5, type=c("PT.adjusted")))
  print(serial.test(fm, lags.pt=16, lags.bg=5, type=c("BG")))
  print(serial.test(fm, lags.pt=16, lags.bg=5, type=c("ES")))
  print("-----------------")
  print("Autoregressive conditional heteroskedasticity (ARCH) test")
  print(arch.test(fm))
}

# spill out the original path matrix with direction going from rows to columns
netMatR <- array(data=NA, dim=c(nLags, nROIs, nROIs))   # original path coefficient matrix
netMatT <- array(data=NA, dim=c(nLags, nROIs, nROIs))   # t values matrix
for (ii in 1:nROIs) for (jj in 1:nROIs) for (kk in 1:nLags)  { # ii: target, jj: source, kk: lag
  netMatR[kk,jj,ii] <- coef(fm)[[ii]][jj+nROIs*(kk-1), 1]  # path coefficients
  netMatT[kk,jj,ii] <- coef(fm)[[ii]][jj+nROIs*(kk-1), 3]  # t values
}

# should also be able to get the residuals with resids
