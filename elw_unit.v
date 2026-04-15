`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2026 09:27:34 PM
// Design Name: 
// Module Name: elw_unit
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


module elw_unit(
        input clk,
        input resetn,
        
       //ctrl sigs
        input   quant_act_func_enb_0,
        input   quant_act_func_enb_1,
        input   quant_act_func_enb_2,
 
        input   cp_clr,
        input   cp2h_enb,
        input   cp2w_enb,
        input   cp_enb,
        
        //config sigs
        input  [31:0] elew_quant_muler_0,
        input  [31:0] elew_quant_muler_1,
        input  [31:0] elew_quant_muler_2,

        input  [ 7:0] elew_quant_rshift_0,
        input  [ 7:0] elew_quant_rshift_1,
        input  [ 7:0] elew_quant_rshift_2,

        input  [31:0] elew_output_offset,

        input  [3:0] elew_act_func_type,
        
        //input data
        input  [31:0] elew_di_0_0,
        input  [31:0] elew_di_0_1,
        input  [31:0] elew_di_0_2,

        input  [7:0] elew_di_1_0,
        input  [7:0] elew_di_1_1,
        input  [7:0] elew_di_1_2,
        
        //output sigs
        output [7:0] elew_do_0_0,
        output [7:0] elew_do_0_1,
        output [7:0] elew_do_0_2,
        
        output [7:0] elew_do_1,
        
        output  valid_0,
        output  valid_1,
        output  valid_2
    );  
    
    wire [31:0] quant_to_act_func_0, quant_to_act_func_1, quant_to_act_func_2;

    wire [31:0] act_func_do_0, act_func_do_1, act_func_do_2;

    wire [63:0] lut_to_quant_0_0, lut_to_quant_0_1, lut_to_quant_0_2, lut_to_quant_0_3, lut_to_quant_0_4, lut_to_quant_0_5,
                lut_to_quant_0_6, lut_to_quant_0_7 ,lut_to_quant_0_8, lut_to_quant_0_9, lut_to_quant_0_10,
                lut_to_quant_0_11, lut_to_quant_0_12, lut_to_quant_0_13, lut_to_quant_0_14, lut_to_quant_0_15;

    wire [63:0] lut_to_quant_1_0, lut_to_quant_1_1, lut_to_quant_1_2, lut_to_quant_1_3, lut_to_quant_1_4, lut_to_quant_1_5,
                lut_to_quant_1_6, lut_to_quant_1_7, lut_to_quant_1_8, lut_to_quant_1_9, lut_to_quant_1_10,
                lut_to_quant_1_11, lut_to_quant_1_12, lut_to_quant_1_13, lut_to_quant_1_14, lut_to_quant_1_15;

    wire [63:0] lut_to_quant_2_0, lut_to_quant_2_1, lut_to_quant_2_2, lut_to_quant_2_3, lut_to_quant_2_4, lut_to_quant_2_5,
                lut_to_quant_2_6, lut_to_quant_2_7, lut_to_quant_2_8, lut_to_quant_2_9, lut_to_quant_2_10,
                lut_to_quant_2_11, lut_to_quant_2_12, lut_to_quant_2_13, lut_to_quant_2_14, lut_to_quant_2_15;
    
    //Quantilize
    // first
    quant_lut  quant_lut_0 (
        .quant_muler    (elew_quant_muler_0),
        
        .quant_val_0    (lut_to_quant_0_0),
        .quant_val_1    (lut_to_quant_0_1),
        .quant_val_2    (lut_to_quant_0_2),
        .quant_val_3    (lut_to_quant_0_3),
        .quant_val_4    (lut_to_quant_0_4),
        .quant_val_5    (lut_to_quant_0_5),
        .quant_val_6    (lut_to_quant_0_6),
        .quant_val_7    (lut_to_quant_0_7),
        .quant_val_8    (lut_to_quant_0_8),
        .quant_val_9    (lut_to_quant_0_9),
        .quant_val_10   (lut_to_quant_0_10),
        .quant_val_11   (lut_to_quant_0_11),
        .quant_val_12   (lut_to_quant_0_12),
        .quant_val_13   (lut_to_quant_0_13),
        .quant_val_14   (lut_to_quant_0_14),
        .quant_val_15   (lut_to_quant_0_15)
    );

    quant_unit quant_unit_0 (
        .clk   (clk),
        .resetn (resetn),
        .enb    (quant_act_func_enb_0),

        .quant_di       (elew_di_0_0),
        .quant_do       (quant_to_act_func_0),

        .quant_rshift   (elew_quant_rshift_0),

        .quant_val_0    (lut_to_quant_0_0),
        .quant_val_1    (lut_to_quant_0_1),
        .quant_val_2    (lut_to_quant_0_2),
        .quant_val_3    (lut_to_quant_0_3),
        .quant_val_4    (lut_to_quant_0_4),
        .quant_val_5    (lut_to_quant_0_5),
        .quant_val_6    (lut_to_quant_0_6),
        .quant_val_7    (lut_to_quant_0_7),
        .quant_val_8    (lut_to_quant_0_8),
        .quant_val_9    (lut_to_quant_0_9),
        .quant_val_10   (lut_to_quant_0_10),
        .quant_val_11   (lut_to_quant_0_11),
        .quant_val_12   (lut_to_quant_0_12),
        .quant_val_13   (lut_to_quant_0_13),
        .quant_val_14   (lut_to_quant_0_14),
        .quant_val_15   (lut_to_quant_0_15),

        .valid  (valid_0)
    );
    
    act_func act_func_0 (
        .act_func_di (quant_to_act_func_0),
        .act_func_type (elew_act_func_type),
        .act_func_do (act_func_do_0)
    );

    // second
    quant_lut  quant_lut_1 (
        .quant_muler    (elew_quant_muler_1),
        
        .quant_val_0    (lut_to_quant_1_0),
        .quant_val_1    (lut_to_quant_1_1),
        .quant_val_2    (lut_to_quant_1_2),
        .quant_val_3    (lut_to_quant_1_3),
        .quant_val_4    (lut_to_quant_1_4),
        .quant_val_5    (lut_to_quant_1_5),
        .quant_val_6    (lut_to_quant_1_6),
        .quant_val_7    (lut_to_quant_1_7),
        .quant_val_8    (lut_to_quant_1_8),
        .quant_val_9    (lut_to_quant_1_9),
        .quant_val_10   (lut_to_quant_1_10),
        .quant_val_11   (lut_to_quant_1_11),
        .quant_val_12   (lut_to_quant_1_12),
        .quant_val_13   (lut_to_quant_1_13),
        .quant_val_14   (lut_to_quant_1_14),
        .quant_val_15   (lut_to_quant_1_15)
    );

    quant_unit quant_unit_1 (
        .clk   (clk),
        .resetn (resetn),
        .enb   (quant_act_func_enb_1),
        
        .quant_di       (elew_di_0_1),
        .quant_do       (quant_to_act_func_1),

        .quant_rshift   (elew_quant_rshift_1),

        .quant_val_0    (lut_to_quant_1_0),
        .quant_val_1    (lut_to_quant_1_1),
        .quant_val_2    (lut_to_quant_1_2),
        .quant_val_3    (lut_to_quant_1_3),
        .quant_val_4    (lut_to_quant_1_4),
        .quant_val_5    (lut_to_quant_1_5),
        .quant_val_6    (lut_to_quant_1_6),
        .quant_val_7    (lut_to_quant_1_7),
        .quant_val_8    (lut_to_quant_1_8),
        .quant_val_9    (lut_to_quant_1_9),
        .quant_val_10   (lut_to_quant_1_10),
        .quant_val_11   (lut_to_quant_1_11),
        .quant_val_12   (lut_to_quant_1_12),
        .quant_val_13   (lut_to_quant_1_13),
        .quant_val_14   (lut_to_quant_1_14),
        .quant_val_15   (lut_to_quant_1_15),
        
        .valid  (valid_1)
    );
    
    act_func act_func_1 (
        .act_func_di (quant_to_act_func_1),
        .act_func_type (elew_act_func_type),
        .act_func_do (act_func_do_1)
    );
    
    // third
    quant_lut  quant_lut_2 (
        .quant_muler    (elew_quant_muler_2),
        
        .quant_val_0    (lut_to_quant_2_0),
        .quant_val_1    (lut_to_quant_2_1),
        .quant_val_2    (lut_to_quant_2_2),
        .quant_val_3    (lut_to_quant_2_3),
        .quant_val_4    (lut_to_quant_2_4),
        .quant_val_5    (lut_to_quant_2_5),
        .quant_val_6    (lut_to_quant_2_6),
        .quant_val_7    (lut_to_quant_2_7),
        .quant_val_8    (lut_to_quant_2_8),
        .quant_val_9    (lut_to_quant_2_9),
        .quant_val_10   (lut_to_quant_2_10),
        .quant_val_11   (lut_to_quant_2_11),
        .quant_val_12   (lut_to_quant_2_12),
        .quant_val_13   (lut_to_quant_2_13),
        .quant_val_14   (lut_to_quant_2_14),
        .quant_val_15   (lut_to_quant_2_15)
    );

    quant_unit quant_unit_2 (
        .clk   (clk),
        .resetn (resetn),
        .enb   (quant_act_func_enb_2),
        
        .quant_di       (elew_di_0_2),
        .quant_do       (quant_to_act_func_2),

        .quant_rshift   (elew_quant_rshift_2),

        .quant_val_0    (lut_to_quant_2_0),
        .quant_val_1    (lut_to_quant_2_1),
        .quant_val_2    (lut_to_quant_2_2),
        .quant_val_3    (lut_to_quant_2_3),
        .quant_val_4    (lut_to_quant_2_4),
        .quant_val_5    (lut_to_quant_2_5),
        .quant_val_6    (lut_to_quant_2_6),
        .quant_val_7    (lut_to_quant_2_7),
        .quant_val_8    (lut_to_quant_2_8),
        .quant_val_9    (lut_to_quant_2_9),
        .quant_val_10   (lut_to_quant_2_10),
        .quant_val_11   (lut_to_quant_2_11),
        .quant_val_12   (lut_to_quant_2_12),
        .quant_val_13   (lut_to_quant_2_13),
        .quant_val_14   (lut_to_quant_2_14),
        .quant_val_15   (lut_to_quant_2_15),
        
        .valid  (valid_2)
    );
    
    act_func act_func_2 (
        .act_func_di (quant_to_act_func_2),
        .act_func_type (elew_act_func_type),
        .act_func_do (act_func_do_2)
    );
    
    //compare unit
    cp_unit cp_unit (
        .clk   (clk),
        .resetn (resetn),
        .enb   (cp_enb),

        .cp_di_0    (elew_di_1_0),
        .cp_di_1    (elew_di_1_1),
        .cp_di_2    (elew_di_1_2),

        .cp_clr     (cp_clr),
        .cp2h_enb   (cp2h_enb),
        .cp2w_enb   (cp2w_enb),
        .elew_act_func_type (elew_act_func_type),

        .cp_do      (elew_do_1)
    );
    
    wire [31:0] acc_sub_offset_0, acc_sub_offset_1, acc_sub_offset_2;
    assign acc_sub_offset_0 = act_func_do_0 - elew_output_offset;
    assign acc_sub_offset_1 = act_func_do_1 - elew_output_offset;
    assign acc_sub_offset_2 = act_func_do_2 - elew_output_offset;

    reg [7:0] out_0, out_1, out_2;

    always @* begin
        if (elew_act_func_type == 4'd0) begin
            if (acc_sub_offset_0 > 255) out_0 = 8'hFF;
            else out_0 = acc_sub_offset_0[7:0];

            if (acc_sub_offset_1 > 255) out_1 = 8'hFF;
            else out_1 = acc_sub_offset_1[7:0];

            if (acc_sub_offset_2 > 255) out_2 = 8'hFF;
            else out_2 = acc_sub_offset_2[7:0];

        end
        else begin
            if ($signed(acc_sub_offset_0) < -128) out_0 = 8'h80;
            else if ($signed(acc_sub_offset_0) > 127) out_0 = 8'h7F;
            else out_0 = acc_sub_offset_0[7:0];

            if ($signed(acc_sub_offset_1) < -128) out_1 = 8'h80;
            else if ($signed(acc_sub_offset_1) > 127) out_1 = 8'h7F;
            else out_1 = acc_sub_offset_1[7:0];

            if ($signed(acc_sub_offset_2) < -128) out_2 = 8'h80;
            else if ($signed(acc_sub_offset_2) > 127) out_2 = 8'h7F;
            else out_2 = acc_sub_offset_2[7:0];
        end
    end

    assign elew_do_0_0 = out_0;
    assign elew_do_0_1 = out_1;
    assign elew_do_0_2 = out_2;
    
endmodule
