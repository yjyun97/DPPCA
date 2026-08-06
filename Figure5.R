##------------------------------------------------------------------------------
## Specifies parameters

vec_k = c(1, 2, 3) # rank 
m = 100 # number of grid points 
beta_max = 3.5 # maximum noise level 
FOLDER_OUTPUT = "outputs/" # specifies folder to save the output to 
WHICH_DATA = "1000Genomes" # 1000Genomes, survey

##------------------------------------------------------------------------------
## Loads libraries

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

##------------------------------------------------------------------------------
## Computes privacy as a function of beta

for (i in 1:length(vec_k)) {
  k = vec_k[i]
  vec_beta = seq(fun_est(k, L)$H * 1.001, beta_max, length.out = m)
  vec_sig = sapply(vec_beta, function(x) {fun_sig(x, k, L)})
  # saves outputs 
  df = data.frame(
    beta = vec_beta,  
    sig = vec_sig
  )
  path_output = paste0(FOLDER_OUTPUT, WHICH_DATA, "_Figure4_privacy_", k, 
                       ".txt")
  write.table(df, file = path_output, row.names = F, col.names = T)
}

##------------------------------------------------------------------------------