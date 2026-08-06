##------------------------------------------------------------------------------
## Specifies parameters 

FOLDER_OUTPUT = "outputs/" # specifies folder to save the output to 
WHICH_DATA = "survey" # genomes, survey

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

##------------------------------------------------------------------------------
## Computes theoretical tradeoff function values 

for (k in c(1, 2, 3)) {
  for (beta in c(0.5, 1, 2, 4, 8)) {
    if ((WHICH_DATA == "1000Genomes") & (((k == 3) & (beta < 1.64)) |
        ((k == 2) & (beta < 0.56)))) {
    } else {
      # AGDP 
      vec_alpha = seq(0, 1, length.out = 200)
      sig = fun_sig(beta, k, L)
      vec_tf = sapply(vec_alpha, function(x) {return(fun_gdp(sig, x))})
      # prior work 
      #-----
      # Citation(s): 
      # - Implementation based on K. Chaudhuri, A. D. Sarwate, and K. Sinha. A 
      #   near-optimal algorithm for differentially-private principal components. 
      #   The Journal of Machine Learning Research, 14(1):2905–2943, 2013.
      epsilon = (p ** 2 / n) * beta
      #-----
      vec_tf_prior = sapply(vec_alpha, function(x) {return(fun_dp(epsilon, x))})
      # saves outputs
      df = data.frame(
        alpha = vec_alpha, 
        tf = vec_tf, 
        tf_prior = vec_tf_prior
      )
      path_output = paste0(FOLDER_OUTPUT, WHICH_DATA, "_Figure6_theoretical",
                           "_k", k, "_beta", beta, ".txt")
      write.table(df, path_output, row.names = F, col.names = T)
    }
  }
}

##------------------------------------------------------------------------------