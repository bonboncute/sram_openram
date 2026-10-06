# SRAM Macro Integration with APB-Lite Memory Controller

End-to-end RTL-to-signoff flow: a custom-generated 1KB SRAM macro integrated behind an APB-lite memory controller, synthesized to a standard-cell gate-level netlist, and verified through static timing analysis.

## Overview

This project demonstrates a complete digital design flow on open-source tools:

1. **SRAM macro generation** — OpenRAM compiler, 1KB (256 words × 32-bit, 1 RW port), freepdk45 45nm technology, TT corner @ 1.0V/25°C
2. **RTL design** — APB-lite memory controller (`mem_ctrl.v`) bridging an APB bus to the SRAM's native read/write interface
3. **Functional verification** — Icarus Verilog simulation of write-then-read-back sequence, waveform inspection in GTKWave
4. **Synthesis** — Yosys, mapped to the Nangate45 standard cell library
5. **Static Timing Analysis** — OpenSTA, checking both the main clock domain and the asynchronous reset (`rstn`) removal/recovery paths

## Tools Used

| Stage | Tool |
|---|---|
| SRAM generation | [OpenRAM](https://github.com/VLSIDA/OpenRAM) v1.2.49 |
| Process technology | freepdk45 (45nm) |
| RTL simulation | Icarus Verilog (`iverilog`/`vvp`) |
| Waveform viewer | GTKWave |
| Synthesis | Yosys 0.33 |
| Standard cell library | Nangate45 (typical corner) |
| Static timing analysis | OpenSTA |

## Architecture

```
        APB bus                    mem_ctrl.v                 SRAM macro
  ┌───────────────┐          ┌──────────────────┐        ┌─────────────────┐
  │ psel, penable │          │                   │ s_cs   │                 │
  │ pwrite, paddr │ ───────► │  APB-lite slave   │ s_we   │  sram_1kb_32b   │
  │ pwdata        │          │  → native SRAM    │ s_addr │  (256×32, RW)   │
  │               │ ◄─────── │    interface       │ s_din  │  OpenRAM-       │
  │ prdata, pready│          │                   │ s_dout │  generated      │
  └───────────────┘          └──────────────────┘ ◄────── └─────────────────┘
```

The controller registers each APB request, drives a one-cycle-delayed `pending` flag to generate `pready`, and passes the request straight through to the SRAM's active-high `cs`/`we` interface.

Two SRAM models are used at different stages:
- `sram_behav.v` — lightweight behavioral model, used for fast RTL/controller verification in simulation
- `sram_1kb_32b.v` / `.lib` — the real OpenRAM-generated macro (with characterized timing/power), used for synthesis and STA

## Results

### Functional simulation
Write 4 words (`0xA5A50000`–`0xA5A50003`) over APB, then read them back:
```
OK 0 = a5a50000
OK 1 = a5a50001
OK 2 = a5a50002
OK 3 = a5a50003
```
All 4 words match — functional correctness verified.

### Synthesis (Yosys + Nangate45)
The controller's combinational logic reduces to just **2 gates** (1× AND2_X1, 1× AND3_X1) after FSM/memory optimization passes — the design is almost entirely sequential (6 flip-flops), reflecting a simple, efficient bus-interface implementation.

### Static Timing Analysis (OpenSTA)
Constraint: 100 MHz clock (10 ns period), 1 ns I/O delay.

| Path | Type | Slack | Result |
|---|---|---|---|
| Internal reconvergent path | min | 0.13 ns | ✅ MET |
| `psel` → internal FF | max | 8.68 ns | ✅ MET |
| `rstn` → FF (removal) | async min | 0.82 ns | ✅ MET |
| `rstn` → FF (recovery) | async max | 9.05 ns | ✅ MET |

**TNS = 0.00 ns** — zero timing violations across all path groups (setup, hold, and asynchronous reset removal/recovery).

### SRAM macro characteristics (from OpenRAM datasheet)
| Parameter | Value |
|---|---|
| Configuration | 256 words × 32 bits (1 KB), 1 RW port |
| Technology | freepdk45, TT corner |
| Area | 43,985 µm² |
| Supply | 1.0 V |
| Max frequency (analytical) | 1049 MHz |
| Read/Write power | 2.12 mW |
| Leakage power | 0.010 mW |

## Repository Structure

See folder layout in this repo — `rtl/` (design), `tb/` (testbench), `synth/` (Yosys scripts + netlist), `sta/` (constraints + timing reports), `sram_macro/` (OpenRAM config + generated views), `sim/` (simulation flow), `docs/` (generated datasheet).

## How to Reproduce

```bash
# 1. Generate the SRAM macro (requires OpenRAM + freepdk45 PDK)
openram sram_macro/sram_1kb_32b.py

# 2. Simulate the controller + SRAM
cd sim && make sim && make view   # opens GTKWave

# 3. Synthesize with Yosys
yosys synth/synth.ys

# 4. Run static timing analysis
sta sta/run_sta.tcl
```

## Author

Nguyễn Phú Cường — Computer Engineering, applying for Physical Design / Hardware Engineering roles.
