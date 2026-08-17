[**English**](./README_EN.md) | [**简体中文**](./README.md)

# RV32I Pipeline CPU and Differential-Testing Platform

This repository contains two related RV32I processor implementations developed for FPGA integration and post-competition verification:

- `CPU/`: the three-stage SystemVerilog processor used in the competition design. Its pipeline is organized as `IFU & IDU -> EXU -> LSU & WBU` and is intended for integration into the JYD Vivado SoC template.
- `cdp-tests/`: a later five-stage processor, SoC wrapper, and Verilator-based differential-testing environment for instruction regression and waveform generation.

The project received the **South China Regional Second Prize** in the 2025 National College Students' Integrated Circuit Innovation and Entrepreneurship Competition.

> This repository is intended as a technical reference. The competition platform performs originality checks; please do not submit this implementation as your own work.

## Highlights

- An independently implemented RV32I datapath in SystemVerilog.
- A three-stage FPGA-oriented version that has been deployed through a Vivado SoC template.
- A five-stage version with a stable SoC wrapper and debug write-back interface.
- Instruction-level differential testing against a C reference model.
- Single-test and batch-regression workflows with VCD waveform generation.
- Timing closure at **100 MHz** for the competition-oriented implementation.

## Repository Layout

```text
.
|-- CPU/                         # Three-stage FPGA-oriented processor
|   |-- myCPU.sv                 # CPU top module
|   `-- ...                      # Pipeline and control modules
|-- cdp-tests/                   # Linux/Verilator verification environment
|   |-- mySoC/                   # Five-stage CPU and SoC top-level wrapper
|   |   |-- miniRV_SoC.v         # Simulation top module
|   |   `-- myCPU.sv             # Five-stage CPU top module
|   |-- vsrc/                    # Simulation RAM and instruction-memory models
|   |-- csrc/                    # Verilator C++ testbench and difftest logic
|   |-- golden_model/            # C reference model
|   |-- bin/                     # RV32I test binaries
|   `-- run_all_tests.py         # Batch regression runner
`-- Picture/                     # Integration and regression screenshots
```

## 1. FPGA Integration of the Three-Stage CPU

The `CPU/` implementation is designed to be added to the competition-provided JYD SoC template in Vivado.

### Top-Level Interface

The top module is `CPU/myCPU.sv`. Its main interfaces are:

- Clock and reset: `cpu_clk`, `cpu_rst`
- Instruction memory: `irom_addr`, `irom_data`
- Data/peripheral access: `perip_addr`, `perip_wen`, `perip_mask`, `perip_wdata`, `perip_rdata`

### Integration Procedure

1. Open the JYD SoC template using the Vivado version specified by the competition.
2. Add every `.sv` file under `CPU/` as a design source.
3. Ensure Vivado treats the files as SystemVerilog and can resolve `` `include "para.sv" ``.
4. Instantiate `myCPU` in the template CPU wrapper and connect the instruction-memory and peripheral interfaces.
5. Configure the template IP blocks and set the CPU clock output to **100 MHz**.
6. Run synthesis and implementation, generate the bitstream, and program the board.

The resulting Vivado source hierarchy is shown below:

![Vivado hierarchy after integrating the CPU](Picture/JYD_SoC.png)

The current version has been corrected for stable board execution at 100 MHz. A 150 MHz configuration was also exercised during the competition, but it had timing violations and is not the recommended setting.

![Result on the JYD evaluation platform](Picture/JYD_result.png)

## 2. Verilator and Differential Testing

The `cdp-tests/` environment verifies the later five-stage implementation on Linux. It compiles the RTL with Verilator, compares architectural write-back events against a C golden model, and emits a waveform for each test.

### Dependencies

```bash
sudo apt-get update
sudo apt-get install -y verilator make g++ python3
```

### Build

```bash
git clone https://github.com/hongpengWu/RV32I-Pipline-CPU-trace-JYD.git
cd RV32I-Pipline-CPU-trace-JYD/cdp-tests
make clean
make
```

The Verilator top module is `miniRV_SoC`. Build artifacts are placed in `cdp-tests/obj_dir/`.

### Run One Test

```bash
make run TEST=addi
```

The Makefile links `bin/addi.bin` as `meminit.bin`, runs the simulator, and writes the waveform to `waveform/addi.vcd`.

To inspect the waveform:

```bash
gtkwave waveform/addi.vcd
```

### Run the Full Regression Suite

```bash
python3 run_all_tests.py
```

The script executes every binary under `bin/` and reports the passed and failed cases.

![Batch regression output](Picture/trace_result.png)

## Pass/Fail Semantics

- A mismatch between the RTL write-back trace and the reference model terminates the test as a failure.
- Reaching `ecall` terminates the program; by default, `a0` (`x10`) must be zero for the test to pass.
- A test that does not terminate before the simulation limit is reported as timed out.

This setup makes the two implementations complementary: use `CPU/` for FPGA integration and use `cdp-tests/` for repeatable instruction-level verification and debugging.

## Troubleshooting

- `verilator: command not found`: install Verilator or add it to `PATH`.
- Symbolic-link errors: run the flow on Linux, or copy the selected test binary to `meminit.bin` manually.
- `Timed out`: inspect control flow, memory access, exception return, and the generated VCD trace.
