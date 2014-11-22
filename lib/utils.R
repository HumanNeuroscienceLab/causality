# This function allows you to load all the contents of an rda into 
# a list
load_rda <- function(infile) { 
  load(infile)
  as.list(environment())
}

