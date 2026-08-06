##------------------------------------------------------------------------------
## Specifies parameters

k = 1 # number of principal components
beta = 0.2 # noise parameter 2
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
U = svd_SigmaX$u
U_star = U[, 1:k]

##------------------------------------------------------------------------------
## Computes finite utilities 

for (which_error in c("op", "Fro")) {
  set.seed(seed)
  vec_error = rep(0, N)
  for(i in 1:N) {
    V = fun_V_Gibbs(beta, k, SigmaX, N_iter = N_iter)
    if (which_error == "op") {
      vec_error[i] = fun_error_e(V, U_star)
    } else if (which_error == "Fro") {
      vec_error[i] = fun_error_e_Fro(V, U_star)
    }
  }
  # saves outputs 
  path_output = paste0(FOLDER_OUTPUT, WHICH_DATA, "_Figure3_empirical_", 
                       which_error, "_k", k, "_beta", beta, ".txt")
  write.table(vec_error, file = path_output, row.names = F, col.names = F)
}

##------------------------------------------------------------------------------