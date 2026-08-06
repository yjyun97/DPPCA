##------------------------------------------------------------------------------
## Loads libraries

library(MASS)
library(EFA.dimensions)
source("functions.R")
FOLDER_OUTPUT = "outputs/" # specifies folder to save the output to 

##------------------------------------------------------------------------------
## Computes tradeoff function values

fun_dp1 = function(y) {sapply(y, function(x) {return(fun_dp(1, x))})}
fun_gdp1 = function(y) {sapply(y, function(x) {return(fun_gdp(1, x))})}
fun_gdp3 = function(y) {sapply(y, function(x) {return(fun_gdp(3, x))})}
grid = seq(0, 1, length.out = 100)
vec_dp1 = fun_dp1(grid)
vec_gdp1 = fun_gdp1(grid)
vec_gdp3 = fun_gdp3(grid)
vec_perfect = 1 - grid

##------------------------------------------------------------------------------## Saves outputs
## Saves outputs

df = data.frame(
  alpha = grid,
  dp1 = vec_dp1,
  gdp1 = vec_gdp1,
  gdp3 = vec_gdp3,
  perfect = vec_perfect
)
path_output = paste0(FOLDER_OUTPUT, "Figure2.txt")
write.table(df, file = path_output, row.names = F, col.names = T)

##------------------------------------------------------------------------------