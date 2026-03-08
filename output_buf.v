`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 09:36:00 PM
// Design Name: 
// Module Name: output_buf
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


module output_buf(
        input clk,
        input reset,
        input enb,
        
        input [31:0] obuf_di,
        input obuf_ld,
        
        output reg [31:0] obuf_do
    );

    always @(posedge clk) begin
        if (reset) begin
            obuf_do <= 0;
        end
        else begin
            if (enb) begin
                if (obuf_ld) begin
                    obuf_do <= obuf_di;
                end 
            end
        end
    end
    
endmodule
