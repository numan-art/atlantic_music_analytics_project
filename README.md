# Atlantic U.S. Top 50 Playlist Analytics

Analytics project for Atlantic Recording Corporation's daily U.S. Top 50 playlist
snapshots: ranking stability, song longevity, artist dominance, popularity, and
content-attribute analysis, delivered as a Streamlit dashboard plus written
research paper and government executive summary.

## Project Structure

```
project/
├── app.py                       # Streamlit dashboard (entry point)
├── requirements.txt
├── README.md
├── tests_manual.py               # Smoke-test harness covering every module + edge cases
├── data/
│   └── Atlantic_United_States.csv
├── src/
│   ├── preprocessing.py          # Load, validate, clean the raw CSV
│   ├── feature_engineering.py    # days_on_chart, average_rank, volatility, dominance index, etc.
│   ├── analysis.py               # All ranking/song/artist/popularity/content analysis
│   └── visualizations.py         # Plotly chart builders used by app.py
├── research_paper/
│   └── research_paper.md         # Full analytical report (sections 1-20)
├── executive_summary/
│   └── executive_summary.md      # Non-technical summary for government stakeholders
└── outputs/                      # (scratch space for exported figures/tables, if generated)
```

## Setup

```bash
pip install -r requirements.txt
```

## Running the Dashboard

```bash
streamlit run app.py
```

The dashboard reads `data/Atlantic_United_States.csv`, cleans it with the same
pipeline used for the written reports, and exposes:

- **Global filters** (sidebar): date range, artist, song, position range (1–50),
  album type — all routed through a single reusable `filter_data()` function.
- **KPI bar**: Days on Chart, Average Rank, Rank Volatility Index, Popularity
  Score Trend, Artist Dominance Index (top artist), Explicit Content Share —
  all recomputed live from the filtered data.
- **Views**: Overview, Song Performance, Artist Reach, Audience & Content, and
  Catalog Signals. Related analyses are grouped together to keep the dashboard
  focused while preserving the underlying analytical functions.

## Data Notes (see `research_paper/research_paper.md` Section 7 for full detail)

- Raw file: 27,800 rows, no missing values.
- One date (2025-03-01) contained a duplicated 100-row snapshot; the pipeline
  deduplicates it back to 50 rows, keeping the first occurrence.
- Four calendar days in range have no snapshot at all and are left as genuine
  gaps rather than imputed.
- Cleaned dataset: 27,750 rows across 555 unique snapshot dates, 977 unique
  (song, artist) entries, 297 unique artists.

## Reproducing the Analysis Outside the Dashboard

```bash
python3 src/preprocessing.py        # prints the data-quality report
python3 src/feature_engineering.py  # prints sample engineered output
python3 src/analysis.py             # prints KPI and correlation output
python3 tests_manual.py             # runs the full smoke-test suite
```

## Deliverables

| Deliverable | Location |
|---|---|
| Streamlit dashboard | `app.py` |
| Research paper | `research_paper/research_paper.md` |
| Government executive summary | `executive_summary/executive_summary.md` |

## Key Methodological Notes

- All findings are correlational; no causal claims are made anywhere in the
  code, dashboard, or written deliverables.
- The Artist Dominance Index equally weights four normalized components
  (chart-day presence, unique songs, average rank, average popularity)
  because the brief provided no stakeholder-specified weighting — this is an
  explicit, documented assumption, not an optimized or validated weighting.
- No data was fabricated at any stage. Where something could not be computed
  from the source columns, it was left out rather than estimated.
