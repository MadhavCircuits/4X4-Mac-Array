# Command cheat sheet

## Server setup (csh)
```
csh
source ~/cshrc_618
```

## Genus
```
genus -f syn/mac_genus.tcl | tee syn/genus_run.log
```
Key commands: `read_hdl -sv`, `elaborate`, `read_sdc`, `syn_generic`, `syn_map`, `syn_opt`, `report_area/timing/power/gates`, `write_hdl`, `write_sdc`.

## Innovus
```
innovus -init init_design.tcl -log innovus_run.log
```
| Stage | Command |
|---|---|
| Import | `init_design` |
| Floorplan | `floorPlan -site CoreSite -r 1.0 0.75 10 10 10 10` |
| Power | `globalNetConnect`, `addRing`, `sroute` |
| Pins | `setPinAssignMode`, `editPin` |
| Place | `place_design` |
| CTS | `create_ccopt_clock_tree_spec`, `ccopt_design` |
| Route | `routeDesign` |
| Timing | `setAnalysisMode -analysisType onChipVariation -cppr both`, `timeDesign -postRoute` |
| Reports | `reportCongestion -hotspot`, `report_area`, `summaryReport -noHtml` |
| Save/restore | `saveDesign x.enc`, `restoreDesign x.enc.dat mac_array_4x4` |

## Inspecting stages in the GUI
```
restoreDesign ../outputs/s1_floorplan.enc.dat mac_array_4x4   ;# floorplan
restoreDesign ../outputs/s2_power.enc.dat     mac_array_4x4   ;# power
restoreDesign ../outputs/s3_pins.enc.dat      mac_array_4x4   ;# pins
restoreDesign ../outputs/s4_place.enc.dat     mac_array_4x4   ;# placement
restoreDesign ../outputs/s5_cts.enc.dat       mac_array_4x4   ;# clock tree
restoreDesign ../outputs/s6_route.enc.dat     mac_array_4x4   ;# routed
fit
```
In the GUI use the Clock Tree Debugger for CTS and the layer visibility panel to show/hide metals and vias.

## Handy checks
```
dbget top.fplan.boxes          ;# core/die box
reportCongestion -hotspot
report_clock_tree_structure
```

## Simulation
```
./run_sim.sh
```
