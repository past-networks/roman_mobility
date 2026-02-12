# Roman Mobility Project
_Mobility and transport network analysis_

## About
The project (1) model roman road network and epigraphic life-to-death trajectory data data as a mobility network; (2) create the first detailed multimodal (sea, river, roads) transport network of the Roman Empire; and (3) explore the structuring effect of the transport network on the mobility network. 

## Authors 
* Petra Hermankova [![](https://orcid.org/sites/default/files/images/orcid_16x16.png)](https://orcid.org/0000-0002-6349-0540), PSN, Aarhus University
* Nadia Kinga Wójtowicz, Aarhus University
* Tom Brughmans [![](https://orcid.org/sites/default/files/images/orcid_16x16.png)](https://orcid.org/0000-0002-1589-7768), PSN, Aarhus University
* [Name], [ORCID], [Institution]
* [Name], [ORCID], [Institution]

## Funding
*The Past Social Networks Projects* is funded by The Carlsberg Foundation’s Young Researcher Fellowship (CF21-0382) in 2022-2026. 

## License
CC-BY-SA 4.0, see attached [License](./License.md)

## Data

### Roman roads

The latest data available at https://itiner-e.org/ 

__de Soto, P. et al. (2025) A High-Resolution Dataset of Roads of the Roman Empire: Itiner-e static version 2024. Zenodo. https://doi.org/10.5281/zenodo.17122148`__

Related publication: __de Soto, P., Pažout, A., Brughmans, T. et al. Itiner-e: A high-resolution dataset of roads of the Roman Empire. Sci Data 12, 1731 (2025). https://doi.org/10.1038/s41597-025-06140-z__


### Rivers

The data is on https://itiner-e.org/ with type = river.

Related publication: __Filet, C., Laroche, C., Coto-Sarmiento, M., & Bongers, T. (2025). As the water flows: A method for assessing river navigability in the past. Journal of Archaeological Science, 182, 106315. https://doi.org/10.1016/j.jas.2025.106315__

### Sea lanes

The data is on https://itiner-e.org/ with type = sea lane.

Related publication: __Gal, D., Saaroni, H., & Cvikel, D. (2023). Mappings of Potential Sailing Mobility in the Mediterranean During Antiquity. Journal of Archaeological Method and Theory, 30(2), 397–448. https://doi.org/10.1007/s10816-022-09567-5__


### Latin inscriptions

__Sobotkova, A., Heřmánková, P., & Kaše, V. (2025). origo (v1.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.14604222__

Related publication: __Sobotkova, A., Heřmánková, P., & Kaše, V. Soldier Mobility in the Roman Empire from Birth-to-Death Locations in Latin Epigraphs. TBA.__

Related repository: `https://github.com/sdam-au/LI_origo`


### Roman Empire Boundaries

1) Roman provinces 200CE

The shapefile of Roman provinces in 200 CE (peak Roman Empire under the Severan dynasty) is based on `roman-empire-ce-200-provinces.geojson` published by The Ancient World Mapping Centre and corrected by Adam Pazout in 2023. https://github.com/AWMC/geodata/tree/master/Cultural-Data/political_shading/roman_empire_ce_200_provinces`

2) Pleaides regions

https://raw.githubusercontent.com/pelagios/magis-pleiades-regions/main/pleiades-regions-magis-pelagios.geojson


### Cities

1) Ancient Sites from Pleiades

https://pleiades.stoa.org/downloads

The site density and spatial network models methods use locations of 14,317 ancient sites that intersect with our research area derived from the ‘Pleiades: A Gazetteer of Past Places’53 dataset with, according to the Pleiades ontology, the type values of ‘settlement’, ‘villa’, ‘fort’, and ‘station’ (referring to a road station), and time period ‘Roman’ (featureTyp LIKE '%settlement%' Or featureTyp LIKE '%villa%' Or featureTyp LIKE '%station%' Or featureTyp LIKE '%fort%' And timePeri_1 LIKE '%roman%').


2) Cities of the Roman Empire
__Hanson, J. W. (2016). Cities Database (OXREP databases). Version 1.0. Accessed (date): <http://oxrep.classics.ox.ac.uk/databases/cities/>. DOI: <https://doi.org/10.5287/bodleian:eqapevAn8>__

Related publication: __Hanson J. W., An urban geography of the Roman world, 100 BC to AD 300. Oxford: Archaeopress; 2016. http://oxrep.classics.ox.ac.uk/oxrep/docs/Hanson2016/Hanson2016_Cities_OxREP.csv__

3) Population estimates

__Hanson J. W, Ortman S. G., A systematic method for estimating the populations of Greek and Roman settlements. J Roman Archaeol. 2017;30: 301–324.__


### Modern countries

Shapefile available at https://public.opendatasoft.com/api/explore/v2.1/catalog/datasets/world-administrative-boundaries/exports/shp

## Repository structure

### `scripts`

1. cleaning_data/: R scripts cleaning and streamlining the `origo` dataset [responsible: Hermankova]

### `data`

1. large_data/: locally saved, does not uppload to GitHub die to size of the data. Users need to download the datasets on their own. Guidance and provenance are provided in the individual scripts, or in the data section above.

2. provinces/: Roman provinces 200CE, see above

3. world-administrative-boundaries/: modern countries, see above

4. hanson_2016_merged.csv - cities of the Roamn Empire, see above

5. HansonOrtmanetal2017_dataset.csv; roman_cities_pop.csv, roman_cities_pop.geojson, roman_cities_pop.parquet - population estimates, see above

6. origo_geo.csv, origo_geo.parquet, origo_variable_dictionary.csv - origo dataset, see above

7. pleiades_regions.geojson - Ancient cities from Pleiades, see above


### `figures`

### `output`


## Screenshots
![Example screenshot](./img/screenshot.png)


## DOI
TBA

## How to cite us
TBA

---


<img src="./img/Main_banner.png" alt="Logo banner">


