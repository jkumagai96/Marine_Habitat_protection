
# Habitat Protection Indexes - new monitoring measures for the conservation of threatened marine habitats 


## Requisites: 

Code is based on R version 4.0.3 (2020-10-10), drafted using RStudio Version 1.4.1103 -- “Wax Begonia” (Windows). 

The code relies on several packages that need to be installed for it to function properly. We are using the package `renv` to ensure compatibility, on first use, please run `renv::restore()` in your machine to ensure you'll install and download all packages in the needed versions. 


## Data download: 

Please download the following datasets, and store them in the `Data_original` folder, each within a unique subfolder, except for habitats, where all shapefiles should be stored together within the same subfolder named `habitats`.

`Data_original` Folder Structure:   
  
--- `habitats`  
  
--- `eez_land`  
  
--- `eez`  
  
--- `mpas`  
  
--- `ocean`  

Datasets to be added: 

| Name | Source/Website | Date accessed | Version |
| :---: | :---: | :---: | :---: |
| World Database on Protected Areas | UNEP-WCMC and IUCN (2021), Protected Planet: The World Database on Protected Areas (WDPA)/The Global Database on Protected Areas Management Effectiveness (GD-PAME)] [On-line], March 2021, Cambridge, UK: UNEP-WCMC and IUCN. Available at: www.protectedplanet.net. | March 2021 | March 2021 |
| eez_land (Union of EEZs and countries) | Flanders Marine Institute (2020). Union of the ESRI Country shapefile and the Exclusive Economic Zones (version 3). Available online at https://www.marineregions.org/. https://doi.org/10.14284/403. | December 2020 | Version 3 |
| EEZs | Flanders Marine Institute (2019). Maritime Boundaries Geodatabase, version 11. Available online at https://www.marineregions.org/. https://doi.org/10.14284/382. | March 2021 | Version 11 |
| Cold Corals | Freiwald A, Rogers A, Hall-Spencer J, Guinotte JM, Davies AJ, Yesson C, Martin CS, Weatherdon LV (2018). Global distribution of cold-water corals (version 5.0). Fifth update to the dataset in Freiwald et al. (2004) by UNEP-WCMC, in collaboration with Andre Freiwald and John Guinotte. Cambridge (UK): UNEP-WCMC. Data DOI: https://doi.org/10.34892/72×9-rt61 | December 2020 | Version 5 |
| Warm-water Corals | UNEP-WCMC, WorldFish Centre, WRI, TNC (2018). Global distribution of warm-water coral reefs, compiled from multiple sources including the Millennium Coral Reef Mapping Project. Version 4.0. Includes contributions from IMaRS-USF and IRD (2005), IMaRS-USF (2005) and Spalding et al. (2001). Cambridge (UK): UNEP-WCMC. Data DOI: https://doi.org/10.34892/t2wk-5t34 | December 2020 | Version 4 |
| Knolls and Seamounts | Yesson C, Clark MR, Taylor M, Rogers AD (2011). The global distribution of seamounts based on 30-second bathymetry data. Deep Sea Research Part I: Oceanographic Research Papers 58: 442-453. doi: 10.1016/j.dsr.2011.02.004. Data URL: http://data.unep-wcmc.org/datasets/41 | March 2021 | Version 1.0 |
| Mangroves | Bunting P., Rosenqvist A., Lucas R., Rebelo L-M., Hilarides L., Thomas N., Hardy A., Itoh T., Shimada M. and Finlayson C.M. (2018). The Global Mangrove Watch – a New 2010 Global Baseline of Mangrove Extent. Remote Sensing 10(10): 1669. doi: 10.3390/rs1010669. | December 2020 | GMW 2016 |
| Saltmarshes | Mcowen C, Weatherdon LV, Bochove J, Sullivan E, Blyth S, Zockler C, Stanwell-Smith D, Kingston N, Martin CS, Spalding M, Fletcher S (2017). A global map of saltmarshes. Biodiversity Data Journal 5: e11764. Paper DOI: https://doi.org/10.3897/BDJ.5.e11764; Data DOI: https://doi.org/10.34892/07vk-ws51 | December 2020 | Version 6 |
| Seagrasses | UNEP-WCMC, Short FT (2020). Global distribution of seagrasses (version 7.0). Seventh update to the data layer used in Green and Short (2003). Cambridge (UK): UNEP-WCMC. Data DOI: https://doi.org/10.34892/x6r3-d211 | December 2020 | Version 7 |
| Ocean | https://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-ocean/ | December 2020 | Version 4.1.0 |

Please note that a folder named `Data_processed` will be added in the workflow. 

## Workflow 

The full workflow can be reproduced by sourcing the `01_Workflow.R` script in the main folder. The script sources the several steps to calculate the indexes. If wanted, one can run each step separately using the scripts in the `Scripts` folder, beware that these are dependent on each other and are built to be run sequentially. 

We also use parallel processing to increase speed of computational demanding spatial calculations. Use with caution on your own machine. We strongly suggest to run the workflow on a smaller subset of data for testing. 
Results are stored in the `Data_final` folder, as comma separated value tables. 


## Methodology 

For each habitat we calculate the percentage protection of that habitat both globally and per country. Please refer to the paper for the full methodology.


## Contacts 

Code written by Joy Kumagai (joy.kumagai@senckenberg.de) and Fabio Favoretto (favoretto@uabcs.mx). Please contact us if you have any questions or open an issue on github.
