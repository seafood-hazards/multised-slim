# Pre-render: fetch the SQLite databases the site reads from the GitHub release.
#
# The databases come from the LATEST release, so no tag is edited here. That
# means EVERY release must carry all ten databases as assets, or the next render
# 404s: use _scripts/publish-release.sh, which uploads them in one command.
#
# Set DB_RELEASE to pin an older release (e.g. DB_RELEASE=v0.1.0) when you need
# to reproduce a specific build. Files that already exist are skipped, so a local
# `data/db` (which may be a symlink to live databases during pipeline
# development) is never overwritten.

tag     <- Sys.getenv("DB_RELEASE", "latest")
repo    <- "seafood-hazards/multised-slim"
sources <- c("mareano", "vannmiljo", "ices_dome", "mudab", "4demon")
gens    <- c("slim", "clean")

base <- if (identical(tag, "latest")) {
  sprintf("https://github.com/%s/releases/latest/download", repo)
} else {
  sprintf("https://github.com/%s/releases/download/%s", repo, tag)
}
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
