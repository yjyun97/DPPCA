##------------------------------------------------------------------------------
## Specifies parameters

m = 20 # number of grid points
FOLDER_OUTPUT = "outputs/" # specifies folder to save the output to 
WHICH_DATA = "survey" # 1000Genomes, survey

##------------------------------------------------------------------------------
## Loads libraries

source("functions.R")

##------------------------------------------------------------------------------
## Computes estimate of trade-off function 

for (k in c(1, 2, 3)) {
  for (beta in c(0.5, 1, 2, 4, 8)) {
    if ((WHICH_DATA == "1000Genomes") & (((k == 3) & (beta < 1.64)) |
        ((k == 2) & (beta < 0.56)))) {
    } else {
      path_n = paste0("samples/", WHICH_DATA, "_Figure6_empirical_null_k", k, 
                      "_beta", beta, ".txt")
      path_a = paste0("samples/", WHICH_DATA, "_Figure6_empirical_alter_k", k, 
                      "_beta", beta, ".txt")
      vec_null = as.matrix(read.table(path_n))
      vec_alter = as.matrix(read.table(path_a))
      N = length(vec_null)
      vec_alpha = seq(0, 1, length.out = m)
      vec_thresh = unname(quantile(vec_null, 1 - vec_alpha))
      vec_tf = (1 / N) * sapply(vec_thresh, function(x) {sum(vec_alter < x)})
      # saves outputs
      df = data.frame(
        alpha = vec_alpha,
        tf = vec_tf
      )
      path_output = paste0(FOLDER_OUTPUT, WHICH_DATA, "_Figure6_empirical_k", k, 
                           "_beta", beta, ".txt")
      write.table(df, file = path_output, row.names = F, col.names = T)
    }
  }
}

##------------------------------------------------------------------------------