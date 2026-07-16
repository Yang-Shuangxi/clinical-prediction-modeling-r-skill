# Data-contract checks for clinical prediction projects.
# These functions are structural checks; they do not replace clinical review.

cp_dc_assert_columns <- function(data, columns) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame or tibble.", call. = FALSE)
  }
  absent <- setdiff(columns, names(data))
  if (length(absent)) {
    stop("Missing required column(s): ", paste(absent, collapse = ", "), call. = FALSE)
  }
  invisible(TRUE)
}

cp_key_audit <- function(data, key, allow_na = FALSE) {
  if (!is.character(key) || !length(key)) {
    stop("`key` must be a non-empty character vector.", call. = FALSE)
  }
  cp_dc_assert_columns(data, key)
  key_data <- data[key]
  missing_rows <- !stats::complete.cases(key_data)
  complete_keys <- key_data[!missing_rows, , drop = FALSE]
  duplicate_rows <- if (nrow(complete_keys)) {
    duplicated(complete_keys) | duplicated(complete_keys, fromLast = TRUE)
  } else {
    logical()
  }
  result <- list(
    key = key,
    n_rows = nrow(data),
    missing_key_rows = sum(missing_rows),
    duplicate_key_rows = sum(duplicate_rows),
    unique_complete_keys = nrow(unique(complete_keys)),
    is_unique = !any(missing_rows) && !any(duplicate_rows)
  )
  if (!allow_na && result$missing_key_rows) {
    result$is_unique <- FALSE
  }
  result
}

