# Next steps

## 1. Finish signoff and GDSII (pending)
Append to the end of `pnr/init_design.tcl` (before `exit`):
```
addFiller -cell {FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1} -prefix FILL
verify_connectivity -type all -report ../reports/connectivity.rpt
verify_drc          -report ../reports/drc.rpt
verify_geometry     -report ../reports/geometry.rpt
saveDesign ../outputs/mac_final.enc
streamOut ../outputs/mac_array_4x4.gds -mapFile <layer.map> -libName DesignLib -merge {<gsclib045.gds>} -units 1000 -mode ALL
```
Open item: the digital GDS layer map file. Find it with `find <gsclib045 dir> -name "*.map" -o -name "*layermap*"`. If none exists, the Innovus/Virtuoso `.tf` techfile or the analog `gpdk045.layermap` is the starting point.
The standard-cell GDS is `gsclib045.gds` (merge it so cell geometry is in the final file).

## 2. Capture the timing numbers
Record WNS/TNS from `../reports/timing_route` after route into `results/results_summary.md`.

## 3. Harder benchmark
8x8 array or shared operand buses, ~3 ns clock, 80%+ utilization, so congestion and timing repair are exercised.

## 4. Extras for the portfolio
- Hold-corner (fast lib) in MMMC.
- Power report and IR-drop view.
- Random-stimulus testbench with scoreboard and coverage.
- Hotspot-aware placement/cost-function experiment.
