`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 09:50:43 PM
// Design Name: 
// Module Name: bias_point_buf
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


module bias_point_buf(
        input clk,
        input resetn,
        input enb,
        
        input bpbuf_ld,
        input [31:0] bpbuf_di,
        
        output reg [31:0] bpbuf_do
    );

    always @(posedge clk) begin
        if (!resetn) 
            bpbuf_do <= 0;
        else 
        if (enb) begin
            if (bpbuf_ld) begin
                bpbuf_do <= bpbuf_di;
            end
        end
    end

    
endmodule
