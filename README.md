# Marine habitat Protection Indicator (MPI) 

## Current protection of threatened marine habitats

### Step 1: download data
Data needed to reproduce the analisis are available at: 

1. MPA layer: https://www.protectedplanet.net/en/thematic-areas/wdpa?tab=WDPA
2. EEZ layer: https://www.marineregions.org/sources.php#unioneezcountry 
3. Cold Corals: https://data.unep-wcmc.org/datasets/3 
4. Warm Water corals: https://data.unep-wcmc.org/datasets/1  
5. Mangroves: https://data.unep-wcmc.org/datasets/45 
6. Saltmarshes: https://data.unep-wcmc.org/datasets/43 
7. Seagrasses: https://data.unep-wcmc.org/datasets/7 
8. Ocean base layer: https://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-ocean/ 


Once data are downloaded from web sources into your local working directory into a custom subfolder called `Data_original/habitats`. Additional habitats in polygon shapefile format can be added to the same folder. 

2. All intermediate data is added into a folder called `Data_processed` created from the scripts.

3. A final output in `.CSV` format is added into a folder called `Data_final` within the scripts.


### Methodology overview:

Using R studio v.1.4.1103, the code calculates the percentage protected of all input habitats both globally and per country. The workflow also includes three levels of protection for the MPAs (all, managed, and completely no-take). 
**Data is stored on google drive: https://drive.google.com/file/d/1VnAK8ATBbXkFFb-UvwahNpBu1L_-_-cg/view?usp=sharing **


---

## Credits and contact informations

Code written by Joy Kumagai (joy.kumagai@senckenberg.de) and Fabio Favorettto (favoretto@uabcs.mx)
Date: Nov. 25th 2020