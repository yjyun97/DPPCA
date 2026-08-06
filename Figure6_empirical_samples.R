##------------------------------------------------------------------------------
## Specifies parameters

k = 1 # number of principal components
beta = 1 # privacy budget
N = 100000 # number of samples 
N_iter = 200 # number of iterations of Gibbs sampler
FOLDER_OUTPUT = "samples/" # specifies folder to save the output to 
WHICH_DATA = "survey" # 1000Genomes, survey

##------------------------------------------------------------------------------
## Loads libraries

library(MASS)
library(rstiefel)
source("functions.R")

##------------------------------------------------------------------------------
## Reads in data 

path_data = paste0("data/", WHICH_DATA, ".txt")
X_df = read.table(path_data, header = T)
X_orig = unname(as.matrix(X_df[, -1]))
n = dim(X_orig)[1]
p = dim(X_orig)[2]

##------------------------------------------------------------------------------
## Preprocesses data and computes sample covariance matrix

X = fun_preprocess(X_orig)
SigmaX = (1 / n) * t(X) %*% X 
svd_SigmaX = svd(SigmaX)
L = svd_SigmaX$d
U = svd_SigmaX$u
U_star = U[, 1:k]

##------------------------------------------------------------------------------
## Generates replicates of the test statistic under the null and alternative

# computes data-dependent estimates
H = (1 / p) * sum(1 / (L[k] - L[(k + 1):p]))
H_prime = - (1 / p) * sum(1 / ((L[k] - L[(k + 1):p]) ** 2))
Delta = L[k] - L[k + 1]
thresh = - Delta * H_prime + H 
# estimates noise parameter beta (with the original data)
#beta = fun_beta(sig, k, L)
if (beta >= thresh) {
  t_numer = beta - H
  t_denom = 2 * (beta - H) + Delta * H_prime
  t = t_numer / t_denom
} else {
  t = 1
}
# creates a data set under the alternative distribution
x_star = sqrt(p) * (sqrt(t) * U[, k] + sqrt(1 - t) * U[, k + 1])
X_tilde = rbind(X, t(x_star))
# computes SigmaX_tilde 
SigmaX_tilde = (1 / (n + 1)) * t(X_tilde) %*% X_tilde 
# samples from the null and the alternative distributions 
vec_null = rep(0, N)
vec_alter = rep(0, N)
set.seed(seed)
for (i in 1:N) {
  V = fun_V_Gibbs(beta, k, SigmaX, N_iter = N_iter)
  vec_null[i] = sum((t(V) %*% x_star) ** 2)
}
for (i in 1:N) {
  V_tilde = fun_V_Gibbs(beta, k, SigmaX_tilde, N_iter = N_iter)
  vec_alter[i] = sum((t(V_tilde) %*% x_star) ** 2)
}

##------------------------------------------------------------------------------
## Saves outputs

path_output_n = paste0(FOLDER_OUTPUT, WHICH_DATA, "_Figure6_empirical_null_k", 
                       k, "_beta", beta, ".txt")
path_output_a = paste0(FOLDER_OUTPUT, WHICH_DATA, "_Figure6_empirical_alter_k", 
                       k, "_beta", beta, ".txt")
write.table(vec_null, file = path_output_n, row.names = F, col.names = F)
write.table(vec_alter, file = path_output_a, row.names = F, col.names = F)

##------------------------------------------------------------------------------