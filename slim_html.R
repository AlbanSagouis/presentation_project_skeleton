# Slim a rendered Quarto revealjs file.
#
# Quarto always embeds the Source Sans Pro web font (and the "simple" theme adds
# Lato and News Cycle), about 4 MB in total. custom.scss uses system fonts, so
# those @font-face rules are never used. This removes them from the standalone
# HTML. Run it after every render:
#
#   quarto render <name>.qmd
#   Rscript slim_html.R <name>.html

args <- commandArgs(trailingOnly = TRUE)
checkmate::assert_string(x = args[[1]], .var.name = "path to the rendered html")
html_path <- args[[1]]
checkmate::assert_file_exists(x = html_path, extension = "html")

unused_families <- c("Source Sans Pro", "Lato", "News Cycle")

html <- readr::read_file(file = html_path)
size_before <- nchar(x = html, type = "bytes")

# The stylesheet is embedded url-encoded: "@font-face {" is "%40font%2Dface%20%7B"
# and "family: 'Lato'" is "family%3A%20%27Lato%27".
family_pattern <- stringi::stri_replace_all_fixed(
  str = unused_families,
  pattern = " ",
  replacement = "%20",
  vectorise_all = FALSE
) |>
  paste(collapse = "|")
font_face_pattern <- paste0(
  "%40font%2Dface%20%7B%0A?font%2Dfamily%3A%20%27(",
  family_pattern,
  ")%27.*?%7D(?=%0A)"
)

slim <- stringi::stri_replace_all_regex(
  str = html,
  pattern = font_face_pattern,
  replacement = ""
)

readr::write_file(x = slim, file = html_path)
size_after <- nchar(x = slim, type = "bytes")
cli::cli_alert_success(
  "{html_path}: {round(size_before / 1e6, digits = 1)} MB to {round(size_after / 1e6, digits = 1)} MB"
)
