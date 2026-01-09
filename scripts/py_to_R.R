### initializing python in R
library(reticulate)
## to get the conda environment
reticulate::conda_python('base')
Sys.which("python") # to see wichi python is been used.
use_python("/Users/franciscotacora/opt/anaconda3/bin/python") # to specify the conda environment

reticulate::py_run_file('teste.py')
