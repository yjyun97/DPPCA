##------------------------------------------------------------------------------
## Loads libraries

source("functions.R")

##------------------------------------------------------------------------------
## Reads in data and labels

WHICH_DATA = "1000Genomes" # 1000Genomes, survey
path_data = paste0("data/", WHICH_DATA, ".txt")
X_df = read.table(path_data, header = T)
X_orig = unname(as.matrix(X_df[, -1]))
n = dim(X_orig)[1]
p = dim(X_orig)[2]
FOLDER_OUTPUT = "outputs/" # specifies folder to save the output to 

##------------------------------------------------------------------------------
## Preprocesses data and computes sample covariance matrix

X = fun_preprocess(X_orig)
SigmaX = (1 / n) * t(X) %*% X 
svd_SigmaX = svd(SigmaX)
L = svd_SigmaX$d
U = svd_SigmaX$u

##------------------------------------------------------------------------------
## Computes thresholds for phase transitions

H_vec = rep(0, 3)
for (k in 1:3) {
  H_vec[k] = (1 / p) * sum(1 / (L[k] - L[(k + 1):p]))
}

##------------------------------------------------------------------------------
## Saves outputs

df = data.frame(
  Hvec = H_vec
)
write.table(df, file = paste0(FOLDER_OUTPUT, WHICH_DATA, 
                              "_Figure3_thresholds.txt"), 
            row.names = F, col.names = T)

##------------------------------------------------------------------------------