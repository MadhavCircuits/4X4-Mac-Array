# Results summary

## Synthesis (Genus 21.1, slow corner, 5.0 ns)
| Metric | Value |
|---|---|
| Cells | 4864 |
| Cell area | 13,488.48 um^2 |
| Total area (with wiring estimate) | 20,205 um^2 |
| Setup slack | +443 ps |
| Banned (CoreSiteDouble) cells in netlist | 0 |

## Place and route (Innovus 21.15)
| Metric | Value |
|---|---|
| Die box | 0 0 155.0 153.52 um |
| Core box | 10.0 10.07 145.0 143.45 um |
| Core utilization target | 75% |
| Standard cells after CTS | 4940 |
| Clock sinks / leaf buffers | 512 / 6 |
| Total wire length | 160,654 um |
| DRC violations | 0 |
| Antenna violations | 0 |
| Congestion hotspot | 0.00 / 0.00 |
| Design status | Routed |

## To fill in
- Post-route WNS / TNS (from `timeDesign -postRoute` summary).
- Final filler count and `verify_drc` result.
- Floorplan-only and power-plan-only screenshots. Everything else is in [gallery.md](gallery.md).
