---
editor_options: 
  markdown: 
    wrap: 72
---

## Project Documentation

This document reports information on this project (continuously
updated).

#### Questions

-   Has the range of Nyctanassa violacea recently expanded into
    California?
-   If so, what are the possible drivers of this range expansion over
    time?

#### Methodological notes

**eBird data**

Data was downloaded from eBird on Oct 7 2026.

Data filtering and exploration is needed. We will filter data to
standardize methodology and simultaneously visually explore the data to
help guide decisions.

Some methodological filters we may want to use:

1) Locality type
2) Observation type
3) Effort in km and/or hour
4) Time of record (keep between 2000-2026)
5) Records with breeding information

Some visual exploration we may want to have:

1) Temporal distribution of
points over years (2000-2026)
2) Temporal distribution of points
throughout the year (to visualize yearly migration and breeding seasons)
3) Mapping sampling effort based on number of observers, checklist,
effort in km/h, etc.

Step-by-step of analyzing eBird data (largely based on XXX) - To be
completed by Santiago

**Climate data**

We are thinking here of checking what is available from remote sensing
data, to have a better sense of climate change over recent years.
[PRISM](https://prism.oregonstate.edu/) could be an interesting dataset.

**Land use/urban development**

Two interesting datasets here:
[GISA](https://gee-community-catalog.org/projects/gisa/) (Global
Impervious Surface Area) and
[GUE](https://gee-community-catalog.org/projects/gue/) (Global Urban
Extent).

**Resource availability**

Fisheries? A good contact here might be the [Fredston
Lab](https://alexafredston.com/).

**Statistical approach**

-   The first approach that comes to mind is to test models with
    different combinations of the predictors above, to get a best model
    to predict some metric of presence for the species. Depending on
    what metric we use, we will use different types of models. This
    tutorial has some notes on deriving estimates of and modeling
    presence/absence, encounter rate and relative abundance. For
    presence/absence, we could think of a logistic model, while for
    encounter rate and relative abundance, we may be able to use
    regression models.
-   Climate, land use and resource availability are the main predictors
    we are interested in, but there are other types of variation we need
    to control for. Some that come to mind: sampling effort, habitat
    heterogeneity.
