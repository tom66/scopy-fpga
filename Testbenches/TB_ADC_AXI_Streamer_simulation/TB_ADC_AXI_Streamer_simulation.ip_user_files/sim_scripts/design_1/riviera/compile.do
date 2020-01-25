vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm
vlib riviera/fifo_generator_v13_2_3

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm
vmap fifo_generator_v13_2_3 riviera/fifo_generator_v13_2_3

vlog -work xil_defaultlib  -sv2k12 \
"G:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"G:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"G:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work fifo_generator_v13_2_3  -v2k5 \
"../../../../TB_ADC_AXI_Streamer_simulation.srcs/sources_1/bd/design_1/ip/design_1_adc_streamer_0_0/src/fifo_generator_0_1/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_3 -93 \
"../../../../TB_ADC_AXI_Streamer_simulation.srcs/sources_1/bd/design_1/ip/design_1_adc_streamer_0_0/src/fifo_generator_0_1/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_3  -v2k5 \
"../../../../TB_ADC_AXI_Streamer_simulation.srcs/sources_1/bd/design_1/ip/design_1_adc_streamer_0_0/src/fifo_generator_0_1/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../bd/design_1/ip/design_1_adc_streamer_0_0/src/fifo_generator_0_1/sim/fifo_generator_0.v" \
"../../../bd/design_1/ipshared/ca0b/hdl/adc_test_streamer_v2_0_M00_AXIS.v" \
"../../../bd/design_1/ipshared/ca0b/hdl/adc_test_streamer_v2_0.v" \
"../../../bd/design_1/ip/design_1_adc_streamer_0_0/sim/design_1_adc_streamer_0_0.v" \
"../../../bd/design_1/sim/design_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

