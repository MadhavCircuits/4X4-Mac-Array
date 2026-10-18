# Single-corner (slow, 1.08 V, 125 C) view used for the baseline.
set LIBDIR /home/install/FOUNDRY/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045/timing

create_library_set -name slow_lib \
    -timing [list $LIBDIR/slow_vdd1v2_basicCells.lib]

create_rc_corner -name rc_typ -temperature 125

create_constraint_mode -name mac_constraints \
    -sdc_files [list /home/pbl1/Digital/mac_array/outputs/mac_array_synth.sdc]

create_delay_corner -name slow_corner \
    -library_set slow_lib -rc_corner rc_typ

create_analysis_view -name mac_view \
    -constraint_mode mac_constraints \
    -delay_corner slow_corner

set_analysis_view -setup {mac_view} -hold {mac_view}
