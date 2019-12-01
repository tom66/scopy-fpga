connect -url tcp:127.0.0.1:3121
source C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/mvp_hw_platform/ps7_init.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Platform Cable USB 00001004b9fe01"} -index 0
rst -system
after 3000
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Platform Cable USB 00001004b9fe01"} -index 0
loadhw -hw C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/mvp_hw_platform/system.hdf -mem-ranges [list {0x40000000 0xbfffffff}]
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Platform Cable USB 00001004b9fe01"} -index 0
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Platform Cable USB 00001004b9fe01"} -index 0
dow C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/ps_app/Debug/ps_app.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Platform Cable USB 00001004b9fe01"} -index 0
con
