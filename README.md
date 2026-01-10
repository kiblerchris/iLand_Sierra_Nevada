# Sierra Nevada iLand Model

## Introduction

This iLand model implementation has been created to simulate alpine forest dynamics in California's Sierra Nevada mountains as part of the [Western Fire and Forest Resilience Collaborative](https://www.westernfireforest.org/) (WFFRC). It will ultimately be synthesized with other iLand landscapes created by WFFRC to simulate future forest resilience across the western United States.

## Species

The model implementation is designed to replicate conifer forest dynamics across a network of long-term field plots in Sequoia and King's Canyon National parks. The field plots are maintained by the U.S. Geological Survey. The Sierra Nevada model contains four vegetation classes, which represent species that form distinct elevational bands across the field plots. The initial parameter values were based on parameterizations for similar species compiled by [Thom et al. (2024)](https://doi.org/10.1016/j.dib.2024.110662), but they have been modified for the Sierra Nevada species.

| Vegetation Class  | Represented Species | Thom et al. (2024) Parameters |
| ------------- | ------------- | ------------- |
| Low elevation pine  | *Pinus ponderosa*  | *Pinus ponderosa* |
| Incense cedar | *Calocedrus decurrens* | *Thuja plicata* |
| Mixed fir | *Abies concolor*<br>*Abies magnifica*  | *Abies lasiocarpa* |
| High elevation pine | *Pinus contorta*<br>*Pinus monticola* | *Pinus contorta* |

## Climate

The climate data are derived from the second version of Park Williams' downscaled climate products. I compared Park's data set with DAYMET and GRIDMET, along with field measurements from HOBO sensors, and there was strong agreement across all data sets, suggesting that the gridded climate products are reliable and somewhat interchangeable. Park's data set is not publicly available, but it is stored on [CyVerse](https://cyverse.org/) and is accessible to WFFRC members. The climate data processing was completed on CyVerse, but the code is available here. Individual climate records were extracted for each field plot.

## Soil

Soil texture and depth data were extracted from [rescaled products](https://casoilresource.lawr.ucdavis.edu/soil-properties/download.php) created by [Walkinshaw et al. (2025)](https://casoilresource.lawr.ucdavis.edu/soil-properties/). The data are primarily derived from the [Soil Survey Geographic Database](https://www.nrcs.usda.gov/resources/data-and-reports/soil-survey-geographic-database-ssurgo) (SSURGO). The iLand implementation specifically uses the `clay.tif`, `sand.tif`, `silt.tif`, and `resdept.tif` (depth to restrictive layer) files.

Soil nitrogen availability is fixed at a value of `45` rather than using spatially variable values. A value of `45` maximizes the sensitivity to the plant nitrogen parameter based on the hard-coded plant nitrogen [sensitivity curves](https://iland-model.org/nitrogen+response). This approach effectively makes nitrogen control on plant productivity a *species level* process rather than a *stand level* process. It has been utilized successfully by Hansen et al. for iLand landscapes in Alaska. Other research groups have parameterized spatial nitrogen availability based on the data set produced by [Coops et al. (2012)](https://doi.org/10.1016/j.rse.2012.08.024). The dynamic nitrogen module is turned off in the model.

## Light Influence Patterns

The light influence patterns (LIP) represent a lookup table of ray tracing outputs that are created using the [Lightroom](https://iland-model.org/Lightroom) software, which is part of the iLand download package. A tutorial for parameterizing Lightroom is available in the model documentation (see link above). A more practical tutorial is provided in the `iLand_LIP_Calibration_Tutorial.Rmd` file. 

For the Sierra Nevada model implementation, the LIP files were calibrated using the [Tallo allometric database](https://doi.org/10.1111/gcb.16302), along with additional values from literature (see the `SEKI_LIP_and_init_calibration.Rmd` file). The intermediate files along with the final LIP files are provided in the `LIP` folder.

## Project File

The project file provided here performs a relatively straightforward implementation of iLand. It is the result of consultation with other WFFRC research groups, although project files are not completely standardized across the collaborative. All disturbance modules are turned off, along with features like dynamic nitrogen cycling that require extensive parameterization. The landscape is currently set up in `standgrid` mode, where each 1 ha resource unit (i.e., grid cell) has its own climate and soil forcings. The resource units do not interact under the current parameterization. There are 10 replicates of each field plot (19 field plots X 10 replicates = 190 resource units), and each resource unit is entirely independent. The `torus` setting is activated, so any seeds that exit one side of the resource unit will reenter from the opposite side of the same resource unit.

## Control Files

The project file dispatches several other control files that define landscape and species parameters. Once the landscape is set up, the calibration process will primarily involve modifying `species.sqlite` and `tree_init.txt`. (The file names are defined in the project file and may vary across model implementations.) A brief summary of each control file is provided below:

| File  | Purpose | 
| ------------- | ------------- |
| `species.sqlite`  | Defines the [species parameters](https://iland-model.org/species+parameter) |
| `climate.sqlite` | Defines the [climate](https://iland-model.org/ClimateData?highlight=climate) for each resource unit |
| `env.grid.txt` | Defines the physical layout of the resource units on the landscape |
| `environment.txt` | Defines the soil properties for each resource unit. This file can also be used to specify almost any model parameter individually for each resource unit. |
| `tree_init.txt` | Determines which trees get [initialized](https://iland-model.org/initialize+trees) at the beginning of the model run |
| `sapling_init.txt` | Determines which sapling cohorts get [initialized](https://iland-model.org/initialize+trees) at the beginning of the model run |
| LIP `bin` files | Stores the ray tracing lookup tables for each species. The LIP file names are defined in `species.sqlite`. |
| `output.sqlite` | Stores the output database, which contains the user-defined [output tables](https://iland-model.org/Outputs) |

## Most Useful Species Parameters

The table below summarizes the most useful [species parameters](https://iland-model.org/species+parameter) to modify when calibrating the model. It was created by Kristin Braziunas.

| Process  | Sensitive Parameters | 
| ------------- | ------------- |
| Regeneration  | sapReinekesR<br>fecundity  |
| Establishment | estMinTemp |
| Saplings | sapHeightGrowthPotential<br>sapStressThreshold  |
| Growth | **respNitrogenClass**<br>**respTempMin**<br>**respTempMax**<br>lightResponseClass<br>psiMin |
| Mortality | **probIntrinsic**  |

## Useful Links

* [Model home page](https://iland-model.org/startpage)
* [Model documentation](https://iland-model.org/iLand+Hub)
* [Source code](https://github.com/edfm-tum/iland-model) (most useful source code [here](https://github.com/edfm-tum/iland-model/blob/058749ffb2d174d171ca1fc8541baa0f127babbf/src/core/tree.cpp))
* [iLand Discord server](https://discord.gg/seCBZnpj)
* iLand North America meetings and listserv (contact Kristin Braziunas)