# Agent and contributor guide

## Project purpose

This project compares Airbnb listing snapshots for Lisbon with the official Portuguese local-accommodation register. It identifies licence matches, formatting mismatches, possible repeated use of licence numbers, and listings whose apparent location differs from the official record.

The analysis is investigative. A result is an indicator for verification, not a legal finding that a listing or establishment is illegal.

## Running the project

Install dependencies:

```bash
bundle install
```

Run the analysis:

```bash
bundle exec ruby run_me.rb
```

The script downloads missing source snapshots, prints overall and per-freguesia statistics, classifies repeated licence groups, and writes:

```text
data_sources/data_transformed/result.csv
```

Run tests:

```bash
ruby -Itest test/al_ilegal_test.rb
ruby -Itest test/spatial_clusters_test.rb
```

Ruby syntax checks:

```bash
ruby -c run_me.rb
ruby -c lib/al_ilegal.rb
ruby -c lib/al_ilegal/data.rb
```

## Data and reproducibility

Raw data under `data_sources/*.csv` and cached files under `tmp/` are intentionally ignored by Git. The Airbnb snapshot date is configured in `lib/al_ilegal/data.rb`; update it only after verifying the corresponding public Inside Airbnb archive URL.

The official register is downloaded with the current date in its filename. The analysis uses the dated file returned by the downloader, not an older undated copy.

Airbnb `last_scraped` values are listing-level collection dates and may span several days. They are not necessarily the same as the archive snapshot date.

## Matching and classification

Licence values are normalized conservatively. Leading zeroes and clear `/AL` or legacy year formats may be normalized; other schemes such as `/UT/YYYY` must not be treated as AL registration numbers.

Repeated licence numbers are not automatically collapsed. The classifier uses spatial clusters within 500 metres, listing names, room/property types, official establishment type, and official municipality. `host_id` is retained as metadata but is not used as a merge criterion.

The output distinguishes, among other categories:

- likely establishments with multiple room/unit listings;
- repeated licences in the same location;
- the same licence appearing in multiple locations;
- licences officially registered outside Lisbon;
- listings with no identifiable licence.

The establishment-level figure printed by the script is an analytical estimate. It collapses only the lower-risk repeated-location categories and leaves suspicious reuse cases separate.

## Editing guidance

- Preserve `licensa_raw` when changing licence parsing so the source value remains auditable.
- Add regression tests for new licence formats and spatial rules.
- Do not describe unmatched or geographically inconsistent listings as illegal without official validation.
- Do not commit raw downloaded datasets unless explicitly requested.
- The PDF and Markdown report are working publication artefacts and should be updated separately from code/data commits.
