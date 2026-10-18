# Interview Q&A

## About this project

**Walk me through your project.**
I implemented a 4x4 array of 8-bit MAC units from RTL to a routed layout in a 45 nm library. I simulated with self-checking testbenches, synthesized with Genus at 5 ns (+443 ps slack), then did floorplan, power ring, pin placement, placement, CCOpt CTS, NanoRoute and OCV post-route timing in Innovus. Final: about 4.9k cells, 75% utilization, 0 DRC, 0 antenna violations.

**Biggest problem you faced?**
Routing failed with "no vias" (NRDB-158). The tech LEF I started with had 16 vias; the full gsclib045 v4.4 LEF has 135. Second was CoreSiteDouble: 62 double-height cells made placement fail, so I banned them in both Genus and Innovus.

**What are double-height cells?**
Cells like power switches, isolation cells, level shifters and retention flops that span two standard-cell rows. They need rows of the double-height site type; my floorplan only had single-height rows.

**Why is congestion zero? Is that good?**
The 16 MACs are independent with no shared buses, so it is an easy benchmark. A harder one (8x8, shared buses, tighter clock, higher utilization) would show hotspots.

**Why 75% utilization?**
Leaves room for CTS buffers, timing repair and routing. Higher utilization increases congestion and DRC risk.

**Why put c[*] on the top edge?**
530 pins at 1 um spacing did not fit on one edge. The top edge with 0.5 um spacing fits.

**Why was OCV mode needed?**
Post-route signoff must consider on-chip variation (derating on launch/capture paths); Innovus refuses the post-route analysis otherwise. CPPR removes pessimism on the common clock path.

## Physical design fundamentals

**Setup vs hold?**
Setup: data must arrive before the capture edge minus setup time (fix: faster logic, upsize, restructure). Hold: data must not change until hold time after the edge (fix: insert delay buffers). Setup depends on clock period; hold does not.

**What is slack, WNS, TNS?**
Slack = required time - arrival time. WNS = worst negative slack. TNS = sum of all negative slacks.

**What is CTS and why needed?**
Distributes the clock to all flops with low skew and controlled latency/transition. Without it, a single net drives hundreds of flops with huge skew and slew.

**What is clock skew? Useful skew?**
Difference in clock arrival between flops. Useful skew intentionally delays a capture clock to borrow time from a critical path.

**What does the power ring do? Why different metals?**
Distributes VDD/VSS around the core and feeds the stripes/rails with low IR drop. Upper thick metals have low resistance; horizontal and vertical layers alternate to avoid shorts.

**What is IR drop? Electromigration?**
IR drop: voltage lost on the power network (I*R) lowering supply at cells. EM: metal atom migration under high current density; fixed by wider wires or more vias.

**What are antenna violations?**
Charge collected on a long metal during plasma etching can damage a gate. Fixed by jumpers (layer hopping), antenna diodes, or reordering routing.

**What are fillers and decaps?**
Fillers fill empty row space so power rails and wells are continuous and density rules are met. Decaps add decoupling capacitance for the supply.

**What do DRC, LVS, and connectivity check?**
DRC: geometric design rules. LVS: layout vs schematic/netlist equality. Connectivity: opens/shorts in the routed nets.

**Steps in floorplanning?**
Die/core size and aspect ratio, utilization, macro placement, I/O pin placement, power planning, blockages.

**Global vs detailed placement?**
Global: approximate positions minimizing wirelength/congestion (may overlap). Detailed/legalization: snap to rows and site grid with no overlap.

**Why is a multi-corner multi-mode (MMMC) setup used?**
Timing depends on PVT and on the operating mode; signoff must pass in all corners/modes. Setup is worst at slow corners, hold at fast corners. This project uses one slow corner for the baseline.

**How to fix a setup violation?**
Upsize or swap Vt on cells in the path, buffer long nets, restructure logic, reduce load, useful skew, relax constraints if legitimate, pipeline in RTL.

**How to reduce congestion?**
Lower utilization, congestion-driven placement, cell padding, adjust pin placement, add blockages, use more routing layers, restructure netlist.

## RTL / DV side

**Why a self-checking testbench?**
It reports PASS/FAIL automatically with `$fatal`, so it can run in regression without reading waveforms.

**Tests included?**
Reset behavior, a normal multiply-add (10*20+50), enable-hold, maximum operands (255*255+100 = 65125), and all 16 MAC instances with distinct inputs.

**Blocking vs non-blocking?**
Use `<=` in clocked `always_ff` blocks, `=` in combinational blocks, to avoid races and simulation/synthesis mismatch.

**What would you add for stronger verification?**
Random stimulus with a scoreboard/reference model, coverage (corner values, enable toggling, reset mid-operation), assertions, and gate-level simulation with SDF.
