`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2026 08:06:28 PM
// Design Name: 
// Module Name: pe_wreg
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


module pe_wreg(
    input   enb,
    input   clk,
    input   resetn,

    input   [7:0] wreg_di_0,
    input   [7:0] wreg_di_1,
    input   [7:0] wreg_di_2,

    output reg [7:0] wreg_do_0,
    output reg [7:0] wreg_do_1,
    output reg [7:0] wreg_do_2

);   
    always @(posedge clk) begin
        if (!resetn) begin
            wreg_do_0 <= 0;
            wreg_do_1 <= 0;
            wreg_do_2 <= 0;
        end 
        else if (enb) begin
            wreg_do_0 <= wreg_di_0;
            wreg_do_1 <= wreg_di_1;
            wreg_do_2 <= wreg_di_2;
        end
    end

endmodule
