# Issues hit and how they were fixed

Each row is a real problem from this project. Interview-ready: symptom, root cause, fix.

| # | Symptom | Root cause | Fix |
|---|---|---|---|
| 1 | NRDB-158 / IMPCCOPT-5053 "no vias" during CTS/route | An older tech LEF with only 16 vias was used; NanoRoute lacked the via set it needs | Use `gsclib045_all_v4.4` LEFs (`gsclib045_tech.lef`, 135 vias) in both Genus and Innovus |
| 2 | IMPSP-365 placement failure about `CoreSiteDouble` | 62 library cells (power-switch, isolation, level-shifter, retention flops, BUFX2, PINVX1) are double-height; the floorplan only has single-height `CoreSite` rows | Put them in `syn/dontuse.txt`; `dont_use` in Genus and `setDontUse` in Innovus. Netlist verified to contain none of them |
| 3 | IMPCCOPT-4254 "design not placed" | `ccopt_design` was run before `place_design` | Add `place_design` before CTS |
| 4 | IMPOPT-7027 at post-route `timeDesign` | Post-route timing requires OCV analysis mode | `setAnalysisMode -analysisType onChipVariation -cppr both` |
| 5 | `editPin` error / bottom edge could not fit 530 pins | `-spacing` needs `-unit micron`; 530 `c[*]` pins at 1 um spacing exceed the edge length | Move `c[*]` to the top edge with 0.5 um spacing |
| 6 | Wrong layer names in `addRing` (Metal10/Metal11) | LEF layer names are `M10`/`M11` (GUI shows Metal10) | Use LEF names in Tcl |
| 7 | Genus area report showed 0.000 | Library loaded without physical (LEF) info | Add `lef_library` before elaborate |
| 8 | `report_congestion` invalid command | Innovus 21.1 uses a different name | `reportCongestion -hotspot` |
| 9 | `innovus: command not found` | New shell had no Cadence environment | `csh; source ~/cshrc_618` after each login |
| 10 | csh: "Ambiguous output redirect", "Undefined variable", silent heredoc failure | Server shell is csh, not bash; `2>/dev/null` and heredocs behave differently | Avoid them; edit files with `gedit` |
| 11 | Typing a file path alone gave "Permission denied" | The shell tried to execute the file | Open it with an editor |
| 12 | Innovus console ran a shell command | Unknown Innovus commands fall through to the shell | Run shell greps outside Innovus |

## Lessons
- Match tech LEF, macro LEF and liberty from one library release.
- Make the same don't-use list visible to synthesis and P&R, otherwise P&R can still choose a banned cell.
- Order matters: init -> floorplan -> power -> pins -> place -> CTS -> route -> timing.
- Save a checkpoint after every stage (`saveDesign`) so any stage can be inspected or restarted.
