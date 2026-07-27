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
- The R packages used by the pages:

  ```r
  install.packages(c("DBI", "RSQLite", "dplyr", "tidyr", "tibble", "knitr"))
  ```

### 2. Download the databases

The pages read ten SQLite databases from a `data/db/` folder (git-ignored): a
**slim** and a **clean** database for each of the five sources. The slim
databases are published on each source's pilot release; the clean databases are
published on this repository's releases.

```bash
mkdir -p data/db
cd data/db

# Slim databases (each source's pilot release)
curl -LO https://github.com/seafood-hazards/mareano-pilot/releases/download/v0.1.16/mareano_slim.sqlite
curl -LO https://github.com/seafood-hazards/vannmiljo-pilot/releases/download/v0.1.16/vannmiljo_slim.sqlite
curl -LO https://github.com/seafood-hazards/ices-dome-pilot/releases/download/v0.1.17/ices_dome_slim.sqlite
curl -LO https://github.com/seafood-hazards/mudab-pilot/releases/download/v0.1.4/mudab_slim.sqlite
curl -LO https://github.com/seafood-hazards/4demon-pilot/releases/download/v0.1.0/4demon_slim.sqlite

# Clean databases (this repository's release)
for s in mareano vannmiljo ices_dome mudab 4demon; do
  curl -LO https://github.com/seafood-hazards/multised-slim/releases/download/v0.1.0/${s}_clean.sqlite
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
needed to render every page. The download links for the slim databases are also
listed on the site's [Database Downloads](database-downloads.qmd) page.

### 3. Render the site

```bash
quarto render     # builds the whole site into _site/
# or, for a live-reloading preview while editing:
quarto preview
```

The output lands in `_site/` (git-ignored).

### 4. Publish (optional)

GitHub Pages runs Jekyll by default, which ignores the `_`-prefixed asset
directories Quarto emits, so an empty `.nojekyll` file must sit at the served
root. The simplest route is Quarto's built-in publisher, which handles this for
you and pushes the rendered site to a `gh-pages` branch:

```bash
quarto publish gh-pages
```

Alternatively, copy the **contents** of `_site/` (including a `.nojekyll` file) to
wherever you serve the site.

## Repository layout

```
*.qmd            the site pages
_quarto.yml      site configuration and navigation
styles.css       small style overrides
image/           images used by the pages
data/db/         the SQLite databases (git-ignored; you download these)
_site/           rendered output (git-ignored)
```
