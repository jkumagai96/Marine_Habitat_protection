# Marine habitat Protection Indicator (MPI) 

## Current protection of threatened marine habitats

### Step 1: download data
Data needed to reproduce the analisis are available at: 

#### Base layers:

- **MPA layer**: https://www.protectedplanet.net/en/thematic-areas/wdpa?tab=WDPA
- **EEZ layer**: https://www.marineregions.org/sources.php#unioneezcountry 
- **Ocean base layer**: https://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-ocean/ 

#### Habitat layers:

- **Cold Corals**: https://data.unep-wcmc.org/datasets/3 
- **Warm Water corals**: https://data.unep-wcmc.org/datasets/1  
- **Mangroves**: https://data.unep-wcmc.org/datasets/45 
- **Saltmarshes**: https://data.unep-wcmc.org/datasets/43 
- **Seagrasses**: https://data.unep-wcmc.org/datasets/7 


Once data are downloaded from web sources into your local working directory, these *must* be organized as following:

- `Data_original` folder as: 
- `Data_original/mpas`: where all MPAs layer should be stored
- `Data_original/ocean`: where the "Ocean base layer" should be stored
- `Data_original/eez_land` where the EEZ layer should be stored
- `Data_original/habitats`into a custom subfolder called `Data_original/habitats`

Additional habitats in polygon shapefile format can be added to the same `Data_original/habitats` folder. 

Once the workflow is sourced, all intermediate data is added into a folder called `Data_processed` created from the scripts.

A final output in `.CSV` format is added into a folder called `Data_final` within the scripts.


### Methodology overview:

Using R studio v.1.4.1103, the code calculates the percentage protected of all input habitats both globally and per country. The workflow also includes three levels of protection for the MPAs (all, managed, and completely no-take). 
Details over the methodology can be found [here]()


---

## Credits and contact informations

Code written by Joy Kumagai (joy.kumagai@senckenberg.de) and Fabio Favorettto (favoretto@uabcs.mx)
Date: Nov. 25th 2020