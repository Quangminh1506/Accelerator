`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2026 10:20:34 AM
// Design Name: 
// Module Name: mul_8bit
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

module M8_CP13_6 (
    input  wire [7:0] A,
    input  wire [7:0] B,
    output wire [15:0] P
);

    wire pp [7:0][7:0];
    genvar i, j;
    generate
        for (i=0; i<8; i=i+1) begin : gen_pp_row
            for (j=0; j<8; j=j+1) begin : gen_pp_col
                assign pp[i][j] = A[i] & B[j];
            end
        end
    endgenerate

    wire col1_s2 = pp[0][1] | pp[1][0];
    wire col2_s2_0, col2_s2_1;
    wire col3_s2_0, col3_s2_1;
    wire col4_s2_0, col4_s2_1, col4_s2_2;
    wire col5_s2_0, col5_s2_1, col5_s2_2;
    wire col6_s2_0, col6_s2_1, col6_s2_2, col6_s2_3;
    wire col7_s2_0, col7_s2_1, col7_s2_2, col7_s2_3;
    
    wire col8_s2_0, col8_s2_1;
    wire col8_s2_cout0, col8_s2_cout1;
    wire col9_s2_carry0, col9_s2_carry1;
        
    wire col9_s2_0, col9_s2_1;
    wire col9_s2_cout0;  
    wire col10_s2_carry0, col10_s2_carry1;
    
    wire col10_s2_0, col10_s2_1;
    wire col10_s2_cout0;  
    wire col11_s2_carry0;
    
    wire col11_s2_0;
    wire col11_s2_cout0;  
    wire col12_s2_carry0;
    
    wire col12_s2_0, col12_s2_1;    
    wire col13_s2_carry0;
    
    wire col13_s2_0, col13_s2_1;    
    
    wire col14_s2_0;
    
    // stage 1
    // approximate
    compress_32 col2_s2_inst(.a(pp[0][2]), .b(pp[1][1]), .c(pp[2][0]), .y1(col2_s2_0), .y2(col2_s2_1));
    CP3 col3_s2_inst(.x1(pp[0][3]), .x2(pp[1][2]), .x3(pp[2][1]), .x4(pp[3][0]), .y1(col3_s2_0), .y2(col3_s2_1));
    CP3 col4_s2_inst(.x1(pp[0][4]), .x2(pp[1][3]), .x3(pp[2][2]), .x4(pp[3][1]), .y1(col4_s2_0), .y2(col4_s2_1));
    assign col4_s2_2 = pp[4][0];
    CP3 col5_s2_inst(.x1(pp[0][5]), .x2(pp[1][4]), .x3(pp[2][3]), .x4(pp[3][2]), .y1(col5_s2_0), .y2(col5_s2_1));
    assign col5_s2_2 = pp[4][1] | pp[5][0];
    CP3 col6_s2_inst0(.x1(pp[0][6]), .x2(pp[1][5]), .x3(pp[2][4]), .x4(pp[3][3]), .y1(col6_s2_0), .y2(col6_s2_1));
    compress_32 col6_s2_inst1(.a(pp[4][2]), .b(pp[5][1]), .c(pp[6][0]), .y1(col6_s2_2), .y2(col6_s2_3));
    CP3 col7_s2_inst0(.x1(pp[0][7]), .x2(pp[1][6]), .x3(pp[2][5]), .x4(pp[3][4]), .y1(col7_s2_0), .y2(col7_s2_1));
    CP3 col7_s2_inst1(.x1(pp[4][3]), .x2(pp[5][2]), .x3(pp[6][1]), .x4(pp[7][0]), .y1(col7_s2_2), .y2(col7_s2_3));
    
    // exact
    compress_exact_42 col8_s2_inst0(.x1(pp[1][7]), .x2(pp[2][6]), .x3(pp[3][5]), .x4(pp[4][4]), .cin(1'b0), .sum(col8_s2_0), .carry(col9_s2_carry0), .cout(col8_s2_cout0));
    compress_exact_42 col8_s2_inst1(.x1(pp[5][3]), .x2(pp[6][2]), .x3(pp[7][1]), .x4(1'b0), .cin(1'b0), .sum(col8_s2_1), .carry(col9_s2_carry1), .cout(col8_s2_cout1));
    
    compress_exact_42 col9_s2_inst0(.x1(pp[2][7]), .x2(pp[3][6]), .x3(pp[4][5]), .x4(pp[5][4]), .cin(col8_s2_cout0), .sum(col9_s2_0), .carry(col10_s2_carry0), .cout(col9_s2_cout0));
    FA col9_s2_inst1(.a(pp[6][3]), .b(pp[7][2]), .cin(col8_s2_cout1), .sum(col9_s2_1), .cout(col10_s2_carry1));
    
    compress_exact_42 col10_s2_inst0(.x1(pp[3][7]), .x2(pp[4][6]), .x3(pp[5][5]), .x4(pp[6][4]), .cin(col9_s2_cout0), .sum(col10_s2_0), .carry(col11_s2_carry0), .cout(col10_s2_cout0));
    assign col10_s2_1 = pp[7][3];

    compress_exact_42 col11_s2_inst0(.x1(pp[4][7]), .x2(pp[5][6]), .x3(pp[6][5]), .x4(pp[7][4]), .cin(col10_s2_cout0), .sum(col11_s2_0), .carry(col12_s2_carry0), .cout(col11_s2_cout0));

    FA col12_s2_inst0(.a(pp[5][7]), .b(pp[6][6]), .cin(col11_s2_cout0), .sum(col12_s2_0), .cout(col13_s2_carry0));
    assign col12_s2_1 = pp[7][5];
    
    assign col13_s2_0 = pp[6][7];
    assign col13_s2_1 = pp[7][6];

    assign col14_s2_0 = pp[7][7];

    //stage 2
    wire col4_0, col4_1;
    wire col5_0, col5_1;
    
    wire col6_0;
    wire col7_carry0;
    
    wire col7_0;
    wire col8_carry0;
    
    wire col8_0;
    wire col9_carry0;
    
    wire col9_0;
    wire col9_cout0;
    wire col10_carry0;
    
    wire col10_0;
    wire col10_cout0;
    wire col11_carry0;
    
    wire col11_0;
    wire col12_carry0;
    
    wire col12_0;
    wire col13_carry0;
    
    wire col13_0;
    wire col14_carry0;
    
    wire col14_0;
    
    //aprox
    compress_32 col4_inst(.a(col4_s2_0), .b(col4_s2_1), .c(col4_s2_2), .y1(col4_0), .y2(col4_1));
    compress_32 col5_inst(.a(col5_s2_0), .b(col5_s2_1), .c(col5_s2_2), .y1(col5_0), .y2(col5_1));
    CP1 col6_inst(.x1(col6_s2_0), .x2(col6_s2_1), .x3(col6_s2_2), .x4(col6_s2_3), .sum(col6_0), .carry(col7_carry0));
    CP1 col7_inst(.x1(col7_s2_0), .x2(col7_s2_1), .x3(col7_s2_2), .x4(col7_s2_3), .sum(col7_0), .carry(col8_carry0));

    //exact
    HA col8_inst(.a(col8_s2_0), .b(col8_s2_1), .sum(col8_0), .carry(col9_carry0));
    
    compress_exact_42 col9_inst(.x1(col9_s2_0), .x2(col9_s2_1), .x3(col9_s2_carry0), .x4(col9_s2_carry0), .cin(1'b0), .sum(col9_0), .carry(col10_carry0), .cout(col9_cout0));

    compress_exact_42 col10_inst(.x1(col10_s2_0), .x2(col10_s2_1), .x3(col10_s2_carry0), .x4(col10_s2_carry0), .cin(col9_cout0), .sum(col10_0), .carry(col11_carry0), .cout(col10_cout0));

    FA col11_inst(.a(col11_s2_0), .b(col11_s2_carry0), .cin(col10_cout0), .sum(col11_0), .cout(col12_carry0));

    FA col12_inst(.a(col12_s2_0), .b(col12_s2_1), .cin(col12_s2_carry0), .sum(col12_0), .cout(col13_carry0));

    FA col13_inst(.a(col13_s2_0), .b(col13_s2_1), .cin(col13_s2_carry0), .sum(col13_0), .cout(col14_carry0));

    assign col14_0 = col14_s2_0;

    //last stage
    wire [15:0] rowA,rowB;
    
    assign rowA ={col14_0, col13_0, col12_0, col11_0, col10_0, col9_0, col8_0, col7_0, col6_0, col5_0, col4_0, col3_s2_0, col2_s2_0, col1_s2, pp[0][0]};
    assign rowB ={col14_carry0, col13_carry0, col12_carry0, col11_carry0, col10_carry0, col9_carry0, col8_carry0, col7_carry0, 1'b0, col5_1, col4_1, col3_s2_1, col2_s2_1, 1'b0, 1'b0};

    RCA RCA_inst(.a(rowA), .b(rowB), .sum(P));

endmodule