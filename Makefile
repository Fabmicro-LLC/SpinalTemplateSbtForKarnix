NAME = projectname
SPINALHDL = ./hw/spinal/projectname/MyTopLevel.scala
VERILOG = ./hw/gen/MyTopLevel.v
LPF = karnix_cabga256.lpf
DEVICE = 25k
PACKAGE = CABGA256
FTDI_CHANNEL = 0 ### FT2232 has two channels, select 0 for channel A or 1 for channel B
#
FLASH_METHOD := $(shell cat flash_method 2> /dev/null)
UPLOAD_METHOD := $(shell cat upload_method 2> /dev/null)

all: $(NAME).bin

$(VERILOG): $(SPINALHDL)
	sbt "runMain projectname.MyTopLevelVerilog"

$(NAME).bin: $(LPF) $(VERILOG)
	yosys -v2 -p "synth_ecp5 -abc2 -top MyTopLevel -json $(NAME).json" $(VERILOG)
	nextpnr-ecp5 --package $(PACKAGE) --$(DEVICE) --json $(NAME).json --textcfg $(NAME)_out.config --lpf $(LPF) --lpf-allow-unconstrained
	ecppack --compress --freq 38.8 --input $(NAME)_out.config --bit $(NAME).bit


upload:
ifeq ("$(FLASH_METHOD)", "flash")
	openFPGALoader -v --ftdi-channel $(FTDI_CHANNEL) -f --reset $(NAME).bin
else
	openFPGALoader -v --ftdi-channel $(FTDI_CHANNEL) $(NAME).bin
endif

clean:
	@rm *.json *.config *.bit $(VERILOG)

