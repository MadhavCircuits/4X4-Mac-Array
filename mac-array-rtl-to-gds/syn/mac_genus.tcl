# Genus synthesis. Run:  genus -f syn/mac_genus.tcl | tee syn/genus_run.log
# Edit ROOT_DIR to where you cloned the repo on the server.
set DESIGN   mac_array_4x4
set ROOT_DIR /home/pbl1/Digital/mac_array
set GP       /home/install/FOUNDRY/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045
set LIB_FILE "$GP/timing/slow_vdd1v2_basicCells.lib"

file mkdir "$ROOT_DIR/reports"
file mkdir "$ROOT_DIR/outputs"

set_db init_hdl_search_path [list "$ROOT_DIR/rtl"]
set_db init_lib_search_path [list "$GP/timing"]
set_db library $LIB_FILE
set_db lef_library [list $GP/lef/gsclib045_tech.lef $GP/lef/gsclib045_macro.lef]

read_hdl -sv [list "$ROOT_DIR/rtl/mac_unit.sv" "$ROOT_DIR/rtl/mac_array_4x4.sv"]
elaborate $DESIGN

# Ban the 62 cells that need the CoreSiteDouble (double-height) site
set fh [open "$ROOT_DIR/syn/dontuse.txt" r]
set bad [read $fh]
close $fh
foreach c $bad {
    set_db [get_db base_cells $c] .dont_use true
}

read_sdc "$ROOT_DIR/constraints/mac_array.sdc"
check_design -unresolved > "$ROOT_DIR/reports/check_design.rpt"

syn_generic
syn_map
syn_opt

report_area   > "$ROOT_DIR/reports/area.rpt"
report_timing > "$ROOT_DIR/reports/timing.rpt"
report_power  > "$ROOT_DIR/reports/power.rpt"
report_gates  > "$ROOT_DIR/reports/gates.rpt"

write_hdl > "$ROOT_DIR/outputs/mac_array_synth.v"
write_sdc > "$ROOT_DIR/outputs/mac_array_synth.sdc"
exit
