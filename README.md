# multised (slim)

Source for the **multised (slim)** website: documentation of the harmonised,
quality-controlled marine-sediment trace-element databases assembled from five
external sources (Mareano, Vannmiljo, ICES-DOME, MUDAB, 4Demon), and of how the
QC-passed "clean" databases are built from them.

The site is a [Quarto](https://quarto.org) website. Its pages read the SQLite
databases live at render time, so to build the site yourself you download the
databases and render locally. The databases themselves are not stored in this
repository.

Published site: <https://seafood-hazards.github.io/multised-slim/>

## Reproducing the site locally

### 1. Prerequisites

- [R](https://www.r-project.org/) 4.1 or newer (the code uses the native `|>` pipe)
- [Quarto](https://quarto.org/docs/get-started/) 1.4 or newer
- The R packages Quarto's knitr engine and the pages need:

  ```r
  install.packages(c("rmarkdown", "knitr", "DBI", "RSQLite", "dplyr", "tidyr", "tibble"))
  ```

### 2. Download the databases

The pages read ten SQLite databases from a `data/db/` folder (git-ignored): a
**slim** and a **clean** database for each of the five sources, all published on
this repository's [releases](https://github.com/seafood-hazards/multised-slim/releases).
The slim databases here are the *flagged* version the site reads (the common
schema plus the quality-control and marking flags); the original pre-flag slim
databases live on each source's pilot release and are not needed to build the
site.

You do not have to download these by hand: the site's `pre-render` step
(`_scripts/download-dbs.R`) fetches any that are missing into `data/db/` whenever
you `quarto render`, and the `post-render` step (`_scripts/cleanup-dbs.R`) removes
them again only in CI. The commands below are for fetching the databases without
rendering.

```bash
mkdir -p data/db
cd data/db

# Slim (flagged) and clean databases, from this repository's latest release
for s in mareano vannmiljo ices_dome mudab 4demon; do
  for gen in slim clean; do
    curl -LO https://github.com/seafood-hazards/multised-slim/releases/latest/download/${s}_${gen}.sqlite
  done
done
```

After this, `data/db/` should contain:

```
mareano_slim.sqlite    mareano_clean.sqlite
vannmiljo_slim.sqlite  vannmiljo_clean.sqlite
ices_dome_slim.sqlite  ices_dome_clean.sqlite
mudab_slim.sqlite      mudab_clean.sqlite
4demon_slim.sqlite     4demon_clean.sqlite
```

The **DB Design** and **Flagging** pages read the slim databases; the **Clean
Databases** pages read the clean ones (a couple compare the two), so all ten are
needed to render every page. Download links for all of them are also listed on
the site's [Database Downloads](database-downloads.qmd) page.

### 3. Render the site

```bash
quarto render     # builds the whole site into _site/
# or, for a live-reloading preview while editing:
quarto preview
```

The output lands in `_site/` (git-ignored).

### 4. Publishing

The site is published automatically by GitHub Actions
(`.github/workflows/publish.yml`) on every push to `main`: the workflow installs R
and Quarto, renders the site (the `pre-render` step downloads the databases and
the `post-render` step deletes them), and deploys to GitHub Pages. Enable it once
under **Settings > Pages > Source = GitHub Actions**; after that no local render
or manual upload is needed.

The site takes its databases from this repository's **latest** release, so no
tag has to be edited when a new one is published. `releases/latest/download/`
does not fall back to an older release, which means **every release must carry
all ten databases as assets**, or the next CI render fails. Use the helper,
which refuses to create the release if any asset is missing:

```bash
git tag -a vX.Y.Z -m "Release of vX.Y.Z" && git push origin vX.Y.Z
_scripts/publish-release.sh vX.Y.Z          # before pushing main
git push origin main
```

Set `DB_RELEASE` to pin an older release when reproducing a specific build:

```bash
DB_RELEASE=v0.1.0 quarto render
```

## Repository layout

```
*.qmd                     the site pages
_quarto.yml               site configuration; pre-render / post-render hooks
_scripts/                 database download (pre-render) and cleanup (post-render)
.github/workflows/        the GitHub Actions publish workflow
styles.css                small style overrides
image/                    images used by the pages
data/db/                  the SQLite databases (git-ignored; auto-downloaded)
_site/                    rendered output (git-ignored)
```
