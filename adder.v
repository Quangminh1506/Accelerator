`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2026 06:27:37 PM
// Design Name: 
// Module Name: adder
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

module RCA (
    input  [15:0] a,    
    input  [15:0] b,    
    output [15:0] sum   
);
    wire [16:0] c;      

    assign c[0] = 1'b0; 
    
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : rca_loop
            FA fa_inst (
                .a(a[i]),
                .b(b[i]),
                .cin(c[i]),
                .sum(sum[i]),
                .cout(c[i+1])
            );
        end
    endgenerate
    
    // Lưu ý: Bit nhớ cuối cùng c[16] thường bị bỏ qua trong nhân 8x8 
    // vì kết quả tối đa 16 bit.
endmodule

module compress_exact_42(
    input x1,x2,x3,x4,cin,
    output sum, carry, cout
);
    wire s1;
    FA FA1(.a(x1), .b(x2), .cin(x3), .sum(s1), .cout(cout));
    FA FA2(.a(s1), .b(x4), .cin(cin), .sum(sum), .cout(carry));
endmodule

module FA (
    input  a, b, cin,
    output sum, cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a&cin) | (b&cin) | (a&b);
endmodule

module HA ( 
    input a, b,
    output sum, carry
);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule
