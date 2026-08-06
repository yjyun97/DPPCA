##------------------------------------------------------------------------------
## Samplers

fun_V_Gibbs = function(beta, k, SigmaX, N_iter = 50) {
  # Samples privatized PCs V using Gibbs sampler of Hoff 
  # Input(s): 
  # - beta: noise parameter 
  # - k: number of PCs 
  # - SigmaX: sample covariance matrix 
  # Output(s): 
  # - v_store: privatized PCs V 
  # Citation(s): 
  # - implementation of the Gibbs sampler of P. D. Hoff. Simulation of the 
  #   matrix bingham–von mises–fisher distribution, with applications to 
  #   multivariate and relational data. Journal of Computational and Graphical 
  #   Statistics, 18(2):438–456, 2009.
  p = dim(SigmaX)[1]
  A = (p * beta / 2) * SigmaX
  B = diag(rep(1, p))
  v_init = rustiefel(p, k)
  v_store = v_init
  for (i in 1:N_iter) {
    v_cur = rbing.matrix.gibbs(A, B, v_store)
    v_store = v_cur
  }
  return(v_store)
}

##------------------------------------------------------------------------------
## Privacy 

fun_sig = function(beta, k, L) {
  # Estimates level of AGDP guarantee on X 
  # Inputs:
  # - beta: noise parameter 
  # - k: number of PCs 
  # - L: vector of eigenvalues of sample covariance matrix 
  # Outputs: 
  # - sig: level of AGDP guarantee on X 
  p = length(L)
  # computes data-dependent quantities
  H = (1 / p) * sum(1 / (L[k] - L[(k + 1):p]))
  H_prime = - (1 / p) * sum(1 / ((L[k] - L[(k + 1):p]) ** 2))
  Delta = L[k] - L[k + 1]
  theta = n / (p ** (3 / 2))
  if (beta <= H) {
    print("The priacy budget cannot be satisfied!")
    return()
  }
  # computes level of AGDP guarantee 
  phase_t = - Delta * H_prime + H
  if (beta >= phase_t) {
    factor1 = 1 / (2 * Delta * theta ** 2) 
    numer = (beta - H) ** 2 
    denom = 2 * (beta - H) + Delta * H_prime 
    factor2 = numer / denom 
    sig = sqrt(factor1 * factor2) 
  } else {
    sig = sqrt(- (1 / (2 * theta ** 2)) * H_prime) 
  }
  return(sig)
}

fun_beta = function(w, k, L) {
  # Estimates noise parameter beta
  # Input(s):
  # - w: target privacy guarantee
  # - k: number of PCs 
  # - L: vector of eigenvalues of sample covariance matrix 
  # Output(s): 
  # - BX: estimate of noise parameter beta
  p = length(L)
  # computes data-dependent quantities
  H = (1 / p) * sum(1 / (L[k] - L[(k + 1):p]))
  H_prime = - (1 / p) * sum(1 / ((L[k] - L[(k + 1):p]) ** 2))
  Delta = L[k] - L[k + 1]
  theta = n / (p ** (3 / 2))
  sig_min = - (1 / 2) * (1 / (theta ** 2)) * H_prime
  # computes beta 
  tmp_sqrt = sqrt(max((w ** 2) ** 2 - sig_min * w ** 2, 0)) 
  BX = 2 * ((theta ** 2) * Delta) * (w ** 2 + tmp_sqrt) + H
  return(BX)
}

##------------------------------------------------------------------------------
## Trade-off functions

fun_gdp = function(rho, alpha) {
  # Computes trade-off function value for rho-GDP evaluated at alpha
  # Input(s):
  # - rho: level of GDP guarantee 
  # - alpha: input to the trade-off function 
  # Output(s):
  # - tf: trade-off function value for rho-GDP evaluated at alpha
  # Citation(s):
  # - Implementation of Equation (5) of J. Dong, A. Roth, and W. J. Su. Gaussian 
  #   differential privacy. Journal of the Royal Statistical Society: Series B 
  #   (Statistical Methodology), 84(1):3–37, 2022.
  tf = pnorm(qnorm(1 - alpha) - rho)
  return(tf)
}