cp_assert_unique_key <- function(data, key, allow_na = FALSE) {
  audit <- cp_key_audit(data, key, allow_na = allow_na)
  if (audit$missing_key_rows && !allow_na) {
    stop(
      "Key contains ", audit$missing_key_rows,
      " missing row(s): ", paste(key, collapse = ", "),
      call. = FALSE
    )
  }
  if (audit$duplicate_key_rows) {
    stop(
      "Key is not unique; ", audit$duplicate_key_rows,
      " rows belong to duplicated key value(s): ", paste(key, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(audit)
}

cp_check_allowed_values <- function(data, column, allowed, allow_na = TRUE) {
  if (!is.character(column) || length(column) != 1L) {
    stop("`column` must be one column name.", call. = FALSE)
  }
  cp_dc_assert_columns(data, column)
  value <- data[[column]]
  if (!allow_na && anyNA(value)) {
    stop("Column `", column, "` contains missing values.", call. = FALSE)
  }
  observed <- value[!is.na(value)]
  invalid <- !as.character(observed) %in% as.character(allowed)
  if (any(invalid)) {
    shown <- unique(as.character(observed[invalid]))
    stop(
      "Unexpected value(s) in `", column, "`: ",
      paste(utils::head(shown, 10L), collapse = ", "),
      call. = FALSE
    )
  }
  list(column = column, allowed = allowed, observed = unique(observed), missing = sum(is.na(value)))
}

cp_normalize_join_by <- function(x, y, by) {
  if (!is.character(by) || !length(by)) {
    stop("`by` must be a non-empty character vector or named mapping.", call. = FALSE)
  }
  if (is.null(names(by))) {
    x_key <- unname(by)
    y_key <- unname(by)
  } else {
    if (any(!nzchar(names(by))) || any(!nzchar(unname(by)))) {
      stop("Join key names cannot be empty.", call. = FALSE)
    }
    x_key <- names(by)
    y_key <- unname(by)
  }
  cp_dc_assert_columns(x, x_key)
  cp_dc_assert_columns(y, y_key)
  list(x = x_key, y = y_key)
}

cp_key_tokens <- function(data, key) {
  pieces <- lapply(data[key], function(value) {
    value <- as.character(value)
    value[is.na(value)] <- "<NA>"
    value
  })
  do.call(paste, c(pieces, sep = "\034"))
}

cp_check_join_keys <- function(x, y, by,
                               relationship = c("one-to-one", "one-to-many", "many-to-one", "many-to-many"),
                               allow_na = FALSE) {
  relationship <- match.arg(relationship)
  keys <- cp_normalize_join_by(x, y, by)
  x_audit <- cp_key_audit(x, keys$x, allow_na = allow_na)
  y_audit <- cp_key_audit(y, keys$y, allow_na = allow_na)
  if (!allow_na && (x_audit$missing_key_rows || y_audit$missing_key_rows)) {
    stop("Join keys contain missing values; resolve or explicitly allow them first.", call. = FALSE)
  }
  if (relationship == "one-to-one" && (x_audit$duplicate_key_rows || y_audit$duplicate_key_rows)) {
    stop("Expected one-to-one join, but at least one side has duplicate keys.", call. = FALSE)
  }
  if (relationship == "one-to-many" && x_audit$duplicate_key_rows) {
    stop("Expected one-to-many join, so `x` must have unique keys.", call. = FALSE)
  }
  if (relationship == "many-to-one" && y_audit$duplicate_key_rows) {
    stop("Expected many-to-one join, so `y` must have unique keys.", call. = FALSE)
  }
  x_token <- cp_key_tokens(x, keys$x)
  y_token <- cp_key_tokens(y, keys$y)
  list(
    x_key = keys$x,
    y_key = keys$y,
    relationship = relationship,
    x = x_audit,
    y = y_audit,
    unmatched_x = sum(!x_token %in% y_token),
    unmatched_y = sum(!y_token %in% x_token)
  )
}

cp_check_time_order <- function(data, earlier, later, id = NULL, allow_equal = TRUE) {
  cp_dc_assert_columns(data, c(earlier, later))
  if (!is.null(id)) {
    if (!is.character(id) || length(id) != 1L) {
      stop("`id` must be one column name when supplied.", call. = FALSE)
    }
    cp_dc_assert_columns(data, id)
  }
  a <- data[[earlier]]
  b <- data[[later]]
  is_posix <- inherits(a, "POSIXt") || inherits(b, "POSIXt")
  is_date <- inherits(a, "Date") || inherits(b, "Date")
  if (is_posix && !(inherits(a, "POSIXt") && inherits(b, "POSIXt"))) {
    stop("Both time columns must be POSIXct/POSIXlt when either is POSIX.", call. = FALSE)
  }
  if (is_date && !(inherits(a, "Date") && inherits(b, "Date"))) {
    stop("Both time columns must be Date when either is Date.", call. = FALSE)
  }
  if (!is_posix && !is_date && !(is.numeric(a) && is.numeric(b))) {
    stop("Time columns must both be numeric, Date, or POSIXct/POSIXlt.", call. = FALSE)
  }
  complete <- !is.na(a) & !is.na(b)
  bad <- logical(length(a))
  if (any(complete)) {
    bad[complete] <- if (allow_equal) a[complete] > b[complete] else a[complete] >= b[complete]
  }
  list(
    earlier = earlier,
    later = later,
    id = id,
    incomplete = sum(!complete),
    violations = sum(bad),
    violation_rows = which(bad),
    violation_ids = if (is.null(id)) NULL else data[[id]][bad]
  )
}

cp_data_profile <- function(data) {
  if (!is.data.frame(data)) stop("`data` must be a data.frame or tibble.", call. = FALSE)
  profile <- lapply(data, function(value) {
    distinct <- tryCatch(length(unique(value[!is.na(value)])), error = function(e) NA_integer_)
    list(
      class = paste(class(value), collapse = "/"),
      type = typeof(value),
      n_missing = sum(is.na(value)),
      n_unique_nonmissing = distinct
    )
  })
  out <- data.frame(
    variable = names(profile),
    class = vapply(profile, `[[`, character(1), "class"),
    type = vapply(profile, `[[`, character(1), "type"),
    n_missing = vapply(profile, `[[`, integer(1), "n_missing"),
    n_unique_nonmissing = vapply(profile, `[[`, integer(1), "n_unique_nonmissing"),
    row.names = NULL,
    stringsAsFactors = FALSE
  )
  out
}
