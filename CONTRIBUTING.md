# Contributing

Contributions are welcome for additional PDK products, improved measurements, verified pinouts, artwork corrections, and installer improvements.

## Naming

User-facing filenames and titles must use only the product name and part number.

Good:

```text
PDK_Red_4_Expander_R4E.fzpz
PDK Red 4 Expander (R4E)
```

Avoid:

```text
Actual
Exact
1to1
MountFit
RedMax
Fritzing72
Hotfix
```

Those details belong in release notes and Git history.

## SVG requirements

Every SVG view must:

- Use 72 viewBox units per physical inch
- Use a plain default SVG namespace
- Contain no generated `ns0:` or `ns1:` prefixes
- Contain unique IDs
- Preserve every connector ID referenced by the FZP

## Measurements

Preferred evidence:

1. Manufacturer mechanical drawing
2. Physical caliper measurements
3. Exact-scale scan
4. Verified enclosure mounting pattern
5. Known connector pitch
6. Manual illustration

## Connector pitch

Standard 0.100-inch headers must be modeled as exactly 2.54 mm center-to-center. When source artwork is distorted, correct the artwork rather than moving connector geometry off-grid.

## Module IDs

Use a fresh module ID for a geometrically incompatible revision. Do not expose revision or calibration wording in the visible title.

## Installer changes

The Windows installer must remain non-administrative and write only to the user's `Documents\Fritzing` tree. It must back up replaced files.
