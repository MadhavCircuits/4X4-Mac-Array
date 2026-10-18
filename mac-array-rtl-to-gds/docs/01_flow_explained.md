# Flow explained, stage by stage

## 1. RTL and simulation
`mac_unit` multiplies two 8-bit values, adds a 32-bit value and registers the result (sync reset, enable).
`mac_array_4x4` instantiates 16 of them. Testbenches check reset, a computed value, enable-hold and the 255*255+100 corner case.
Buses are flattened (`a[i*8 +: 8]`) so the top-level ports are plain vectors, which keeps P&R pin handling simple.

## 2. Constraints (SDC)
- `create_clock` 5 ns on `clk`.
- `set_input_delay` / `set_output_delay` 1 ns: leaves 3 ns of logic budget between input and output registers in the worst case, and tells the tool that outside logic uses part of the cycle.

## 3. Synthesis (Genus)
- `read_hdl` + `elaborate`: parse and build the generic design.
- `syn_generic`: technology-independent optimization.
- `syn_map`: map to library cells.
- `syn_opt`: timing/area optimization.
- Outputs: gate-level netlist, SDC, area/timing/power/gates reports.
- Physical LEFs are loaded so area numbers are real (without them area printed 0.000).

## 4. Floorplan
`floorPlan -site CoreSite -r 1.0 0.75 10 10 10 10`: aspect ratio 1.0, 75% core utilization, 10 um margin on every side. Result: die 155 x 153.52 um.

## 5. Power planning
Core ring on M10 (horizontal) and M11 (vertical), then `sroute` connects standard-cell power rails (follow pins) to the ring. `globalNetConnect` ties every VDD/VSS pin to the global nets.

## 6. Pin placement
1298 pins. Inputs a/b on the left, c on top (most pins, so tightest spacing), outputs y on the right, clk/rst/en at the bottom. Keeping inputs and outputs on opposite sides shortens routes through the datapath.

## 7. Placement
`place_design` with `-congEffort high`: global placement, then legalization on the site grid, then pre-CTS optimization.

## 8. Clock tree synthesis
`create_ccopt_clock_tree_spec` + `ccopt_design`. 512 flop sinks, balanced with clock buffers/inverters. CTS adds buffers (4864 -> 4940 cells) and optimizes skew.

## 9. Routing
`routeDesign` (NanoRoute): global routing, track assignment, detailed routing, then search-and-repair for DRC. Final: 0 DRC.

## 10. Post-route timing
`timeDesign -postRoute` with OCV analysis (`setAnalysisMode -analysisType onChipVariation -cppr both`). OCV is required, otherwise IMPOPT-7027.

## 11. Pending: signoff and GDS
Fillers (FILL1..FILL64), `verify_connectivity`, `verify_drc`, `verify_geometry`, then `streamOut` with a layer map. See `05_next_steps.md`.
