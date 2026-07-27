# Pre-render: fetch the SQLite databases the site reads from the GitHub release.
#
# Change the release tag in ONE place below (or set the DB_RELEASE env var to
# override, e.g. in the publish workflow). Files that already exist are skipped,
# so a local `data/db` (which may be a symlink to live databases during pipeline
# development) is never overwritten.

tag     <- Sys.getenv("DB_RELEASE", "v0.1.0")
repo    <- "seafood-hazards/multised-slim"
sources <- c("mareano", "vannmiljo", "ices_dome", "mudab", "4demon")
gens    <- c("slim", "clean")

base <- sprintf("https://github.com/%s/releases/download/%s", repo, tag)
dir.create("data/db", recursive = TRUE, showWarnings = FALSE)

for (s in sources) for (g in gens) {
  dest <- sprintf("data/db/%s_%s.sqlite", s, g)
  if (file.exists(dest)) {
    message("skip (exists): ", dest)
    next
  }
  url <- sprintf("%s/%s_%s.sqlite", base, s, g)
  message("download: ", url)
  ok <- utils::download.file(url, dest, mode = "wb", quiet = TRUE)
  if (ok != 0 || !file.exists(dest)) {
    stop("failed to download ", url)
  }
}
