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

The climate data are derived from the second version of Park Williams' downscaled climate products. The data set is not publicly available, but it is stored on [CyVerse](https://cyverse.org/) and is accessible to WFFRC members. The climate data processing was completed on CyVerse, but the code is available here. Individual climate records were extracted for each field plot.

## Soil

Soil texture and depth data were extracted from [rescaled products](https://casoilresource.lawr.ucdavis.edu/soil-properties/download.php) created by [Walkinshaw et al. (2025)](https://casoilresource.lawr.ucdavis.edu/soil-properties/). The data are primarily derived from the [Soil Survey Geographic Database (SSURGO)](https://www.nrcs.usda.gov/resources/data-and-reports/soil-survey-geographic-database-ssurgo). The iLand implementation specifically uses the `clay.tif`, `sand.tif`, `silt.tif`, and `resdept.tif` (depth to restrictive layer) files.

Soil nitrogen availability is fixed at a value of `45` rather than using spatially variable values. A value of `45` maximizes the sensitivity to the plant nitrogen parameter based on the [hard-coded plant nitrogen sensitivity curves](https://iland-model.org/nitrogen+response). This approach effectively makes nitrogen control on plant productivity a *species level* process rather than a *stand level* process. It has been utilized successfully by Hansen et al. for iLand landscapes in Alaska. Other research groups have parameterized spatial nitrogen availability based on the data set produced by [Coops et al. (2012)](https://doi.org/10.1016/j.rse.2012.08.024). The dynamic nitrogen module is turned off in the model.

## Light Influence Patterns

The light influence patterns (LIP) represent a lookup table of ray tracing outputs that are created using the [Lightroom](https://iland-model.org/Lightroom) software, which is part of the iLand download package. A tutorial for parameterizing Lightroom is available in the model documentation (see link above). A more practical tutorial is provided in the `iLand_LIP_Calibration_Tutorial.Rmd` file. 

For the Sierra Nevada model implementation, the LIP files were calibrated using the [Tallo allometric database](https://doi.org/10.1111/gcb.16302), along with additional values from literature (see the `SEKI_LIP_and_init_calibration.Rmd` file). The intermediate files along with the final LIP files are provided in the `LIP` folder.

## Useful Links

* [Model home page](https://iland-model.org/startpage)
* [Model documentation](https://iland-model.org/iLand+Hub)
* [Source code](https://github.com/edfm-tum/iland-model) (most useful source code [here](https://github.com/edfm-tum/iland-model/blob/058749ffb2d174d171ca1fc8541baa0f127babbf/src/core/tree.cpp))
* [iLand Discord server](https://discord.gg/seCBZnpj)
* iLand North America meetings and listserv (contact Kristin Braziunas)