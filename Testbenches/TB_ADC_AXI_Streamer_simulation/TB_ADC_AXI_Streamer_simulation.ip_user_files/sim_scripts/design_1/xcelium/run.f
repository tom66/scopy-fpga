-makelib xcelium_lib/xil_defaultlib -sv \
  "G:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "G:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "G:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_3 \
  "../../../../TB_ADC_AXI_Streamer_simulation.srcs/sources_1/bd/design_1/ip/design_1_adc_streamer_0_0/src/fifo_generator_0_1/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_3 \
  "../../../../TB_ADC_AXI_Streamer_simulation.srcs/sources_1/bd/design_1/ip/design_1_adc_streamer_0_0/src/fifo_generator_0_1/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_3 \
  "../../../../TB_ADC_AXI_Streamer_simulation.srcs/sources_1/bd/design_1/ip/design_1_adc_streamer_0_0/src/fifo_generator_0_1/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/design_1/ip/design_1_adc_streamer_0_0/src/fifo_generator_0_1/sim/fifo_generator_0.v" \
  "../../../bd/design_1/ipshared/ca0b/hdl/adc_test_streamer_v2_0_M00_AXIS.v" \
  "../../../bd/design_1/ipshared/ca0b/hdl/adc_test_streamer_v2_0.v" \
  "../../../bd/design_1/ip/design_1_adc_streamer_0_0/sim/design_1_adc_streamer_0_0.v" \
  "../../../bd/design_1/sim/design_1.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

