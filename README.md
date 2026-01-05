# \# Sierra Nevada iLand Model

# 

# \## Introduction

# 

# This iLand model implementation has been created to simulate alpine forest dynamics in California's Sierra Nevada mountains as part of the \[Western Fire and Forest Resilience Collaborative (WFFRC)](https://www.westernfireforest.org/). It will ultimate be synthesized with other iLand landscapes created by WFFRC to simulate future forest resilience across the western United States.

# 

# \## Species

# 

# The model implementation is designed to replicate conifer forest dynamics across a network of long-term field plots in Sequoia and King's Canyon National parks. The field plots are maintained by the U.S. Geological Survey. The Sierra Nevada model contains four vegetation classes, which represent species that form distinct elevational bands across the field plots. The initial parameter values were based on parameterizations for similar species compiled by \[Thom et al. (2024)](https://doi.org/10.1016/j.dib.2024.110662), but they have been modified for the Sierra Nevada species.

# 

# | Vegetation Class  | Represented Species | Thom et al. (2024) Parameters |

# | ------------- | ------------- | ------------- |

# | Low elevation pine  | \*Pinus ponderosa\*  | \*Pinus ponderosa\* |

# | Incense cedar | \*Calocedrus decurrens\* | \*Thuja plicata\* |

# | Mixed fir | \*Abies concolor\*<br>\*Abies magnifica\*  | \*Abies lasiocarpa\* |

# | High elevation pine | \*Pinus contorta\*<br>\*Pinus monticola\* | \*Pinus contorta\* |

# 

# \## Climate

# 

# The climate data are derived from the second version of Park Williams' downscaled climate products. The data set is not publicly available, but it is stored on \[CyVerse](https://cyverse.org/) and is accessible to WFFRC members. The climate data processing was completed on CyVerse, but the code is available here. Individual climate records were extracted for each field plot.

# 

# \## Soil

# 

# Soil texture and depth data were extracted from \[rescaled products](https://casoilresource.lawr.ucdavis.edu/soil-properties/download.php) created by \[Walkinshaw et al. (2025)](https://casoilresource.lawr.ucdavis.edu/soil-properties/). The data are primarily derived from the \[Soil Survey Geographic Database (SSURGO)](https://www.nrcs.usda.gov/resources/data-and-reports/soil-survey-geographic-database-ssurgo). The iLand implementation specifically uses the `clay.tif`, `sand.tif`, `silt.tif`, and `resdept.tif` (depth to restrictive layer) files.

# 

# Soil nitrogen availability is fixed at a value of `45` rather than using spatially variable values. A value of `45` maximizes the sensitivity to the plant nitrogen parameter based on the \[hard-coded plant nitrogen sensitivity curves](https://iland-model.org/nitrogen+response). This approach effectively makes nitrogen control on plant productivity a \*species level\* process rather than a \*stand level\* process. It has been utilized successfully by Hansen et al. for iLand landscapes in Alaska. Other research groups have parameterized spatial nitrogen availability based on the data set produced by \[Coops et al. (2012)](https://doi.org/10.1016/j.rse.2012.08.024). The dynamic nitrogen module is turned off in the model.

# 

