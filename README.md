# BIP I - VHDL (VHSIC Hardware Description Language)

## AUTHOR

André Solano F. R. Maiolini (19.02012-0)

## CONTENTS

- This repository contains VHDL code and testbenches using GHDL, GTKWave, and Makefile to the describe a Basic Instruction-set Processor (BIP).
- The CPU can execute basic instructions stored in ROM, using an accumulator (ACC) and an Arithmetic Logic Unit (ALU) for arithmetic and logical operations.
- This CPU adopts the Harvard architecture.

## REPOSITORY STRUCTURE

```
├── src/
│   ├── components/
│   |   ├── arithmetic_logic_unit/
|   |   ├── control/
|   |   ├── counter/
|   |   ├── memory/
|   |   ├── register/
|   |   └── timer/
|   └── cpu.vhd
|
├── test/
|   ├── testbench/
|   └── waveform/
|
├── makefile
└── README.md
```

## Dependencies

To run the tests and view the results, you'll need the following tools installed on your system:
- [GHDL](https://github.com/ghdl/ghdl)
- [GTKWave](https://gtkwave.sourceforge.net/)
- [Make](https://www.gnu.org/software/make/)

---

## Usage

### Inputs

- `enable_clk` : Enables clock pulses -> starts execution.
- `MR`         : Master-Reset (active LOW).

### Makefile

The included Makefile automates the process of compilation, simulation, and result visualization.


1. Navigate to the project directory;
2. Run the testbench and visualize the waveform:
```
make test
````
3. View the last generated waveform: 
```
make view;
```
4. Clean up the generated files: 
```
make clean
```

---

