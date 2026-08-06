##------------------------------------------------------------------------------
## Specifies parameters 

vec_beta = c(0.01, 0.2, 1.2) # noise level
seed = 1 # seed
FOLDER_OUTPUT = "outputs/" # specifies folder to save the output to 
WHICH_DATA = "1000Genomes" # 1000Genomes, survey
N_iter = 200

##------------------------------------------------------------------------------
## Loads libraries

library(MASS)
library(rstiefel)
library(EFA.dimensions)
source("functions.R")

##------------------------------------------------------------------------------
## Reads in data and labels

path_data = paste0("data/", WHICH_DATA, ".txt")
X_df = read.table(path_data, header = T)
X_orig = unname(as.matrix(X_df[, -1]))
# labels
path_labels = paste0("data/", WHICH_DATA, "_labels.txt")
X_labels = as.matrix(read.table(path_labels, header = T))[, 2]
n = dim(X_orig)[1]
p = dim(X_orig)[2]

##------------------------------------------------------------------------------
## Preprocesses data and computes sample covariance matrix

X = fun_preprocess(X_orig)
SigmaX = (1 / n) * t(X) %*% X 
svd_SigmaX = svd(SigmaX)
L = svd_SigmaX$d
U = svd_SigmaX$u

##------------------------------------------------------------------------------
## Computes non-private and private projections 

X_proj = X %*% U[, 1:2] # computes projections 
df = data.frame(
  x = X_proj[, 1], 
  y = X_proj[, 2],
  labels = X_labels
)
path_output = paste0(FOLDER_OUTPUT, WHICH_DATA, "_Figure1_nonPriv.txt")
write.table(df, file = path_output, row.names = F, col.names = T)

for (i in 1:length(vec_beta)) {
  beta = vec_beta[i]
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
  path_output = paste0(FOLDER_OUTPUT, WHICH_DATA, "_Figure1_", beta, ".txt")
  write.table(df, file = path_output, row.names = F, col.names = T)
  #-----
  # Citation(s): 
  # - Implementation based on K. Chaudhuri, A. D. Sarwate, and K. Sinha. A 
  #   near-optimal algorithm for differentially-private principal components. 
  #   The Journal of Machine Learning Research, 14(1):2905–2943, 2013.
  ep = c(beta * p ** 2 / n)
  #-----
  # Citation(s):
  # - Implementation based on Section 3.3 of J. Dong, A. Roth, and W. J. Su. 
  #   Gaussian differential privacy. Journal of the Royal Statistical Society: 
  #   Series B (Statistical Methodology), 84(1):3–37, 2022.
  Bern_null = 1 / (1 + exp(ep))
  Bern_alter = exp(ep) / (1 + exp(ep))
  #-----
  print(paste0("Beta=", beta, " corresponds to ", round(ep, 2), "-DP guarantee,"))
  print(paste0("which is equiavalent to testing Bern(", round(Bern_null, 2), ") v.s. Bern(", round(Bern_alter, 2), ")"))
}

##------------------------------------------------------------------------------