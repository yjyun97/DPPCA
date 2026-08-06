##------------------------------------------------------------------------------
## Specifies parameters

vec_beta = unique(read.csv("var_error.txt")[, 2])
m = length(vec_beta) # number of grid points
FOLDER_OUTPUT = "outputs/" # specifies folder to save the output to 
WHICH_DATA = "1000Genomes" # 1000Genomes, survey

##------------------------------------------------------------------------------
## Computes sample mean of estimation error 

for (which_error in c("op", "Fro")) {
  for (k in c(1, 2, 3)) {
    mat = matrix(0, m, 2)
    for(i in 1:m) {
      beta = vec_beta[i]
      cur_file = paste0("samples/", WHICH_DATA, "_Figure3_empirical_", 
                        which_error, "_k", k, "_beta", beta, 
                        ".txt")
      cur_vec = as.matrix(read.table(cur_file))
      mat[i, 1] = beta
      mat[i, 2] = mean(cur_vec)
    }
    # saves outputs 
    df = data.frame(
      beta = mat[, 1], 
      error = mat[, 2]
    )
    path_output = paste0(FOLDER_OUTPUT, WHICH_DATA, "_Figure3_empirical_", 
                         which_error, "_k", k, ".txt")
    write.table(df, file = path_output, row.names = F, col.names = T)
  }
}

##------------------------------------------------------------------------------