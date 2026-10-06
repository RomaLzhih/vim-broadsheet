library(utils)
counts <- read.csv("visits.csv")
f <- function(x, limit = 10) {
  if (nrow(x) == 0) {
    stop("no rows")
  }
  for (i in 1:limit) {
    y <- x[i, ]
  }
  repeat {
    break
  }
  return(x)
}
v <- c(1.5, 2.5, TRUE, NA)
