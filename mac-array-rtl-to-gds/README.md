# 4x4 MAC Array: RTL to Routed Layout (Cadence Genus + Innovus, GPDK 45 nm)

A complete digital implementation flow for a 16-unit multiply-accumulate (MAC) array:
SystemVerilog RTL, simulation, logic synthesis, floorplan, power planning, pin placement,
placement, clock tree synthesis, routing and post-route timing.

> **Status:** RTL -> routed design is done and clean (0 DRC, 0 antenna violations).
> The last step (filler insertion, final verify and GDSII stream-out) is still pending. See [docs/05_next_steps.md](docs/05_next_steps.md).

## Design

| Item | Value |
|---|---|
| Function | `y <= a*b + c` per MAC, 8-bit x 8-bit multiply, 32-bit accumulate input, registered output |
| Array | 16 independent MAC units (4x4), generated with `generate` |
| Ports | clk, rst, en[15:0], a[127:0], b[127:0], c[511:0], y[511:0] (1298 pins) |
| Clock | 200 MHz (5.0 ns), I/O delay 1.0 ns |
| Technology | Cadence GPDK045 `gsclib045_all_v4.4`, slow corner (1.08 V, 125 C) |
| Tools | Icarus Verilog, Genus 21.1, Innovus 21.15 |

## Flow

```
RTL (SystemVerilog)
   | iverilog / vvp          functional simulation
   v
Genus                        syn_generic -> syn_map -> syn_opt   -> netlist + SDC
   v
Innovus
   init_design               netlist + LEF + MMMC
   floorPlan                 75% utilization, square core
   addRing / sroute          VDD/VSS ring (M10/M11) + standard-cell rails
   editPin                   1298 pins on four edges
   place_design              congestion-driven global + detail placement
   ccopt_design              clock tree synthesis (CCOpt)
   routeDesign               NanoRoute global + detail route
   timeDesign -postRoute     OCV timing signoff
   [pending] addFiller, verify_drc/connectivity, streamOut GDSII
```

## Results (baseline run)

| Metric | Value |
|---|---|
| Cells after synthesis | 4864 |
| Cell area (synthesis) | 13,488 um^2 |
| Setup slack at 5 ns (synthesis) | **+443 ps** |
| Std cells after P&R (incl. clock buffers) | 4940 |
| Die / core | 155.0 x 153.52 um / 135 x 133.38 um |
| Utilization | 75% |
| Clock tree | 512 sinks, 6 leaf buffers |
| Total wire length | 160,654 um |
| DRC violations after route | 0 |
| Antenna violations | 0 |
| Congestion hotspot score | 0.00 / 0.00 |

Details: [results/results_summary.md](results/results_summary.md).

## Layout screenshots

Grouped by flow step in [results/gallery.md](results/gallery.md).

| Placement | Clock tree | Routed |
|---|---|---|
| ![placement](results/images/01_placement_overview.png) | ![clock tree](results/images/06_cts_clock_tree_debugger.png) | ![routed](results/images/11_route_all_layers_final.png) |

## Repository layout

```
rtl/           mac_unit.sv, mac_array_4x4.sv
tb/            self-checking testbenches
constraints/   mac_array.sdc
syn/           mac_genus.tcl, dontuse.txt
pnr/           mmmc.tcl, init_design.tcl
docs/          flow explanation, issues & fixes, interview Q&A, command cheat sheet
results/       results summary, screenshot gallery (gallery.md), images/
run_sim.sh     runs both testbenches
```

## How to run

**1. Simulation (any machine with Icarus Verilog)**
```
./run_sim.sh
```

**2. Synthesis (Cadence server, csh)**
```
csh
source ~/cshrc_618
cd <repo>
genus -f syn/mac_genus.tcl | tee syn/genus_run.log
```

**3. Place and route**
```
cd pnr
innovus -init init_design.tcl -log innovus_run.log
```
Absolute paths in the Tcl files point to the course server (`/home/pbl1/Digital/mac_array`). Change them to your own directory.

To inspect a stage in the GUI, restore a checkpoint: `restoreDesign ../outputs/s4_place.enc.dat mac_array_4x4`, then `fit`.

## Where to read first (revision order)

1. [docs/01_flow_explained.md](docs/01_flow_explained.md): what each step does and why.
2. [docs/02_issues_and_fixes.md](docs/02_issues_and_fixes.md): real problems hit and how they were solved (great interview material).
3. [docs/03_interview_qa.md](docs/03_interview_qa.md): questions and answers.
4. [docs/04_commands_cheatsheet.md](docs/04_commands_cheatsheet.md): commands to remember.

## Limitations

- The 16 MACs are independent, so routing is easy and congestion is zero. A harder benchmark (8x8 array, shared buses, ~3 ns clock, higher utilization) is needed to see real hotspots.
- Single corner (slow) only; no hold-corner or multi-mode analysis yet.
- The standard-cell library is a teaching library, not a production PDK.
