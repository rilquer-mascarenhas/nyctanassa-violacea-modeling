## Project Documentation

This document reports information on this project (continuously
updated).

### Questions

-   Has the range of *Nyctanassa violacea* recently expanded into California?
-   If so, what are the possible drivers of this range expansion over time?

### Methods

#### eBird data

Data was downloaded from eBird on Oct 7 2026.

Data filtering and exploration is needed. We will filter data to standardize methodology and simultaneously visually explore the data to help guide decisions.

Some methodological filters we may want to use:

1) Locality type
2) Observation type
3) Effort in km and/or hour
4) Time of record (keep between 2000-2026)
5) Records with breeding information
6) Think about the age of individual recorded (juvenile vs adults). It's important to have information on both, but juveniles are easier to be misidentified (juveniles of different species look alike).

Some visual exploration we may want to have:

1) Temporal distribution of points over years (2000-2026)
2) Temporal distribution of points throughout the year (to visualize yearly migration and breeding seasons)
3) Mapping sampling effort based on number of observers, checklist, effort in km/h, etc.

[This tutorial](https://ebird.github.io/ebird-best-practices/) has several ideas and guidelines on estimating and modeling biological metrics from eBird data.

Step-by-step of analyzing eBird data (largely based on [Hochachka et al. 2023](https://doi.org/10.1093/ornithology/ukad035)):

1. Filtering data to region of interest: California, Baja California and Baja California Sur
2. Filter by time: interested in YCNH reports in Southern California from 2000-2026. Also interested in historical records for Baja CA
3. Filter by checklist effort:
- Only include complete checklist—gets rid of some of the heterogeneity in observer effort that comes from citizen science data
- Only include “traveling” checklists, but also check data with “stationary” and data with only “stationary”
- Consider filtering by checklist duration (e.g. only include checklists with duration < 5 hrs), and traveling length (e.g. observers traveled up to 5 km)

#### Climate data

- We are thinking here of checking what is available from remote sensing data, to have a better sense of climate change over recent years.
- [PRISM](https://prism.oregonstate.edu/) could be an interesting dataset.

#### Land use/urban development

- Two interesting datasets here: [GISA](https://gee-community-catalog.org/projects/gisa/) (Global Impervious Surface Area) and [GUE](https://gee-community-catalog.org/projects/gue/) (Global Urban Extent).

#### Resource availability

- Fisheries? A good contact here might be the [Fredston Lab](https://alexafredston.com/).

#### Statistical approach

- The first approach that comes to mind is to test models with different combinations of the predictors above, to get a best model to predict some metric of presence for the species. Depending on what metric we use, we will use different types of models. This tutorial has some notes on deriving estimates of and modeling presence/absence, encounter rate and relative abundance. For presence/absence, we could think of a logistic model, while for encounter rate and relative abundance, we may be able to use regression models.
- Climate, land use and resource availability are the main predictors we are interested in, but there are other types of variation we need to control for. Some that come to mind: sampling effort, habitat heterogeneity.
