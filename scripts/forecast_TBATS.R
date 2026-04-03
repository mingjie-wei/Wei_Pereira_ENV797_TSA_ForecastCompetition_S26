# Model: TBATS on msts() with seasonal.periods = c(7, 365.25); ETS(weekly) fallback.
# From repo root: Rscript scripts/forecast_TBATS.R

req <- c("readxl", "dplyr", "forecast")
miss <- req[!vapply(req, requireNamespace, logical(1), quietly = TRUE)]
if (length(miss)) {
  stop(
    "Missing packages: ", paste(miss, collapse = ", "),
    "\nInstall with: install.packages(c(",
    paste0("\"", miss, "\"", collapse = ", "), "))",
    call. = FALSE
  )
}

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(forecast)
})

repo_root <- getwd()
load_path <- file.path(repo_root, "data", "load.xlsx")
template_path <- file.path(repo_root, "data", "submission_template.csv")
out_dir <- file.path(repo_root, "output")
out_csv <- file.path(out_dir, "submission_TBATS.csv")

if (!file.exists(load_path)) {
  stop("data/load.xlsx not found. Run this script from the repository root.", call. = FALSE)
}

hour_cols <- paste0("h", 1:24)

read_load_daily <- function(path) {
  readxl::read_excel(path) |>
    dplyr::mutate(date = as.Date(.data$date)) |>
    dplyr::mutate(
      load_day = rowMeans(dplyr::across(dplyr::all_of(hour_cols)), na.rm = TRUE)
    ) |>
    dplyr::select("meter_id", "date", "load_day") |>
    dplyr::arrange(.data$date)
}

daily <- read_load_daily(load_path)

stopifnot(!anyNA(daily$load_day))

mape_pct <- function(actual, predicted) {
  ok <- actual != 0 & is.finite(actual) & is.finite(predicted)
  100 * mean(abs((actual[ok] - predicted[ok]) / actual[ok]))
}

fit_and_forecast <- function(y_numeric, h, label) {
  y_msts <- msts(y_numeric, seasonal.periods = c(7, 365.25))
  fit <- tryCatch(
    tbats(y_msts),
    error = function(e) NULL
  )
  if (!is.null(fit)) {
    message("Model: TBATS (", label, ")")
    return(list(fit = fit, fc = forecast::forecast(fit, h = h)))
  }
  y7 <- stats::ts(y_numeric, frequency = 7)
  fit <- forecast::ets(y7)
  message("Model: ETS(weekly) fallback (", label, ")")
  list(fit = fit, fc = forecast::forecast(fit, h = h))
}

# ---- Hold-out: train through 2010-06-30, forecast 2010-07 (31 days) ----
train_end <- as.Date("2010-06-30")
val_start <- as.Date("2010-07-01")
val_end <- as.Date("2010-07-31")

train2010 <- daily |>
  dplyr::filter(.data$date <= train_end)
val2010 <- daily |>
  dplyr::filter(.data$date >= val_start, .data$date <= val_end)

res2010 <- fit_and_forecast(
  train2010$load_day,
  h = nrow(val2010),
  label = "train through 2010-06-30"
)
fc2010 <- as.numeric(res2010$fc$mean)
message(
  "Hold-out MAPE (Jul 2010): ",
  format(round(mape_pct(val2010$load_day, fc2010), 2), nsmall = 2),
  "%"
)

# ---- Final: train through 2011-06-30, forecast July 2011 ----
train_final <- daily |>
  dplyr::filter(.data$date <= as.Date("2011-06-30"))

res_final <- fit_and_forecast(
  train_final$load_day,
  h = 31,
  label = "train through 2011-06-30"
)
fc_july2011 <- as.numeric(res_final$fc$mean)

tpl <- read.csv(template_path, stringsAsFactors = FALSE)
if (nrow(tpl) != length(fc_july2011)) {
  stop("submission_template row count does not match forecast horizon (31).", call. = FALSE)
}
tpl$load <- round(fc_july2011, digits = 2)

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
write.csv(tpl, out_csv, row.names = FALSE)
message("Wrote: ", out_csv)
