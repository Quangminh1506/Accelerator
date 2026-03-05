`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2026 09:00:02 PM
// Design Name: 
// Module Name: quant_lut
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module quant_lut(
    input   [31:0] quant_muler,

    output  [63:0] quant_val_0,
    output  [63:0] quant_val_1,
    output  [63:0] quant_val_2,
    output  [63:0] quant_val_3,
    output  [63:0] quant_val_4,
    output  [63:0] quant_val_5,
    output  [63:0] quant_val_6,
    output  [63:0] quant_val_7,
    output  [63:0] quant_val_8,
    output  [63:0] quant_val_9,
    output  [63:0] quant_val_10,
    output  [63:0] quant_val_11,
    output  [63:0] quant_val_12,
    output  [63:0] quant_val_13,
    output  [63:0] quant_val_14,
    output  [63:0] quant_val_15
);
    wire [63:0] quant_muler_0, quant_muler_1, quant_muler_2, quant_muler_3;

    assign quant_muler_0 = quant_muler;
    assign quant_muler_1 = quant_muler_0 << 1;
    assign quant_muler_2 = quant_muler_1 << 1;
    assign quant_muler_3 = quant_muler_2 << 1;

    assign quant_val_0 = 0;
    assign quant_val_1 = quant_muler_0;
    assign quant_val_2 = quant_muler_1;
    assign quant_val_3 = quant_muler_1 + quant_muler_0;
    assign quant_val_4 = quant_muler_2;
    assign quant_val_5 = quant_muler_2 + quant_muler_0;
    assign quant_val_6 = quant_muler_2 + quant_muler_1;
    assign quant_val_7 = quant_muler_2 + quant_muler_1 + quant_muler_0;
    assign quant_val_8 = quant_muler_3;
    assign quant_val_9 = quant_muler_3 + quant_muler_0;
    assign quant_val_10 = quant_muler_3 + quant_muler_1;
    assign quant_val_11 = quant_muler_3 + quant_muler_1 + quant_muler_0;
    assign quant_val_12 = quant_muler_3 + quant_muler_2;
    assign quant_val_13 = quant_muler_3 + quant_muler_2 + quant_muler_0;
    assign quant_val_14 = quant_muler_3 + quant_muler_2 + quant_muler_1;
    assign quant_val_15 = quant_muler_3 + quant_muler_2 + quant_muler_1 + quant_muler_0;

endmodule
