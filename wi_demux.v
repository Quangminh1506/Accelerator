`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2026 08:05:25 PM
// Design Name: 
// Module Name: wi_demux
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


module wi_demux(
        input [7:0] demux_di_0,
        input [7:0] demux_di_1,
        input [7:0] demux_di_2,

        output reg [7:0] demux_do_0_0,
        output reg [7:0] demux_do_0_1,
        output reg [7:0] demux_do_0_2,
        output reg [7:0] demux_do_1_0,
        output reg [7:0] demux_do_1_1,
        output reg [7:0] demux_do_1_2,
        output reg [7:0] demux_do_2_0,
        output reg [7:0] demux_do_2_1,
        output reg [7:0] demux_do_2_2,

        input [1:0] demux_sel
    );
    
    always @(*) begin
        demux_do_0_0 = 8'd0;
        demux_do_0_1 = 8'd0;
        demux_do_0_2 = 8'd0;
        demux_do_1_0 = 8'd0;
        demux_do_1_1 = 8'd0;
        demux_do_1_2 = 8'd0;
        demux_do_2_0 = 8'd0;
        demux_do_2_1 = 8'd0;
        demux_do_2_2 = 8'd0;
        case (demux_sel)
            2'd0: begin
                demux_do_0_0 = demux_di_0;
                demux_do_0_1 = demux_di_1;
                demux_do_0_2 = demux_di_2;
            end

            2'd1: begin
                demux_do_1_0 = demux_di_0;
                demux_do_1_1 = demux_di_1;
                demux_do_1_2 = demux_di_2;
            end

            2'd2: begin
                demux_do_2_0 = demux_di_0;
                demux_do_2_1 = demux_di_1;
                demux_do_2_2 = demux_di_2;
            end
        endcase
    end
    
endmodule
