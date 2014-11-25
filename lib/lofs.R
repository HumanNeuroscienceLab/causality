# For each node, we look at all elements that are connected to that node. we ask for all combinations of those elements and regress them on our node, and ask what combination gives a residual with the most non-gaussian distribution
library(nortest)
library(plyr)

NG <- function(x) as.numeric(ad.test(x)$statistic)

calc_residuals <- function(y, X) {
  if (!is.matrix(y))
    y <- as.matrix(y)
  if (!is.matrix(X))
    X <- as.matrix(X)
  
  # beta values
  iXtX <- solve(t(X) %*% X)
  b <- iXtX %*% t(X) %*% y
  
  # residuals
  res <- y - X %*% b
  
  return(res)
}

#' Rule 1 for LOFS
#'
#' TODO
#'
#' @param S adjacency matrix of all connections between nodes (nnodes x nnodes)
#' @param dat matrix of time-series (ntpts x nnodes)
#' @return G matrix with connections in S oriented
#'
#' @references
#' TODO
#'
lofs.r1 <- function(S, dat, .NG=NG) {  
  nnodes  <- ncol(dat)
  
  # standardize
  dat     <- scale(dat)
  
  # output matrix
  G       <- matrix(0, nnodes, nnodes)
  
  # no self-nodes
  diag(S) <- 0
  
  for (i in 1:nnodes) {
    possible_parents <- which(S[,i]>0)
    
    # want to get every possible combination of parent nodes
    combos <- llply(1:length(possible_parents), function(j) {
      combn(possible_parents, j, simplify=F)
    })
    combos <- unlist(combos, recursive=F)
    
    # regress on node with possible parent combos
    # and get the non-gaussianity of the residuals
    ngs <- sapply(combos, function(inds) {
      resids <- calc_residuals(dat[,i,drop=F], dat[,inds,drop=F])
      .NG(resids)
    })
    
    # get non-gaussianity without anything
    self_ng <- .NG(dat[,i])
    
    # which node has the maximum non-gaussianity?
    # and greater than empty set
    max_ind <- which.max(ngs)
    if (ngs[max_ind] > self_ng) {
      G[combos[[max_ind]],i] <- S[combos[[max_ind]],i]
    }
  }
  
  return(G)
}

#' Rule 2 for LOFS
#' 
#' Basically for this one, I want to take the combo approach from lofs1
#' except that this time would want to do both directions X<-Y and Y->X
#' save each of those scores.... calculation for the score shoud be looked up
lofs.r2 <- function(S, dat, .NG=NG) {
  nnodes  <- ncol(dat)
  
  # standardize
  dat     <- scale(dat)
  
  # no self-nodes in input adjacency
  diag(S) <- 0
  
  
}

#' Rule 3 for LOFS
lofs.r3 <- function(S, dat, .NG=NG) {
  nnodes  <- ncol(dat)
  
  # standardize
  dat     <- scale(dat)
  
  # no self-nodes in input adjacency
  diag(S) <- 0
  
  # output matrix
  G       <- matrix(0, nnodes, nnodes)
  
  # get i,j coordinates for edges
  inds    <- which(upper.tri(G) & S==1)
  coords  <- expand.grid(list(i=1:nnodes, j=1:nnodes))
  coords  <- coords[inds,]
  
  # Loop through each edge
  for (ii in seq_along(inds)) {
    i <- coords$i[ii]; j <- coords$j[ii]
    X <- dat[,i]; Y <- dat[,j]
    
    # X <- Y
    # if NG(X,Y) + NG(Y) > NG(Y,X) + NG(X)
    # X -> Y
    # if NG(X,Y) + NG(Y) < NG(Y,X) + NG(X)
    toX <- .NG(calc_residuals(X,Y)) + .NG(Y)
    toY <- .NG(calc_residuals(Y,X)) + .NG(X)
    if (toX > toY) {
      G[i,j] <- 1
    } else {
      G[j,i] <- 1
    }
  }
  
  return(G)
}


#' Rule 4 for LOFS
#'
#' TODO
#'
#' @param S adjacency matrix of all connections between nodes (nnodes x nnodes)
#' @param dat matrix of time-series (ntpts x nnodes)
#' @param epsilon threshold for weighted matrix (default=0.1)
#' @param zeta range for free parameter, -zeta to zeta (default=1)
#' @param .NG function that measures the non-gaussianity of the data (default=NG aka the anderson-darling test)
#' @param add.self whether to have 1s in the diagonal of the weighted matrix (default=TRUE)
#' @return list(W,G) W weighted and G unweighted matrix with connections in S oriented
#'
#' @references
#' TODO
#'
lofs.r4 <- function(S, dat, epsilon=0.1, zeta=1, .NG=NG, add.self=TRUE) {
  nnodes  <- ncol(dat)
  
  # standardize
  dat     <- scale(dat)
  
  # get correlation for initializing parameter search
  cordat  <- crossprod(dat)/(nrow(dat)-1)
  
  # no self-nodes in input adjacency
  diag(S) <- 0
  
  # construct W - output matrix
  W       <- matrix(0, nnodes, nnodes)
  if (add.self) diag(W) <- 1
  W[S!=0] <- NA
  
  # function to be applied to each row
  # @param wi = free parameters
  # @param X = time-series
  # @param Wi = row of matrix W
  fun <- function(wi, X, Wi) {
    Wi[is.na(Wi)] <- wi
    .NG(Wi %*% t(X))
    sum(wi)
  }
  
  # Loop through each row
  for (i in 1:nnodes) {
    inds  <- which(S[i,] > 0)
    # determine weights for free parameters while maximizing NG
    res   <- optim(cordat[i,inds], fun, 
                   X=dat, Wi=W[i,], 
                   method="L-BFGS-B", control=list(fnscale=-1), 
                   lower=-zeta, upper=zeta)
    # assign optimized weights
    W[i,inds] <- res$par
  }
  
  # Threshold W to get G
  G <- (W > epsilon) * 1
  
  list(W=W, G=G)
}

