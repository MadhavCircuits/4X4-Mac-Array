#!/usr/bin/env bash
# Functional simulation with Icarus Verilog:  ./run_sim.sh
set -e
iverilog -g2012 -s tb_mac_unit      -o mac_sim   rtl/mac_unit.sv tb/tb_mac_unit.sv
vvp mac_sim
iverilog -g2012 -s tb_mac_array_4x4 -o array_test rtl/mac_unit.sv rtl/mac_array_4x4.sv tb/tb_mac_array_4x4.sv
vvp array_test
