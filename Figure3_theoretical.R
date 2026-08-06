##------------------------------------------------------------------------------
## Specifies parameters

beta_max = 5 # maximum noise level 
m = 200 # number of grid points
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
## Computes theoretical error

vec_beta = seq(0, beta_max, length.out = m)
for (which_error in c("op", "Fro")) {
  for (k in c(1, 2, 3)) {
    if (which_error == "op") {
      vec_error = sapply(vec_beta, function(x) {return(fun_error_t(x, k, L))})
    } else if (which_error == "Fro") {
      vec_error = sapply(vec_beta, 
                         function(x) {return(fun_error_t_Fro(x, k, L))})
    }
    # saves outputs
    df_error = data.frame(
      beta = vec_beta, 
      error = vec_error
    )
    write.table(df_error, file = paste0(FOLDER_OUTPUT, WHICH_DATA, 
                                        "_Figure3_theoretical_", 
                                        which_error, "_k", k, ".txt"), 
                row.names = F, col.names = T)
  }
}

##------------------------------------------------------------------------------