fun_dp = function(epsilon, alpha) {
  # Computes trade-off function value for epsilon-DP evaluated at alpha
  # Input(s):
  # - epsilon: level of epsilon-DP guarantee 
  # - alpha: input to the trade-off function 
  # Output(s):
  # - tf: trade-off function value for epsilon-DP evaluated at alpha
  # Citation(s):
  # - Implementation of Equation (4) of J. Dong, A. Roth, and W. J. Su. Gaussian 
  #   differential privacy. Journal of the Royal Statistical Society: Series B 
  #   (Statistical Methodology), 84(1):3–37, 2022.
  tf = max(0, 1 - exp(epsilon) * alpha, exp(-epsilon) * (1 - alpha))
  return(tf)
}

##------------------------------------------------------------------------------
## Utility 

fun_error_e = function(V, U_star) {
  # Estimates empirical estimation error (operator norm)
  # Input(s):
  # - V: private PCs 
  # - U_star: true PCs 
  # Output(s):
  # - ee: empirical estimation error
  E = U_star %*% t(U_star) - V %*% t(V) 
  ee = max((svd(E))$d) ** 2 
  return(ee)
}

fun_error_e_Fro = function(V, U_star) {
  # Estimates empirical estimation error (Frobenius norm)
  # Input(s):
  # - V: private PCs 
  # - U_star: true PCs 
  # Output(s):
  # - ee: empirical estimation error
  E = U_star %*% t(U_star) - V %*% t(V) 
  ee = sum(E ** 2)
  return(ee)
}

fun_error_t = function(beta, k, L) {
  # Estimates theoretical estimation error (operator norm)
  # Input(s): 
  # - beta: noise parameter 
  # - k: number of PCs 
  # - L: vector of eigenvalues of sample covariance matrix 
  # Output(s):
  # - ee: theoretical estimation error
  p = length(L)
  H = (1 / p) * sum(1 / (L[k] - L[(k + 1):p]))
  ee = min(H / beta, 1)
  return(ee)
}

fun_error_t_Fro = function(beta, k, L) {
  # Estimates theoretical estimation error (Frobenius norm)
  # Input(s): 
  # - beta: noise parameter 
  # - k: number of PCs 
  # - L: vector of eigenvalues of sample covariance matrix 
  # Output(s):
  # - ee: theoretical estimation error
  p = length(L)
  vec_H = rep(0, k)
  for (i in 1:k) {
    vec_H[i] = (1 / p) * sum(1 / (L[i] - L[(k + 1):p]))
  }
  vec_summand = sapply(vec_H / beta, function(x) {return(min(1, x))})
  ee = 2 * sum(vec_summand)
  return(ee)
}

##------------------------------------------------------------------------------
## Data pre-processing

fun_preprocess = function(X_raw) {
  # Implements rank transformation
  # Input(s):
  # - X_raw: raw dataset 
  # Output(s):
  # - X: preprocessed dataset
  n = dim(X_raw)[1]
  # transforms into the rank matrix 
  X = apply(X_raw, 2,  function(x) {return(rank(x, ties.method = "average"))})
  # centers each observation
  X = X - (n + 1) / 2
  # normalizes each observation
  X = 2 * X / (n - 1)
  return(X)
}

fun_preprocess_vanilla = function(X_raw) {
  # Preprocesses in the standard way
  # Input(s):
  # - X_raw: raw dataset 
  # Output(s):
  # - X: preprocessed dataset
  n = dim(X_raw)[1]
  # centers each observation
  mat_colMeans = matrix(rep(1, n), nrow = n) %*% matrix(colMeans(X_raw), 
                                                        nrow = 1)
  X = X_raw - mat_colMeans
  # normalizes each feature
  X = apply(X, 2, function(x) {return(x / sd(x))})
  return(X)
}

##------------------------------------------------------------------------------
## Auxiliary 

fun_est = function(k, L) {
  # Estimates data-dependent quantities 
  # Input(s):
  # - k: number of PCs 
  # - L: vector of eigenvalues of sample covariance matrix 
  # Output(s): 
  # - List of estimates of data-dependent quantities 
  p = length(L)
  H = (1 / p) * sum(1 / (L[k] - L[(k + 1):p])) 
  H_prime = - (1 / p) * sum(1 / ((L[k] - L[(k + 1):p]) ** 2))
  Delta = L[k] - L[k + 1]
  theta = n / (p ** (3 / 2))
  phase_t = - Delta * H_prime + H # phase transition
  sig_min = sqrt(- (1 / (2 * theta ** 2)) * H_prime) # minimum privacy 
  return(list("H" = H, "phase_t" = phase_t, "sig_min" = sig_min, 
              "Delta" = Delta, "H_prime" = H_prime))
}

##------------------------------------------------------------------------------