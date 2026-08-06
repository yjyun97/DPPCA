##------------------------------------------------------------------------------
## Specifies parameters 

vec_beta = c(1, 2, 4, 8) # noise parameters
#vec_w = c(0.5, 1, 1.5) # privacy parameter
seed = 1 # seed
FOLDER_OUTPUT = "outputs/" # specifies folder to save the output to 
WHICH_DATA = "1000Genomes" # 1000Genomes, survey
N_iter = 200 # number of iterations of Gibbs sampler

##------------------------------------------------------------------------------
## Loads libraries

library(MASS)
library(rstiefel)
library(EFA.dimensions)
source("functions.R")

##------------------------------------------------------------------------------
## Reads in data and labels

# data
path_data = paste0("data/", WHICH_DATA, ".txt")
X_df = read.table(path_data, header = T)
X_orig = unname(as.matrix(X_df[, -1]))
n = dim(X_orig)[1]
p = dim(X_orig)[2]
# labels
path_labels = paste0("data/", WHICH_DATA, "_labels.txt")
X_labels = as.matrix(read.table(path_labels, header = T))[, 2]

##------------------------------------------------------------------------------
## Preprocesses data and computes sample covariance matrix

X = fun_preprocess(X_orig)
SigmaX = (1 / n) * t(X) %*% X 
svd_SigmaX = svd(SigmaX)
L = svd_SigmaX$d
U = svd_SigmaX$u

##------------------------------------------------------------------------------
## Computes private projections 

for (i in 1:length(vec_beta)) {
  #w = vec_w[i]
  beta = vec_beta[i] # estimates noise level 
  set.seed(seed)
  # samples privatized PCs
  V = fun_V_Gibbs(beta, 2, SigmaX, N_iter = N_iter)
  # applies the Procrustes rotation 
  res = PROCRUSTES(V, U[, 1:2], type = "orthogonal", verbose = F)
  # computes projections 
  X_proj = X %*% res$loadingsPROC 
  # saves outputs 
  df = data.frame(
    x = X_proj[, 1], 
    y = X_proj[, 2],
    labels = X_labels
  )
  path_output = paste0(FOLDER_OUTPUT, WHICH_DATA, "_Figure4_projections_", beta, 
                       ".txt")
  write.table(df, file = path_output, row.names = F, col.names = T)
  sig = fun_sig(beta, 2, L)
  print(paste0("Corresponds to noise parameter of ", round(sig, 2)))
}

##------------------------------------------------------------------------------