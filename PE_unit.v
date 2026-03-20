`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2025 07:59:15 PM
// Design Name: 
// Module Name: PE_unit
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


module PE_unit
(
        input clk,
        input rst,
        input enb,
        input [31:0] pe_input_offset,
        input [7:0] pe_wdi_0_0, pe_wdi_0_1, pe_wdi_0_2, pe_wdi_1_0, pe_wdi_1_1, pe_wdi_1_2, pe_wdi_2_0, pe_wdi_2_1, pe_wdi_2_2,
        input [7:0] pe_idi_0, pe_idi_1, pe_idi_2,
        output ready,
        output [31:0] pe_odo_0, pe_odo_1, pe_odo_2
    );

    wire [7:0] lpereg_0 [2:0];
    wire [7:0] lpereg_1 [2:0];
    wire [7:0] lpereg_2 [2:0];
    
    wire ready_0, ready_1, ready_2;
    
    assign ready = ready_0 || ready_1 || ready_2;
    // inst 0
    accel_lpe_reg lpe_0 (
        .clk (clk),
        .rst (rst),
        .enb (enb),
        .mac_ready(ready_0),
        .data_in_0 (pe_wdi_0_0),
        .data_in_1 (pe_wdi_0_1),
        .data_in_2 (pe_wdi_0_2),
        .data_out_0 (lpereg_0[0]),
        .data_out_1 (lpereg_0[1]),
        .data_out_2 (lpereg_0[2])
    );

    accel_mac mac_0 (
        .clk (clk),
        .rst (rst),
        .enb (enb),
        .input_offset (pe_input_offset),
        .idi_0 (pe_idi_0),
        .idi_1 (pe_idi_1),
        .idi_2 (pe_idi_2),
        .wdi_0 (lpereg_0[0]),
        .wdi_1 (lpereg_0[1]),
        .wdi_2 (lpereg_0[2]),
        .ready (ready_0),
        .mac_odo (pe_odo_0)
    );

    // inst 1
    accel_lpe_reg lpe_1 (
        .clk (clk),
        .rst (rst),
        .enb (enb),
        .mac_ready(ready_1),
        .data_in_0 (pe_wdi_1_0),
        .data_in_1 (pe_wdi_1_1),
        .data_in_2 (pe_wdi_1_2),
        .data_out_0 (lpereg_1[0]),
        .data_out_1 (lpereg_1[1]),
        .data_out_2 (lpereg_1[2])
    );
    
    accel_mac mac_1 (
        .clk (clk),
        .rst (rst),
        .enb (enb),
        .input_offset (pe_input_offset),
        .idi_0 (pe_idi_0),
        .idi_1 (pe_idi_1),
        .idi_2 (pe_idi_2),
        .wdi_0 (lpereg_1[0]),
        .wdi_1 (lpereg_1[1]),
        .wdi_2 (lpereg_1[2]),
        .ready (ready_1),
        .mac_odo (pe_odo_1)
    );
    
    // inst 2
    accel_lpe_reg lpe_2 (
        .clk (clk),
        .rst (rst),
        .enb (enb),
        .mac_ready(ready_2),
        .data_in_0 (pe_wdi_2_0),
        .data_in_1 (pe_wdi_2_1),
        .data_in_2 (pe_wdi_2_2),
        .data_out_0 (lpereg_2[0]),
        .data_out_1 (lpereg_2[1]),
        .data_out_2 (lpereg_2[2])
    );
    
    accel_mac mac_2 (
        .clk (clk),
        .rst (rst),
        .enb (enb),
        .input_offset (pe_input_offset),
        .idi_0 (pe_idi_0),
        .idi_1 (pe_idi_1),
        .idi_2 (pe_idi_2),
        .wdi_0 (lpereg_2[0]),
        .wdi_1 (lpereg_2[1]),
        .wdi_2 (lpereg_2[2]),
        .ready (ready_2),
        .mac_odo (pe_odo_2)
    );

endmodule
