##------------------------------------------------------------------------------
## Specifies parameters 

FOLDER_OUTPUT = "outputs/" # specifies folder to save the output to 
WHICH_DATA = "1000Genomes" # 1000Genomes, survey

##------------------------------------------------------------------------------
## Loads libraries

library(MASS)
source("functions.R")

##------------------------------------------------------------------------------
## Reads in data and labels

path_data = paste0("data/", WHICH_DATA, ".txt")
X_df = read.table(path_data, header = T)
X_orig = unname(as.matrix(X_df[, -1]))
n = dim(X_orig)[1]
p = dim(X_orig)[2]
# labels
path_labels = paste0("data/", WHICH_DATA, "_labels.txt")
X_labels = as.matrix(read.table(path_labels, header = T))[, 2]

##------------------------------------------------------------------------------
## Preprocesses data and computes non-private projections

for (which_pre in c("vanilla", "rank")) {
  if (which_pre == "rank") {
    X = fun_preprocess(X_orig)
    
  } else if (which_pre == "vanilla") {
    X = fun_preprocess_vanilla(X_orig)
  } 
  SigmaX = (1 / n) * t(X) %*% X
  svd_SigmaX = svd(SigmaX)
  L = svd_SigmaX$d
  U = svd_SigmaX$u
  U_star = U[, 1:2]
  # computes non-private projections
  X_proj = X %*% U_star
  # saves outputs 
  df = data.frame(
    x = X_proj[, 1], 
    y = X_proj[, 2],
    labels = X_labels
  )
  path_output = paste0(FOLDER_OUTPUT, WHICH_DATA, "_Figure7_", which_pre, 
                       ".txt")
  write.table(df, file = path_output, row.names = F, col.names = T)
}

##------------------------------------------------------------------------------