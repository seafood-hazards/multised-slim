# Post-render: remove the downloaded databases, but ONLY in CI.
#
# The guard on the CI env var is deliberate: during local development `data/db`
# may be a symlink to live databases (or files you want to keep), and deleting
# after every `quarto render` would remove them. GitHub Actions sets CI=true, so
# the cleanup runs only on the runner, leaving local renders untouched.

if (!nzchar(Sys.getenv("CI"))) {
  message("not CI: keeping data/db")
} else {
  sources <- c("mareano", "vannmiljo", "ices_dome", "mudab", "4demon")
  for (s in sources) for (g in c("slim", "clean")) {
    f <- sprintf("data/db/%s_%s.sqlite", s, g)
    if (file.exists(f)) {
      message("remove: ", f)
      file.remove(f)
    }
  }
}
