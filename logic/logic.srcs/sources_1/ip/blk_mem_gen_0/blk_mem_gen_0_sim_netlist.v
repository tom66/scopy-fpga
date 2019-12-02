// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Mon Dec  2 20:27:47 2019
// Host        : TomsDesktop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_sim_netlist.v
// Design      : blk_mem_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z014sclg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_gen_0,blk_mem_gen_v8_4_2,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module blk_mem_gen_0
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [10:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [15:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [15:0]douta;

  wire [10:0]addra;
  wire clka;
  wire [15:0]dina;
  wire [15:0]douta;
  wire ena;
  wire [0:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [15:0]NLW_U0_doutb_UNCONNECTED;
  wire [10:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [10:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [15:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "11" *) 
  (* C_ADDRB_WIDTH = "11" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.6745 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "blk_mem_gen_0.mem" *) 
  (* C_INIT_FILE_NAME = "blk_mem_gen_0.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "0" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "2048" *) 
  (* C_READ_DEPTH_B = "2048" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "16" *) 
  (* C_READ_WIDTH_B = "16" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "2048" *) 
  (* C_WRITE_DEPTH_B = "2048" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "16" *) 
  (* C_WRITE_WIDTH_B = "16" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  blk_mem_gen_0_blk_mem_gen_v8_4_2 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[15:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[10:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[10:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[15:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(1'b0));
endmodule

(* ORIG_REF_NAME = "blk_mem_gen_generic_cstr" *) 
module blk_mem_gen_0_blk_mem_gen_generic_cstr
   (douta,
    clka,
    ena,
    addra,
    dina,
    wea);
  output [15:0]douta;
  input clka;
  input ena;
  input [10:0]addra;
  input [15:0]dina;
  input [0:0]wea;

  wire [10:0]addra;
  wire clka;
  wire [15:0]dina;
  wire [15:0]douta;
  wire ena;
  wire [0:0]wea;

  blk_mem_gen_0_blk_mem_gen_prim_width \ramloop[0].ram.r 
       (.addra(addra),
        .clka(clka),
        .dina(dina),
        .douta(douta),
        .ena(ena),
        .wea(wea));
endmodule

(* ORIG_REF_NAME = "blk_mem_gen_prim_width" *) 
module blk_mem_gen_0_blk_mem_gen_prim_width
   (douta,
    clka,
    ena,
    addra,
    dina,
    wea);
  output [15:0]douta;
  input clka;
  input ena;
  input [10:0]addra;
  input [15:0]dina;
  input [0:0]wea;

  wire [10:0]addra;
  wire clka;
  wire [15:0]dina;
  wire [15:0]douta;
  wire ena;
  wire [0:0]wea;

  blk_mem_gen_0_blk_mem_gen_prim_wrapper_init \prim_init.ram 
       (.addra(addra),
        .clka(clka),
        .dina(dina),
        .douta(douta),
        .ena(ena),
        .wea(wea));
endmodule

(* ORIG_REF_NAME = "blk_mem_gen_prim_wrapper_init" *) 
module blk_mem_gen_0_blk_mem_gen_prim_wrapper_init
   (douta,
    clka,
    ena,
    addra,
    dina,
    wea);
  output [15:0]douta;
  input clka;
  input ena;
  input [10:0]addra;
  input [15:0]dina;
  input [0:0]wea;

  wire \DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_n_70 ;
  wire \DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_n_71 ;
  wire [10:0]addra;
  wire clka;
  wire [15:0]dina;
  wire [15:0]douta;
  wire ena;
  wire [0:0]wea;
  wire \NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_CASCADEOUTA_UNCONNECTED ;
  wire \NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_CASCADEOUTB_UNCONNECTED ;
  wire \NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_DBITERR_UNCONNECTED ;
  wire \NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_SBITERR_UNCONNECTED ;
  wire [31:16]\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_DOADO_UNCONNECTED ;
  wire [31:0]\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_DOBDO_UNCONNECTED ;
  wire [3:2]\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_DOPADOP_UNCONNECTED ;
  wire [3:0]\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_DOPBDOP_UNCONNECTED ;
  wire [7:0]\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_ECCPARITY_UNCONNECTED ;
  wire [8:0]\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_RDADDRECC_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  RAMB36E1 #(
    .DOA_REG(1),
    .DOB_REG(0),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_00(256'h976D95E1945492C791398FAA8E1B8C8B8AFA896A87D8864784B5832381917FFF),
    .INIT_01(256'hAF86AE10AC98AB1EA9A3A826A6A7A527A3A5A223A09E9F199D929C0A9A8298F8),
    .INIT_02(256'hC5CCC47AC324C1CDC073BF16BDB7BC55BAF2B98CB823B6B9B54CB3DEB26DB0FB),
    .INIT_03(256'hD963D842D71DD5F4D4C9D39AD268D132CFFACEBFCD80CC3FCAFAC9B3C869C71C),
    .INIT_04(256'hE98BE8A5E7BCE6CEE5DDE4E7E3EEE2F1E1F0E0EBDFE2DED6DDC6DCB3DB9CDA81),
    .INIT_05(256'hF5A4F503F45EF3B4F306F254F19DF0E1F022EF5EEE95EDC9ECF8EC23EB4AEA6C),
    .INIT_06(256'hFD38FCE2FC88FC28FBC4FB5CFAEEFA7CFA04F989F908F883F7F9F76BF6D8F640),
    .INIT_07(256'hFFFCFFF5FFE8FFD7FFC1FFA6FF86FF61FF37FF08FED4FE9CFE5EFE1CFDD5FD89),
    .INIT_08(256'hFDD5FE1CFE5EFE9CFED4FF08FF37FF61FF86FFA6FFC1FFD7FFE8FFF5FFFCFFFF),
    .INIT_09(256'hF6D8F76BF7F9F883F908F989FA04FA7CFAEEFB5CFBC4FC28FC88FCE2FD38FD89),
    .INIT_0A(256'hEB4AEC23ECF8EDC9EE95EF5EF022F0E1F19DF254F306F3B4F45EF503F5A4F640),
    .INIT_0B(256'hDB9CDCB3DDC6DED6DFE2E0EBE1F0E2F1E3EEE4E7E5DDE6CEE7BCE8A5E98BEA6C),
    .INIT_0C(256'hC869C9B3CAFACC3FCD80CEBFCFFAD132D268D39AD4C9D5F4D71DD842D963DA81),
    .INIT_0D(256'hB26DB3DEB54CB6B9B823B98CBAF2BC55BDB7BF16C073C1CDC324C47AC5CCC71C),
    .INIT_0E(256'h9A829C0A9D929F19A09EA223A3A5A527A6A7A826A9A3AB1EAC98AE10AF86B0FB),
    .INIT_0F(256'h8191832384B5864787D8896A8AFA8C8B8E1B8FAA913992C7945495E1976D98F8),
    .INIT_10(256'h68916A1D6BAA6D376EC5705471E3737375047694782679B77B497CDB7E6D7FFF),
    .INIT_11(256'h507851EE536654E0565B57D859575AD75C595DDB5F6060E5626C63F4657C6706),
    .INIT_12(256'h3A323B843CDA3E313F8B40E8424743A9450C467247DB49454AB24C204D914F03),
    .INIT_13(256'h269B27BC28E12A0A2B352C642D962ECC3004313F327E33BF3504364B379538E2),
    .INIT_14(256'h16731759184219301A211B171C101D0D1E0E1F13201C21282238234B2462257D),
    .INIT_15(256'h0A5A0AFB0BA00C4A0CF80DAA0E610F1D0FDC10A011691235130613DB14B41592),
    .INIT_16(256'h02C6031C037603D6043A04A20510058205FA067506F6077B08050893092609BE),
    .INIT_17(256'h0002000900160027003D00580078009D00C700F6012A016201A001E202290275),
    .INIT_18(256'h022901E201A00162012A00F600C7009D00780058003D00270016000900020000),
    .INIT_19(256'h092608930805077B06F6067505FA0582051004A2043A03D60376031C02C60275),
    .INIT_1A(256'h14B413DB13061235116910A00FDC0F1D0E610DAA0CF80C4A0BA00AFB0A5A09BE),
    .INIT_1B(256'h2462234B22382128201C1F131E0E1D0D1C101B171A2119301842175916731592),
    .INIT_1C(256'h3795364B350433BF327E313F30042ECC2D962C642B352A0A28E127BC269B257D),
    .INIT_1D(256'h4D914C204AB2494547DB4672450C43A9424740E83F8B3E313CDA3B843A3238E2),
    .INIT_1E(256'h657C63F4626C60E55F605DDB5C595AD7595757D8565B54E0536651EE50784F03),
    .INIT_1F(256'h7E6D7CDB7B4979B7782676947504737371E370546EC56D376BAA6A1D68916706),
    .INIT_20(256'h976D95E1945492C791398FAA8E1B8C8B8AFA896A87D8864784B5832381917FFF),
    .INIT_21(256'hAF86AE10AC98AB1EA9A3A826A6A7A527A3A5A223A09E9F199D929C0A9A8298F8),
    .INIT_22(256'hC5CCC47AC324C1CDC073BF16BDB7BC55BAF2B98CB823B6B9B54CB3DEB26DB0FB),
    .INIT_23(256'hD963D842D71DD5F4D4C9D39AD268D132CFFACEBFCD80CC3FCAFAC9B3C869C71C),
    .INIT_24(256'hE98BE8A5E7BCE6CEE5DDE4E7E3EEE2F1E1F0E0EBDFE2DED6DDC6DCB3DB9CDA81),
    .INIT_25(256'hF5A4F503F45EF3B4F306F254F19DF0E1F022EF5EEE95EDC9ECF8EC23EB4AEA6C),
    .INIT_26(256'hFD38FCE2FC88FC28FBC4FB5CFAEEFA7CFA04F989F908F883F7F9F76BF6D8F640),
    .INIT_27(256'hFFFCFFF5FFE8FFD7FFC1FFA6FF86FF61FF37FF08FED4FE9CFE5EFE1CFDD5FD89),
    .INIT_28(256'hFDD5FE1CFE5EFE9CFED4FF08FF37FF61FF86FFA6FFC1FFD7FFE8FFF5FFFCFFFF),
    .INIT_29(256'hF6D8F76BF7F9F883F908F989FA04FA7CFAEEFB5CFBC4FC28FC88FCE2FD38FD89),
    .INIT_2A(256'hEB4AEC23ECF8EDC9EE95EF5EF022F0E1F19DF254F306F3B4F45EF503F5A4F640),
    .INIT_2B(256'hDB9CDCB3DDC6DED6DFE2E0EBE1F0E2F1E3EEE4E7E5DDE6CEE7BCE8A5E98BEA6C),
    .INIT_2C(256'hC869C9B3CAFACC3FCD80CEBFCFFAD132D268D39AD4C9D5F4D71DD842D963DA81),
    .INIT_2D(256'hB26DB3DEB54CB6B9B823B98CBAF2BC55BDB7BF16C073C1CDC324C47AC5CCC71C),
    .INIT_2E(256'h9A829C0A9D929F19A09EA223A3A5A527A6A7A826A9A3AB1EAC98AE10AF86B0FB),
    .INIT_2F(256'h8191832384B5864787D8896A8AFA8C8B8E1B8FAA913992C7945495E1976D98F8),
    .INIT_30(256'h68916A1D6BAA6D376EC5705471E3737375047694782679B77B497CDB7E6D7FFF),
    .INIT_31(256'h507851EE536654E0565B57D859575AD75C595DDB5F6060E5626C63F4657C6706),
    .INIT_32(256'h3A323B843CDA3E313F8B40E8424743A9450C467247DB49454AB24C204D914F03),
    .INIT_33(256'h269B27BC28E12A0A2B352C642D962ECC3004313F327E33BF3504364B379538E2),
    .INIT_34(256'h16731759184219301A211B171C101D0D1E0E1F13201C21282238234B2462257D),
    .INIT_35(256'h0A5A0AFB0BA00C4A0CF80DAA0E610F1D0FDC10A011691235130613DB14B41592),
    .INIT_36(256'h02C6031C037603D6043A04A20510058205FA067506F6077B08050893092609BE),
    .INIT_37(256'h0002000900160027003D00580078009D00C700F6012A016201A001E202290275),
    .INIT_38(256'h022901E201A00162012A00F600C7009D00780058003D00270016000900020000),
    .INIT_39(256'h092608930805077B06F6067505FA0582051004A2043A03D60376031C02C60275),
    .INIT_3A(256'h14B413DB13061235116910A00FDC0F1D0E610DAA0CF80C4A0BA00AFB0A5A09BE),
    .INIT_3B(256'h2462234B22382128201C1F131E0E1D0D1C101B171A2119301842175916731592),
    .INIT_3C(256'h3795364B350433BF327E313F30042ECC2D962C642B352A0A28E127BC269B257D),
    .INIT_3D(256'h4D914C204AB2494547DB4672450C43A9424740E83F8B3E313CDA3B843A3238E2),
    .INIT_3E(256'h657C63F4626C60E55F605DDB5C595AD7595757D8565B54E0536651EE50784F03),
    .INIT_3F(256'h7E6D7CDB7B4979B7782676947504737371E370546EC56D376BAA6A1D68916706),
    .INIT_40(256'h976D95E1945492C791398FAA8E1B8C8B8AFA896A87D8864784B5832381917FFF),
    .INIT_41(256'hAF86AE10AC98AB1EA9A3A826A6A7A527A3A5A223A09E9F199D929C0A9A8298F8),
    .INIT_42(256'hC5CCC47AC324C1CDC073BF16BDB7BC55BAF2B98CB823B6B9B54CB3DEB26DB0FB),
    .INIT_43(256'hD963D842D71DD5F4D4C9D39AD268D132CFFACEBFCD80CC3FCAFAC9B3C869C71C),
    .INIT_44(256'hE98BE8A5E7BCE6CEE5DDE4E7E3EEE2F1E1F0E0EBDFE2DED6DDC6DCB3DB9CDA81),
    .INIT_45(256'hF5A4F503F45EF3B4F306F254F19DF0E1F022EF5EEE95EDC9ECF8EC23EB4AEA6C),
    .INIT_46(256'hFD38FCE2FC88FC28FBC4FB5CFAEEFA7CFA04F989F908F883F7F9F76BF6D8F640),
    .INIT_47(256'hFFFCFFF5FFE8FFD7FFC1FFA6FF86FF61FF37FF08FED4FE9CFE5EFE1CFDD5FD89),
    .INIT_48(256'hFDD5FE1CFE5EFE9CFED4FF08FF37FF61FF86FFA6FFC1FFD7FFE8FFF5FFFCFFFF),
    .INIT_49(256'hF6D8F76BF7F9F883F908F989FA04FA7CFAEEFB5CFBC4FC28FC88FCE2FD38FD89),
    .INIT_4A(256'hEB4AEC23ECF8EDC9EE95EF5EF022F0E1F19DF254F306F3B4F45EF503F5A4F640),
    .INIT_4B(256'hDB9CDCB3DDC6DED6DFE2E0EBE1F0E2F1E3EEE4E7E5DDE6CEE7BCE8A5E98BEA6C),
    .INIT_4C(256'hC869C9B3CAFACC3FCD80CEBFCFFAD132D268D39AD4C9D5F4D71DD842D963DA81),
    .INIT_4D(256'hB26DB3DEB54CB6B9B823B98CBAF2BC55BDB7BF16C073C1CDC324C47AC5CCC71C),
    .INIT_4E(256'h9A829C0A9D929F19A09EA223A3A5A527A6A7A826A9A3AB1EAC98AE10AF86B0FB),
    .INIT_4F(256'h8191832384B5864787D8896A8AFA8C8B8E1B8FAA913992C7945495E1976D98F8),
    .INIT_50(256'h68916A1D6BAA6D376EC5705471E3737375047694782679B77B497CDB7E6D7FFF),
    .INIT_51(256'h507851EE536654E0565B57D859575AD75C595DDB5F6060E5626C63F4657C6706),
    .INIT_52(256'h3A323B843CDA3E313F8B40E8424743A9450C467247DB49454AB24C204D914F03),
    .INIT_53(256'h269B27BC28E12A0A2B352C642D962ECC3004313F327E33BF3504364B379538E2),
    .INIT_54(256'h16731759184219301A211B171C101D0D1E0E1F13201C21282238234B2462257D),
    .INIT_55(256'h0A5A0AFB0BA00C4A0CF80DAA0E610F1D0FDC10A011691235130613DB14B41592),
    .INIT_56(256'h02C6031C037603D6043A04A20510058205FA067506F6077B08050893092609BE),
    .INIT_57(256'h0002000900160027003D00580078009D00C700F6012A016201A001E202290275),
    .INIT_58(256'h022901E201A00162012A00F600C7009D00780058003D00270016000900020000),
    .INIT_59(256'h092608930805077B06F6067505FA0582051004A2043A03D60376031C02C60275),
    .INIT_5A(256'h14B413DB13061235116910A00FDC0F1D0E610DAA0CF80C4A0BA00AFB0A5A09BE),
    .INIT_5B(256'h2462234B22382128201C1F131E0E1D0D1C101B171A2119301842175916731592),
    .INIT_5C(256'h3795364B350433BF327E313F30042ECC2D962C642B352A0A28E127BC269B257D),
    .INIT_5D(256'h4D914C204AB2494547DB4672450C43A9424740E83F8B3E313CDA3B843A3238E2),
    .INIT_5E(256'h657C63F4626C60E55F605DDB5C595AD7595757D8565B54E0536651EE50784F03),
    .INIT_5F(256'h7E6D7CDB7B4979B7782676947504737371E370546EC56D376BAA6A1D68916706),
    .INIT_60(256'h976D95E1945492C791398FAA8E1B8C8B8AFA896A87D8864784B5832381917FFF),
    .INIT_61(256'hAF86AE10AC98AB1EA9A3A826A6A7A527A3A5A223A09E9F199D929C0A9A8298F8),
    .INIT_62(256'hC5CCC47AC324C1CDC073BF16BDB7BC55BAF2B98CB823B6B9B54CB3DEB26DB0FB),
    .INIT_63(256'hD963D842D71DD5F4D4C9D39AD268D132CFFACEBFCD80CC3FCAFAC9B3C869C71C),
    .INIT_64(256'hE98BE8A5E7BCE6CEE5DDE4E7E3EEE2F1E1F0E0EBDFE2DED6DDC6DCB3DB9CDA81),
    .INIT_65(256'hF5A4F503F45EF3B4F306F254F19DF0E1F022EF5EEE95EDC9ECF8EC23EB4AEA6C),
    .INIT_66(256'hFD38FCE2FC88FC28FBC4FB5CFAEEFA7CFA04F989F908F883F7F9F76BF6D8F640),
    .INIT_67(256'hFFFCFFF5FFE8FFD7FFC1FFA6FF86FF61FF37FF08FED4FE9CFE5EFE1CFDD5FD89),
    .INIT_68(256'hFDD5FE1CFE5EFE9CFED4FF08FF37FF61FF86FFA6FFC1FFD7FFE8FFF5FFFCFFFF),
    .INIT_69(256'hF6D8F76BF7F9F883F908F989FA04FA7CFAEEFB5CFBC4FC28FC88FCE2FD38FD89),
    .INIT_6A(256'hEB4AEC23ECF8EDC9EE95EF5EF022F0E1F19DF254F306F3B4F45EF503F5A4F640),
    .INIT_6B(256'hDB9CDCB3DDC6DED6DFE2E0EBE1F0E2F1E3EEE4E7E5DDE6CEE7BCE8A5E98BEA6C),
    .INIT_6C(256'hC869C9B3CAFACC3FCD80CEBFCFFAD132D268D39AD4C9D5F4D71DD842D963DA81),
    .INIT_6D(256'hB26DB3DEB54CB6B9B823B98CBAF2BC55BDB7BF16C073C1CDC324C47AC5CCC71C),
    .INIT_6E(256'h9A829C0A9D929F19A09EA223A3A5A527A6A7A826A9A3AB1EAC98AE10AF86B0FB),
    .INIT_6F(256'h8191832384B5864787D8896A8AFA8C8B8E1B8FAA913992C7945495E1976D98F8),
    .INIT_70(256'h68916A1D6BAA6D376EC5705471E3737375047694782679B77B497CDB7E6D7FFF),
    .INIT_71(256'h507851EE536654E0565B57D859575AD75C595DDB5F6060E5626C63F4657C6706),
    .INIT_72(256'h3A323B843CDA3E313F8B40E8424743A9450C467247DB49454AB24C204D914F03),
    .INIT_73(256'h269B27BC28E12A0A2B352C642D962ECC3004313F327E33BF3504364B379538E2),
    .INIT_74(256'h16731759184219301A211B171C101D0D1E0E1F13201C21282238234B2462257D),
    .INIT_75(256'h0A5A0AFB0BA00C4A0CF80DAA0E610F1D0FDC10A011691235130613DB14B41592),
    .INIT_76(256'h02C6031C037603D6043A04A20510058205FA067506F6077B08050893092609BE),
    .INIT_77(256'h0002000900160027003D00580078009D00C700F6012A016201A001E202290275),
    .INIT_78(256'h022901E201A00162012A00F600C7009D00780058003D00270016000900020000),
    .INIT_79(256'h092608930805077B06F6067505FA0582051004A2043A03D60376031C02C60275),
    .INIT_7A(256'h14B413DB13061235116910A00FDC0F1D0E610DAA0CF80C4A0BA00AFB0A5A09BE),
    .INIT_7B(256'h2462234B22382128201C1F131E0E1D0D1C101B171A2119301842175916731592),
    .INIT_7C(256'h3795364B350433BF327E313F30042ECC2D962C642B352A0A28E127BC269B257D),
    .INIT_7D(256'h4D914C204AB2494547DB4672450C43A9424740E83F8B3E313CDA3B843A3238E2),
    .INIT_7E(256'h657C63F4626C60E55F605DDB5C595AD7595757D8565B54E0536651EE50784F03),
    .INIT_7F(256'h7E6D7CDB7B4979B7782676947504737371E370546EC56D376BAA6A1D68916706),
    .INIT_A(36'h000000000),
    .INIT_B(36'h000000000),
    .INIT_FILE("NONE"),
    .IS_CLKARDCLK_INVERTED(1'b0),
    .IS_CLKBWRCLK_INVERTED(1'b0),
    .IS_ENARDEN_INVERTED(1'b0),
    .IS_ENBWREN_INVERTED(1'b0),
    .IS_RSTRAMARSTRAM_INVERTED(1'b0),
    .IS_RSTRAMB_INVERTED(1'b0),
    .IS_RSTREGARSTREG_INVERTED(1'b0),
    .IS_RSTREGB_INVERTED(1'b0),
    .RAM_EXTENSION_A("NONE"),
    .RAM_EXTENSION_B("NONE"),
    .RAM_MODE("TDP"),
    .RDADDR_COLLISION_HWCONFIG("PERFORMANCE"),
    .READ_WIDTH_A(18),
    .READ_WIDTH_B(18),
    .RSTREG_PRIORITY_A("REGCE"),
    .RSTREG_PRIORITY_B("REGCE"),
    .SIM_COLLISION_CHECK("ALL"),
    .SIM_DEVICE("7SERIES"),
    .SRVAL_A(36'h000000000),
    .SRVAL_B(36'h000000000),
    .WRITE_MODE_A("WRITE_FIRST"),
    .WRITE_MODE_B("WRITE_FIRST"),
    .WRITE_WIDTH_A(18),
    .WRITE_WIDTH_B(18)) 
    \DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram 
       (.ADDRARDADDR({1'b1,addra,1'b1,1'b1,1'b1,1'b1}),
        .ADDRBWRADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASCADEINA(1'b0),
        .CASCADEINB(1'b0),
        .CASCADEOUTA(\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_CASCADEOUTA_UNCONNECTED ),
        .CASCADEOUTB(\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_CASCADEOUTB_UNCONNECTED ),
        .CLKARDCLK(clka),
        .CLKBWRCLK(clka),
        .DBITERR(\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_DBITERR_UNCONNECTED ),
        .DIADI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,dina}),
        .DIBDI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .DIPADIP({1'b0,1'b0,1'b0,1'b0}),
        .DIPBDIP({1'b0,1'b0,1'b0,1'b0}),
        .DOADO({\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_DOADO_UNCONNECTED [31:16],douta}),
        .DOBDO(\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_DOBDO_UNCONNECTED [31:0]),
        .DOPADOP({\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_DOPADOP_UNCONNECTED [3:2],\DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_n_70 ,\DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_n_71 }),
        .DOPBDOP(\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_DOPBDOP_UNCONNECTED [3:0]),
        .ECCPARITY(\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_ECCPARITY_UNCONNECTED [7:0]),
        .ENARDEN(ena),
        .ENBWREN(1'b0),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDADDRECC(\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_RDADDRECC_UNCONNECTED [8:0]),
        .REGCEAREGCE(ena),
        .REGCEB(1'b0),
        .RSTRAMARSTRAM(1'b0),
        .RSTRAMB(1'b0),
        .RSTREGARSTREG(1'b0),
        .RSTREGB(1'b0),
        .SBITERR(\NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM36.ram_SBITERR_UNCONNECTED ),
        .WEA({wea,wea,wea,wea}),
        .WEBWE({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}));
endmodule

(* ORIG_REF_NAME = "blk_mem_gen_top" *) 
module blk_mem_gen_0_blk_mem_gen_top
   (douta,
    clka,
    ena,
    addra,
    dina,
    wea);
  output [15:0]douta;
  input clka;
  input ena;
  input [10:0]addra;
  input [15:0]dina;
  input [0:0]wea;

  wire [10:0]addra;
  wire clka;
  wire [15:0]dina;
  wire [15:0]douta;
  wire ena;
  wire [0:0]wea;

  blk_mem_gen_0_blk_mem_gen_generic_cstr \valid.cstr 
       (.addra(addra),
        .clka(clka),
        .dina(dina),
        .douta(douta),
        .ena(ena),
        .wea(wea));
endmodule

(* C_ADDRA_WIDTH = "11" *) (* C_ADDRB_WIDTH = "11" *) (* C_ALGORITHM = "1" *) 
(* C_AXI_ID_WIDTH = "4" *) (* C_AXI_SLAVE_TYPE = "0" *) (* C_AXI_TYPE = "1" *) 
(* C_BYTE_SIZE = "9" *) (* C_COMMON_CLK = "0" *) (* C_COUNT_18K_BRAM = "0" *) 
(* C_COUNT_36K_BRAM = "1" *) (* C_CTRL_ECC_ALGO = "NONE" *) (* C_DEFAULT_DATA = "0" *) 
(* C_DISABLE_WARN_BHV_COLL = "0" *) (* C_DISABLE_WARN_BHV_RANGE = "0" *) (* C_ELABORATION_DIR = "./" *) 
(* C_ENABLE_32BIT_ADDRESS = "0" *) (* C_EN_DEEPSLEEP_PIN = "0" *) (* C_EN_ECC_PIPE = "0" *) 
(* C_EN_RDADDRA_CHG = "0" *) (* C_EN_RDADDRB_CHG = "0" *) (* C_EN_SAFETY_CKT = "0" *) 
(* C_EN_SHUTDOWN_PIN = "0" *) (* C_EN_SLEEP_PIN = "0" *) (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.6745 mW" *) 
(* C_FAMILY = "zynq" *) (* C_HAS_AXI_ID = "0" *) (* C_HAS_ENA = "1" *) 
(* C_HAS_ENB = "0" *) (* C_HAS_INJECTERR = "0" *) (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
(* C_HAS_MEM_OUTPUT_REGS_B = "0" *) (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
(* C_HAS_REGCEA = "0" *) (* C_HAS_REGCEB = "0" *) (* C_HAS_RSTA = "0" *) 
(* C_HAS_RSTB = "0" *) (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
(* C_INITA_VAL = "0" *) (* C_INITB_VAL = "0" *) (* C_INIT_FILE = "blk_mem_gen_0.mem" *) 
(* C_INIT_FILE_NAME = "blk_mem_gen_0.mif" *) (* C_INTERFACE_TYPE = "0" *) (* C_LOAD_INIT_FILE = "1" *) 
(* C_MEM_TYPE = "0" *) (* C_MUX_PIPELINE_STAGES = "0" *) (* C_PRIM_TYPE = "1" *) 
(* C_READ_DEPTH_A = "2048" *) (* C_READ_DEPTH_B = "2048" *) (* C_READ_LATENCY_A = "1" *) 
(* C_READ_LATENCY_B = "1" *) (* C_READ_WIDTH_A = "16" *) (* C_READ_WIDTH_B = "16" *) 
(* C_RSTRAM_A = "0" *) (* C_RSTRAM_B = "0" *) (* C_RST_PRIORITY_A = "CE" *) 
(* C_RST_PRIORITY_B = "CE" *) (* C_SIM_COLLISION_CHECK = "ALL" *) (* C_USE_BRAM_BLOCK = "0" *) 
(* C_USE_BYTE_WEA = "0" *) (* C_USE_BYTE_WEB = "0" *) (* C_USE_DEFAULT_DATA = "0" *) 
(* C_USE_ECC = "0" *) (* C_USE_SOFTECC = "0" *) (* C_USE_URAM = "0" *) 
(* C_WEA_WIDTH = "1" *) (* C_WEB_WIDTH = "1" *) (* C_WRITE_DEPTH_A = "2048" *) 
(* C_WRITE_DEPTH_B = "2048" *) (* C_WRITE_MODE_A = "WRITE_FIRST" *) (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
(* C_WRITE_WIDTH_A = "16" *) (* C_WRITE_WIDTH_B = "16" *) (* C_XDEVICEFAMILY = "zynq" *) 
(* ORIG_REF_NAME = "blk_mem_gen_v8_4_2" *) (* downgradeipidentifiedwarnings = "yes" *) 
module blk_mem_gen_0_blk_mem_gen_v8_4_2
   (clka,
    rsta,
    ena,
    regcea,
    wea,
    addra,
    dina,
    douta,
    clkb,
    rstb,
    enb,
    regceb,
    web,
    addrb,
    dinb,
    doutb,
    injectsbiterr,
    injectdbiterr,
    eccpipece,
    sbiterr,
    dbiterr,
    rdaddrecc,
    sleep,
    deepsleep,
    shutdown,
    rsta_busy,
    rstb_busy,
    s_aclk,
    s_aresetn,
    s_axi_awid,
    s_axi_awaddr,
    s_axi_awlen,
    s_axi_awsize,
    s_axi_awburst,
    s_axi_awvalid,
    s_axi_awready,
    s_axi_wdata,
    s_axi_wstrb,
    s_axi_wlast,
    s_axi_wvalid,
    s_axi_wready,
    s_axi_bid,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_bready,
    s_axi_arid,
    s_axi_araddr,
    s_axi_arlen,
    s_axi_arsize,
    s_axi_arburst,
    s_axi_arvalid,
    s_axi_arready,
    s_axi_rid,
    s_axi_rdata,
    s_axi_rresp,
    s_axi_rlast,
    s_axi_rvalid,
    s_axi_rready,
    s_axi_injectsbiterr,
    s_axi_injectdbiterr,
    s_axi_sbiterr,
    s_axi_dbiterr,
    s_axi_rdaddrecc);
  input clka;
  input rsta;
  input ena;
  input regcea;
  input [0:0]wea;
  input [10:0]addra;
  input [15:0]dina;
  output [15:0]douta;
  input clkb;
  input rstb;
  input enb;
  input regceb;
  input [0:0]web;
  input [10:0]addrb;
  input [15:0]dinb;
  output [15:0]doutb;
  input injectsbiterr;
  input injectdbiterr;
  input eccpipece;
  output sbiterr;
  output dbiterr;
  output [10:0]rdaddrecc;
  input sleep;
  input deepsleep;
  input shutdown;
  output rsta_busy;
  output rstb_busy;
  input s_aclk;
  input s_aresetn;
  input [3:0]s_axi_awid;
  input [31:0]s_axi_awaddr;
  input [7:0]s_axi_awlen;
  input [2:0]s_axi_awsize;
  input [1:0]s_axi_awburst;
  input s_axi_awvalid;
  output s_axi_awready;
  input [15:0]s_axi_wdata;
  input [0:0]s_axi_wstrb;
  input s_axi_wlast;
  input s_axi_wvalid;
  output s_axi_wready;
  output [3:0]s_axi_bid;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  input s_axi_bready;
  input [3:0]s_axi_arid;
  input [31:0]s_axi_araddr;
  input [7:0]s_axi_arlen;
  input [2:0]s_axi_arsize;
  input [1:0]s_axi_arburst;
  input s_axi_arvalid;
  output s_axi_arready;
  output [3:0]s_axi_rid;
  output [15:0]s_axi_rdata;
  output [1:0]s_axi_rresp;
  output s_axi_rlast;
  output s_axi_rvalid;
  input s_axi_rready;
  input s_axi_injectsbiterr;
  input s_axi_injectdbiterr;
  output s_axi_sbiterr;
  output s_axi_dbiterr;
  output [10:0]s_axi_rdaddrecc;

  wire \<const0> ;
  wire [10:0]addra;
  wire clka;
  wire [15:0]dina;
  wire [15:0]douta;
  wire ena;
  wire [0:0]wea;

  assign dbiterr = \<const0> ;
  assign doutb[15] = \<const0> ;
  assign doutb[14] = \<const0> ;
  assign doutb[13] = \<const0> ;
  assign doutb[12] = \<const0> ;
  assign doutb[11] = \<const0> ;
  assign doutb[10] = \<const0> ;
  assign doutb[9] = \<const0> ;
  assign doutb[8] = \<const0> ;
  assign doutb[7] = \<const0> ;
  assign doutb[6] = \<const0> ;
  assign doutb[5] = \<const0> ;
  assign doutb[4] = \<const0> ;
  assign doutb[3] = \<const0> ;
  assign doutb[2] = \<const0> ;
  assign doutb[1] = \<const0> ;
  assign doutb[0] = \<const0> ;
  assign rdaddrecc[10] = \<const0> ;
  assign rdaddrecc[9] = \<const0> ;
  assign rdaddrecc[8] = \<const0> ;
  assign rdaddrecc[7] = \<const0> ;
  assign rdaddrecc[6] = \<const0> ;
  assign rdaddrecc[5] = \<const0> ;
  assign rdaddrecc[4] = \<const0> ;
  assign rdaddrecc[3] = \<const0> ;
  assign rdaddrecc[2] = \<const0> ;
  assign rdaddrecc[1] = \<const0> ;
  assign rdaddrecc[0] = \<const0> ;
  assign rsta_busy = \<const0> ;
  assign rstb_busy = \<const0> ;
  assign s_axi_arready = \<const0> ;
  assign s_axi_awready = \<const0> ;
  assign s_axi_bid[3] = \<const0> ;
  assign s_axi_bid[2] = \<const0> ;
  assign s_axi_bid[1] = \<const0> ;
  assign s_axi_bid[0] = \<const0> ;
  assign s_axi_bresp[1] = \<const0> ;
  assign s_axi_bresp[0] = \<const0> ;
  assign s_axi_bvalid = \<const0> ;
  assign s_axi_dbiterr = \<const0> ;
  assign s_axi_rdaddrecc[10] = \<const0> ;
  assign s_axi_rdaddrecc[9] = \<const0> ;
  assign s_axi_rdaddrecc[8] = \<const0> ;
  assign s_axi_rdaddrecc[7] = \<const0> ;
  assign s_axi_rdaddrecc[6] = \<const0> ;
  assign s_axi_rdaddrecc[5] = \<const0> ;
  assign s_axi_rdaddrecc[4] = \<const0> ;
  assign s_axi_rdaddrecc[3] = \<const0> ;
  assign s_axi_rdaddrecc[2] = \<const0> ;
  assign s_axi_rdaddrecc[1] = \<const0> ;
  assign s_axi_rdaddrecc[0] = \<const0> ;
  assign s_axi_rdata[15] = \<const0> ;
  assign s_axi_rdata[14] = \<const0> ;
  assign s_axi_rdata[13] = \<const0> ;
  assign s_axi_rdata[12] = \<const0> ;
  assign s_axi_rdata[11] = \<const0> ;
  assign s_axi_rdata[10] = \<const0> ;
  assign s_axi_rdata[9] = \<const0> ;
  assign s_axi_rdata[8] = \<const0> ;
  assign s_axi_rdata[7] = \<const0> ;
  assign s_axi_rdata[6] = \<const0> ;
  assign s_axi_rdata[5] = \<const0> ;
  assign s_axi_rdata[4] = \<const0> ;
  assign s_axi_rdata[3] = \<const0> ;
  assign s_axi_rdata[2] = \<const0> ;
  assign s_axi_rdata[1] = \<const0> ;
  assign s_axi_rdata[0] = \<const0> ;
  assign s_axi_rid[3] = \<const0> ;
  assign s_axi_rid[2] = \<const0> ;
  assign s_axi_rid[1] = \<const0> ;
  assign s_axi_rid[0] = \<const0> ;
  assign s_axi_rlast = \<const0> ;
  assign s_axi_rresp[1] = \<const0> ;
  assign s_axi_rresp[0] = \<const0> ;
  assign s_axi_rvalid = \<const0> ;
  assign s_axi_sbiterr = \<const0> ;
  assign s_axi_wready = \<const0> ;
  assign sbiterr = \<const0> ;
  GND GND
       (.G(\<const0> ));
  blk_mem_gen_0_blk_mem_gen_v8_4_2_synth inst_blk_mem_gen
       (.addra(addra),
        .clka(clka),
        .dina(dina),
        .douta(douta),
        .ena(ena),
        .wea(wea));
endmodule

(* ORIG_REF_NAME = "blk_mem_gen_v8_4_2_synth" *) 
module blk_mem_gen_0_blk_mem_gen_v8_4_2_synth
   (douta,
    clka,
    ena,
    addra,
    dina,
    wea);
  output [15:0]douta;
  input clka;
  input ena;
  input [10:0]addra;
  input [15:0]dina;
  input [0:0]wea;

  wire [10:0]addra;
  wire clka;
  wire [15:0]dina;
  wire [15:0]douta;
  wire ena;
  wire [0:0]wea;

  blk_mem_gen_0_blk_mem_gen_top \gnbram.gnativebmg.native_blk_mem_gen 
       (.addra(addra),
        .clka(clka),
        .dina(dina),
        .douta(douta),
        .ena(ena),
        .wea(wea));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
