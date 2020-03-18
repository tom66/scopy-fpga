
`timescale 1ns / 1ns

//////////////////////////////////////////////////////////////////////////////////
// 
// This file is part of YAOS and is licenced under the MIT Licence.
//
//////////////////////////////////////////////////////////////////////////////////

module ecc24_fast (
	// Data input
	input [7:0] byte_0,
	input [7:0] byte_1,
	input [7:0] byte_2,
	
	// Data output
	output [7:0] ecc
);

// parity output
wire h0, h1, h2, h3, h4, h5;

// working data bits
wire d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23;

assign d0 = byte_0[0];
assign d1 = byte_0[1];
assign d2 = byte_0[2];
assign d3 = byte_0[3];
assign d4 = byte_0[4];
assign d5 = byte_0[5];
assign d6 = byte_0[6];
assign d7 = byte_0[7];
assign d8 = byte_1[0];
assign d9 = byte_1[1];
assign d10 = byte_1[2];
assign d11 = byte_1[3];
assign d12 = byte_1[4];
assign d13 = byte_1[5];
assign d14 = byte_1[6];
assign d15 = byte_1[7];
assign d16 = byte_2[0];
assign d17 = byte_2[1];
assign d18 = byte_2[2];
assign d19 = byte_2[3];
assign d20 = byte_2[4];
assign d21 = byte_2[5];
assign d22 = byte_2[6];
assign d23 = byte_2[7];

assign h0 =  d0 ^  d1 ^  d2 ^  d4 ^  d5 ^  d7 ^ d10 ^ d11 ^ d13 ^ d16 ^ d20 ^ d21 ^ d22 ^ d23;
assign h1 =  d0 ^  d1 ^  d3 ^  d4 ^  d6 ^  d8 ^ d10 ^ d12 ^ d14 ^ d17 ^ d20 ^ d21 ^ d22 ^ d23;
assign h2 =  d0 ^  d2 ^  d3 ^  d5 ^  d6 ^  d9 ^ d11 ^ d12 ^ d15 ^ d18 ^ d20 ^ d21 ^ d22;
assign h3 =  d1 ^  d2 ^  d3 ^  d7 ^  d8 ^  d9 ^ d13 ^ d14 ^ d15 ^ d19 ^ d20 ^ d21 ^ d23;
assign h4 =  d4 ^  d5 ^  d6 ^  d7 ^  d8 ^  d9 ^ d16 ^ d17 ^ d18 ^ d19 ^ d20 ^ d22 ^ d23;
assign h5 = d10 ^ d11 ^ d12 ^ d13 ^ d14 ^ d15 ^ d16 ^ d17 ^ d18 ^ d19 ^ d21 ^ d22 ^ d23;

assign ecc = (h0 | (h1 << 1) | (h2 << 2) | (h3 << 3) | (h4 << 4) | (h5 << 5));

endmodule