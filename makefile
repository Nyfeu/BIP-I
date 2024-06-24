# Define the default VHDL files directory and the testbench entity name
VHDL_DIR ?= src/components
VHDL_FILES := $(wildcard $(VHDL_DIR)/**/*.vhd)
VHDL_CPU := src/cpu.vhd
TESTBENCH = cpu_tb
OUTPUT_DIR = test/waveform
TESTBENCH_FILE = test/testbench/$(TESTBENCH).vhd
WAVEFORM = $(OUTPUT_DIR)/$(TESTBENCH).vcd

# Define the commands to be used
GHDL = ghdl
GTKWAVE = gtkwave
RM = del

# Run a testbench
$(WAVEFORM): $(VHDL_FILES) $(VHDL_CPU)
	$(GHDL) -a --std=08 $(VHDL_CPU)
	$(GHDL) -a --std=08 $(VHDL_FILES)
	$(GHDL) -a --std=08 $(TESTBENCH_FILE)
	$(GHDL) -e --std=08 $(TESTBENCH)
	$(GHDL) -r --std=08 $(TESTBENCH) --vcd=$(WAVEFORM)
	$(RM) work-obj08.cf

# Open the waveform in GTKWave
test: $(WAVEFORM)
	$(GTKWAVE) $(WAVEFORM)

# Visualize the waveform
view:
	$(GTKWAVE) $(WAVEFORM)

# Clean up generated files in output directory
clean:
	$(RM) $(OUTPUT_DIR)/$(TESTBENCH).vcd