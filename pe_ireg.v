`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2026 08:04:16 PM
// Design Name: 
// Module Name: pe_ireg
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


module pe_reg(
    input   enb,
    input   clk,
    input   reset,

    input   [7:0] reg_di_0,
    input   [7:0] reg_di_1,
    input   [7:0] reg_di_2,

    output reg [7:0] reg_do_0,
    output reg [7:0] reg_do_1,
    output reg [7:0] reg_do_2

);   
    always @(posedge clk) begin
        if (reset) begin
            reg_do_0 <= 0;
            reg_do_1 <= 0;
            reg_do_2 <= 0;
        end 
        else if (enb) begin
            reg_do_0 <= reg_di_0;
            reg_do_1 <= reg_di_1;
            reg_do_2 <= reg_di_2;
        end
    end

endmodule
