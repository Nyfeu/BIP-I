# BIP I - VHDL (VHSIC Hardware Description Language)

```    

██████╗ ██╗██████╗        ██╗
██╔══██╗██║██╔══██╗      ███║      ->> Author: André Solano F. R. Maiolini
██████╔╝██║██████╔╝█████╗╚██║      ->> Date: 25/06/2024
██╔══██╗██║██╔═══╝ ╚════╝ ██║
██████╔╝██║██║            ██║
╚═════╝ ╚═╝╚═╝            ╚═╝

```

## CONTENTS

- This repository contains VHDL code and testbenches using GHDL, GTKWave, and Makefile to the describe a Basic Instruction-set Processor (BIP).
- The CPU can execute basic instructions stored in ROM, using an accumulator (ACC) and an Arithmetic Logic Unit (ALU) for arithmetic and logical operations.
- This CPU adopts the Harvard architecture.

## INSTRUCTION-SET

| OP CODE | BINARY | INSTRUCTION | DESCRIPTION | 
|:-------:|:------:|:-----------:|-------------|
| 0 | 0000 | **HLT** | Halt |
| 1 | 0001 | **STO** | (addr) ← ACC |
| 2 | 0010 | **LD** | ACC ← (addr) |
| 3 | 0011 | **LDI** | ACC ← const. |
| 4 | 0100 | **ADD** | ACC ← ACC + (addr) |
| 5 | 0101 | **ADDI** | ACC ← ACC + const. |
| 6 | 0110 | **SUB** | ACC ← ACC - (addr) |
| 7 | 0111 | **SUBI** | ACC ← ACC - const. |
| 8 | 1000 | **JUMP** | PC ← const. |
| 9 | 1001 | **NOP** | No operation | 
| A | 1010 | **CMP** | Compare ACC with (addr) |
| B | 1011 | **JNE** | PC ← const., if CMP ≠ ACC |
| C | 1100 | **JL** | PC ← const., if CMP < ACC |
| D | 1101 | **JG** | PC ← const., if CMP > ACC | 
| E | 1110 | **IN** | ACC ← INPUT(addr) | 
| F | 1111 | **OUT** | OUTPUT(addr) ← ACC |

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



## Usage

### Inputs and Outputs

```

- enable_clk : Enables clock pulses;
- MR         : Master-Reset (active LOW);                 ____________________________
- in_port_1  : Input port 1 (16 bits);                   /                           /\
- in_port_2  : Input port 2 (16 bits);                  /         BIP I            _/ /\
- in_port_3  : Input port 3 (16 bits);                 /        (Harvard)         / \/
- in_port_4  : Input port 4 (16 bits);                /                           /\
- out_port_1 : Output port 1 (16 bits);              /___________________________/ /
- out_port_2 : Output port 2 (16 bits);              \___________________________\/
- out_port_3 : Output port 3 (16 bits);               \ \ \ \ \ \ \ \ \ \ \ \ \ \ \
- out_port_4 : Output port 4 (16 bits).

```

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

