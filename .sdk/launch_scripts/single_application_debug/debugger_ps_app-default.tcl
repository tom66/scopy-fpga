connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/main/export/main/hw/main.xsa -mem-ranges [list {0x40000000 0xbfffffff}]
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/ps_app/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/ps_app/Release/ps_app.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con
