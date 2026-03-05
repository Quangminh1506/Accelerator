`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2026 06:35:36 PM
// Design Name: 
// Module Name: accel_lpu_reg
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


module accel_lpe_reg(
        input clk,
        input rst,
        input enb,
        input mac_ready,
        input [7:0] data_in_0, data_in_1, data_in_2, 
        output reg [7:0] data_out_0, data_out_1, data_out_2
    );
    
    always @(posedge clk) begin
        if (rst) begin
            data_out_0 <= 0;
            data_out_1 <= 0;
            data_out_2 <= 0;
        end
        else begin
            if (enb & mac_ready) begin
                data_out_0 <= data_in_0;
                data_out_1 <= data_in_1;
                data_out_2 <= data_in_2; 
            end
        end
    end
    
endmodule
