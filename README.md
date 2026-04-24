# Daily Load Forecasting Competition

Repository for the ENV 797 time series forecasting competition project by Mingjie Wei and Abrao Pereira.

## Overview

The goal of this project is to forecast daily residential electricity demand for July 2011 using historical load data, temperature, and relative humidity. The report compares five time series models on a July 2010 hold-out validation window and selects a final model for Kaggle submission.

The final selected model is `TBATS`, which performed best in local validation and was retained as the final submission model.
TBATS achieved a public Kaggle score of `9.98%`.

## Repository Structure

```
.
├── Wei_Pereira_CompetitionReport_S26.Rmd   # report source
├── Wei_Pereira_CompetitionReport_S26.pdf   # knitted final report
├── Forecasting2026.Rproj
├── data/
│   ├── load.xlsx                           # hourly load data
│   ├── temperature.xlsx                    # hourly temperature data
│   ├── relative_humidity.xlsx              # hourly humidity data
│   ├── submission_template.csv
│   └── csv_backup/                         # CSV copies of xlsx files
├── scripts/
│   ├── forecast_TBATS.R                    # standalone TBATS script
│   └── forecast_ARIMA.R                    # standalone ARIMA script
├── output/
│   ├── submission_TBATS.csv                # final Kaggle submission
│   └── history/                            # earlier experiment submissions
└── archive/                                # older drafts kept for reference
```

## Models Evaluated

| Model | Val MAPE (Jul 2010) |
|-------|:-------------------:|
| **TBATS** *(final)* | **11.34%** |
| SARIMA | 13.52% |
| STL + ETS | 14.49% |
| NNETAR | 14.95% |
| Seasonal Naive | 19.36% |

## Reproducibility

You can reproduce the final report by opening `Forecasting2026.Rproj` in RStudio and knitting `Wei_Pereira_CompetitionReport_S26.Rmd`.

Required R packages:

- `readxl`
- `dplyr`
- `tidyr`
- `lubridate`
- `ggplot2`
- `forecast`
- `knitr`
- `kableExtra`

You can also render the report from the console with:

```r
rmarkdown::render("Wei_Pereira_CompetitionReport_S26.Rmd")
```

## Final Deliverables

- Final report: [Wei_Pereira_CompetitionReport_S26.pdf](./Wei_Pereira_CompetitionReport_S26.pdf)
- Final report source: [Wei_Pereira_CompetitionReport_S26.Rmd](./Wei_Pereira_CompetitionReport_S26.Rmd)
- Final submission: [output/submission_TBATS.csv](./output/submission_TBATS.csv)

## Notes

This repository was prepared for a course competition project. The report is the main deliverable, and the supporting scripts and archived outputs are included for transparency and reproducibility.
