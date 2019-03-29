##############################################################################
## Filename:          D:\169\lab3/drivers/vga_peripheral_007_v1_00_a/data/vga_peripheral_007_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Fri Mar 29 09:24:22 2019 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "vga_peripheral_007" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
