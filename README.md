# BIP I - VHDL

This repository contains VHDL code and testbenches using GHDL, GTKWave, and Makefile to the describe a Basic Instruction-set Processor.

## Repository Structure

```
├── src/
│   ├── components/
│   |   ├── arithmetic_logic_unit/
|   |   ├── bus_control/
|   |   ├── counter/
|   |   ├── memory/
|   |   ├── register/
|   |   └── timer/
|   └── cpu.vhd
├── test/
|   ├── testbench/
|   └── waveform/
├── makefile
└── README.md
```

## Dependencies

To run the tests and view the results, you'll need the following tools installed on your system:
- [GHDL](https://github.com/ghdl/ghdl)
- [GTKWave](https://gtkwave.sourceforge.net/)
- [Make](https://www.gnu.org/software/make/)

## Usage

### Makefile

The included Makefile automates the process of compilation, simulation, and result visualization.

---

