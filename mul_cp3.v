`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2026 10:20:34 AM
// Design Name: 
// Module Name: mul_cp3
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

module CP3(
    input x1, x2, x3, x4, 
    output y1, y2
);
    assign y1 = x1 | x2;
    assign y2 = x3 | x4;
//    assign y1 = x1 | x2 | x3;
//    assign y2 = x4;
endmodule

