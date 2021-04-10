
# Habitat Protection Indexes: new monitoring measures for the conservation of threatened marine habitats 


## Requisites: 

Code is based on R version 4.0.5 (2021-03-31) -- "Shake and Throw", drafted using RStudio Version 1.4.1103. 

The code relies on several packages that need to be installed for it to function properly. We are using the package `renv` to ensure compatibility, on first use, please run `renv::restore()` in your machine to ensure you'll install and download all packages in the needed versions. 


## Data download: 
Data used in this workflow can be downloaded from google drive: https://drive.google.com/file/d/1VnAK8ATBbXkFFb-UvwahNpBu1L_-_-cg/view?usp=sharing 

## Workflow 

The full workflow can be reproduced by sourcing the `01_Workflow.R` script in the main folder. The script sources the several steps to calculate the indexes. If wanted, one can run each step separately using the scripts in the `Scripts` folder, beware that these are dependent on each other and are built to be run sequentially. 

We also use parallel processing to increase speed of computational demanding spatial calculations. Use with caution on your own machine. We strongly suggest to run the workflow on a smaller subset of data for testing. 
Results are stored in the `Data_final` folder, as comma separated value tables. 


## Methodology 

For each habitat we calculate the percentage protection of that habitat both globally and per country. 


## Contacts 

Code written by Joy Kumagai (joy.kumagai@senckenberg.de) and Fabio Favoretto (favoretto@uabcs.mx)
