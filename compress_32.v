`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/14/2026 07:31:06 PM
// Design Name: 
// Module Name: compress_32
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


module compress_32(
        input a,b,c,
        output y1,y2
    );
    
    assign y1 = a | b;
    assign y2 = c;
    
endmodule
