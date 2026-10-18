# Innovus flow: import -> floorplan -> power -> pins -> place -> CTS -> route -> reports.
# Run (csh, Cadence env loaded):  innovus -init pnr/init_design.tcl -log pnr/innovus_run.log
# Paths below are for the RVCE server; edit them for your setup.

set LEFDIR /home/install/FOUNDRY/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045/lef

set init_lef_file  [list $LEFDIR/gsclib045_tech.lef $LEFDIR/gsclib045_macro.lef]
set init_verilog   /home/pbl1/Digital/mac_array/outputs/mac_array_synth.v
set init_top_cell  mac_array_4x4
set init_mmmc_file /home/pbl1/Digital/mac_array/pnr/mmmc.tcl
set init_pwr_net   VDD
set init_gnd_net   VSS

init_design

# Same don't-use list as synthesis (avoids CoreSiteDouble cells / IMPSP-365)
set fh [open /home/pbl1/Digital/mac_array/syn/dontuse.txt r]
foreach c [read $fh] { setDontUse $c true }
close $fh

# ---- Floorplan: square core, 75% utilization, 10 um margins
floorPlan -site CoreSite -r 1.0 0.75 10 10 10 10
saveDesign ../outputs/s1_floorplan.enc

# ---- Power: ring on M10/M11, rails via sroute
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override
addRing -nets {VDD VSS} -layer {top M10 bottom M10 left M11 right M11} -width 2 -spacing 1 -offset 1
sroute -nets {VDD VSS}
saveDesign ../outputs/s2_power.enc

# ---- I/O pins (1298 pins spread over 4 edges)
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.1 -pinDepth 0.5 -fixOverlap 1 -unit micron -spacing 1.0 -side Left   -layer M3 -spreadType side -pin {a[*] b[*]}
editPin -pinWidth 0.1 -pinDepth 0.5 -fixOverlap 1 -unit micron -spacing 0.5 -side Top    -layer M2 -spreadType side -pin {c[*]}
editPin -pinWidth 0.1 -pinDepth 0.5 -fixOverlap 1 -unit micron -spacing 1.0 -side Right  -layer M3 -spreadType side -pin {y[*]}
editPin -pinWidth 0.1 -pinDepth 0.5 -fixOverlap 1 -unit micron -spacing 1.0 -side Bottom -layer M2 -spreadType side -pin {clk rst en[*]}
setPinAssignMode -pinEditInBatch false
saveDesign ../outputs/s3_pins.enc

# ---- Place
puts "=== STEP: PLACE ==="
setPlaceMode -congEffort high
place_design
saveDesign ../outputs/s4_place.enc

# ---- Clock tree
puts "=== STEP: CTS ==="
create_ccopt_clock_tree_spec
ccopt_design
saveDesign ../outputs/s5_cts.enc

# ---- Route
puts "=== STEP: ROUTE ==="
routeDesign
saveDesign ../outputs/s6_route.enc

# ---- Reports
puts "=== STEP: REPORTS ==="
reportCongestion -hotspot > ../reports/congestion_route.rpt
report_area > ../reports/area_route.rpt
summaryReport -noHtml -outfile ../reports/summary_route.rpt
setAnalysisMode -analysisType onChipVariation -cppr both
timeDesign -postRoute -outDir ../reports/timing_route
saveDesign ../outputs/mac_routed.enc

# ---- TODO (next): fillers, verify_drc / verify_connectivity, streamOut once the
#      digital GDS layer map is confirmed (see docs/05_next_steps.md).
exit
