# Structural checks for prediction-model analyses.
# Source this file; it intentionally uses only base R.

cp_assert_columns <- function(data, columns) {
  if (!is.data.frame(data)) stop("`data` must be a data.frame.", call. = FALSE)
  absent <- setdiff(columns, names(data))
  if (length(absent)) {
    stop("Missing required column(s): ", paste(absent, collapse = ", "), call. = FALSE)
  }
  invisible(TRUE)
}

cp_check_formula <- function(formula, data) {
  variables <- all.vars(stats::terms(formula))
  cp_assert_columns(data, variables)
  list(formula = formula, variables = variables, n = nrow(data))
}

cp_check_binary_outcome <- function(data, outcome) {
  cp_assert_columns(data, outcome)
  value <- data[[outcome]]
  missing <- sum(is.na(value))
  observed <- value[!is.na(value)]
  values <- unique(observed)
  if (length(values) != 2L) {
    stop("Binary outcome must contain exactly two observed levels/codes.", call. = FALSE)
  }
  tab <- table(observed, useNA = "no")
  list(
    outcome = outcome,
    n = length(value),
    missing = missing,
    levels_or_codes = names(tab),
    counts = tab,
    events_minimum = min(tab)
  )
}

cp_check_time_to_event <- function(data, time, status, event_code = 1) {
  cp_assert_columns(data, c(time, status))
  follow_up <- data[[time]]
  event <- data[[status]]
  if (!is.numeric(follow_up) || any(!is.finite(follow_up[!is.na(follow_up)]))) {
    stop("Follow-up time must be finite numeric values.", call. = FALSE)
  }
  if (any(follow_up[!is.na(follow_up)] < 0)) {
    stop("Follow-up time cannot be negative.", call. = FALSE)
  }
  complete <- !is.na(follow_up) & !is.na(event)
  event_count <- sum(event[complete] == event_code)
  if (!event_count) stop("No observations have the selected event code.", call. = FALSE)
  list(
    time = time,
    status = status,
    event_code = event_code,
    n = nrow(data),
    complete_cases = sum(complete),
    missing_time_or_status = sum(!complete),
    event_count = event_count,
    status_counts = table(event, useNA = "ifany"),
    time_range = range(follow_up[complete], na.rm = TRUE)
  )
}

cp_missingness <- function(data, variables = names(data)) {
  cp_assert_columns(data, variables)
  n <- nrow(data)
  missing <- vapply(data[variables], function(x) sum(is.na(x)), integer(1))
  data.frame(
    variable = names(missing),
    missing_n = unname(missing),
    missing_pct = if (n) 100 * unname(missing) / n else NA_real_,
    row.names = NULL
  )
}

cp_stratified_split <- function(data, outcome, train_fraction = 0.70, seed = 20260714) {
  cp_check_binary_outcome(data, outcome)
  if (!is.numeric(train_fraction) || length(train_fraction) != 1L ||
      train_fraction <= 0 || train_fraction >= 1) {
    stop("`train_fraction` must be strictly between 0 and 1.", call. = FALSE)
  }
  if (anyNA(data[[outcome]])) {
    stop("Resolve or explicitly handle missing outcome values before splitting.", call. = FALSE)
  }
  set.seed(seed)
  index <- unlist(lapply(split(seq_len(nrow(data)), data[[outcome]]), function(ids) {
    sample(ids, size = max(1L, floor(length(ids) * train_fraction)))
  }), use.names = FALSE)
  list(
    train = data[sort(index), , drop = FALSE],
    test = data[setdiff(seq_len(nrow(data)), index), , drop = FALSE],
    seed = seed
  )
}

