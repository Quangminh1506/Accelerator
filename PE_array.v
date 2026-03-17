`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2026 08:27:29 PM
// Design Name: 
// Module Name: PE_array
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


module PE_array(
        input clk,
        input reset,
        
        //control signals
        input ireg_enb_0, ireg_enb_1, ireg_enb_2,
        input wreg_enb_0_0, wreg_enb_0_1, wreg_enb_0_2,
        input wreg_enb_1_0, wreg_enb_1_1, wreg_enb_1_2,
        input wreg_enb_2_0, wreg_enb_2_1, wreg_enb_2_2,
        input pe_enb_0, pe_enb_1, pe_enb_2,
        
        // Config signals
        input pe_arr_is_conv_layer,
        input [1:0]  pe_arr_conv_dir,
        input [31:0]  pe_arr_input_offset,
        

        // Data signals
        input [7:0] pe_arr_idi_0_0, pe_arr_idi_0_1, pe_arr_idi_0_2,
        input [7:0] pe_arr_idi_1_0, pe_arr_idi_1_1, pe_arr_idi_1_2,
        input [7:0] pe_arr_idi_2_0, pe_arr_idi_2_1, pe_arr_idi_2_2,
        
        // Weight signals
        // Row 0
        input [7:0] pe_arr_wdi_0_0_0, pe_arr_wdi_0_0_1, pe_arr_wdi_0_0_2,
        input [7:0] pe_arr_wdi_0_1_0, pe_arr_wdi_0_1_1, pe_arr_wdi_0_1_2,
        input [7:0] pe_arr_wdi_0_2_0, pe_arr_wdi_0_2_1, pe_arr_wdi_0_2_2,
        // Row 1                                          
        input [7:0] pe_arr_wdi_1_0_0, pe_arr_wdi_1_0_1, pe_arr_wdi_1_0_2,
        input [7:0] pe_arr_wdi_1_1_0, pe_arr_wdi_1_1_1, pe_arr_wdi_1_1_2,
        input [7:0] pe_arr_wdi_1_2_0, pe_arr_wdi_1_2_1, pe_arr_wdi_1_2_2,
        // Row 2                                          
        input [7:0] pe_arr_wdi_2_0_0, pe_arr_wdi_2_0_1, pe_arr_wdi_2_0_2,
        input [7:0] pe_arr_wdi_2_1_0, pe_arr_wdi_2_1_1, pe_arr_wdi_2_1_2,
        input [7:0] pe_arr_wdi_2_2_0, pe_arr_wdi_2_2_1, pe_arr_wdi_2_2_2,
        
        //Output
        output [31:0] pe_arr_odo_0_0, pe_arr_odo_0_1, pe_arr_odo_0_2,
        output [31:0] pe_arr_odo_1_0, pe_arr_odo_1_1, pe_arr_odo_1_2,
        output [31:0] pe_arr_odo_2_0, pe_arr_odo_2_1, pe_arr_odo_2_2,
        
        output valid
    );
    
    localparam LEFT = 4'd1,
               RIGHT = 4'd2,
               DOWN = 4'd3;
    
    wire [7:0] ireg_to_pe [2:0][2:0]; 
    wire [7:0] wreg_to_pe [2:0][2:0][2:0]; 
    reg  [7:0] ireg_idi   [2:0][2:0];
    
    wire valid_0, valid_1, valid_2;
    assign valid = valid_0 || valid_1 || valid_2;
    
    always @* begin // [col][row]
        if (pe_arr_is_conv_layer) begin
            ireg_idi[0][0] = pe_arr_idi_0_0; 
            ireg_idi[0][1] = pe_arr_idi_0_1; 
            ireg_idi[0][2] = pe_arr_idi_0_2;
            ireg_idi[1][0] = pe_arr_idi_1_0; 
            ireg_idi[1][1] = pe_arr_idi_1_1; 
            ireg_idi[1][2] = pe_arr_idi_1_2;
            ireg_idi[2][0] = pe_arr_idi_2_0; 
            ireg_idi[2][1] = pe_arr_idi_2_1;
            ireg_idi[2][2] = pe_arr_idi_2_2;
                case (pe_arr_conv_dir)
                    LEFT: begin 
                        ireg_idi[0][0] = ireg_to_pe[1][0]; 
                        ireg_idi[0][1] = ireg_to_pe[1][1]; 
                        ireg_idi[0][2] = ireg_to_pe[1][2];
                        
                        ireg_idi[1][0] = ireg_to_pe[2][0]; 
                        ireg_idi[1][1] = ireg_to_pe[2][1]; 
                        ireg_idi[1][2] = ireg_to_pe[2][2];

                        ireg_idi[2][0] = pe_arr_idi_0_0; 
                        ireg_idi[2][1] = pe_arr_idi_0_1; 
                        ireg_idi[2][2] = pe_arr_idi_0_2;
                    end
                
                    RIGHT: begin
                        ireg_idi[0][0] = pe_arr_idi_0_0;
                        ireg_idi[0][1] = pe_arr_idi_0_1;
                        ireg_idi[0][2] = pe_arr_idi_0_2;
                        
                        ireg_idi[1][0] = ireg_idi[0][0];
                        ireg_idi[1][1] = ireg_idi[0][1];
                        ireg_idi[1][2] = ireg_idi[0][2];
                        
                        ireg_idi[2][0] = ireg_idi[1][0];
                        ireg_idi[2][1] = ireg_idi[1][1];
                        ireg_idi[2][2] = ireg_idi[1][2];
                    end

                    
                    DOWN: begin 
                        ireg_idi[0][0] = ireg_to_pe[0][1]; 
                        ireg_idi[0][1] = ireg_to_pe[0][2];
                        ireg_idi[1][0] = ireg_to_pe[1][1]; 
                        
                        ireg_idi[1][1] = ireg_to_pe[1][2];
                        ireg_idi[2][0] = ireg_to_pe[2][1]; 
                        ireg_idi[2][1] = ireg_to_pe[2][2];

                        ireg_idi[0][2] = pe_arr_idi_0_2;
                        ireg_idi[1][2] = pe_arr_idi_1_2;
                        ireg_idi[2][2] = pe_arr_idi_2_2;
                    end
                endcase
            end
        end
    
    //input reg
    pe_reg ireg_0 (
        .reg_di_0 (ireg_idi[0][0]),
        .reg_di_1 (ireg_idi[0][1]),
        .reg_di_2 (ireg_idi[0][2]),

        .reg_do_0 (ireg_to_pe[0][0]),
        .reg_do_1 (ireg_to_pe[0][1]),
        .reg_do_2 (ireg_to_pe[0][2]),

        .enb    (ireg_enb_0),
        .clk    (clk),
        .reset (reset)
    );
    
    pe_reg ireg_1 (
        .reg_di_0 (ireg_idi[1][0]),
        .reg_di_1 (ireg_idi[1][1]),
        .reg_di_2 (ireg_idi[1][2]),

        .reg_do_0 (ireg_to_pe[1][0]),
        .reg_do_1 (ireg_to_pe[1][1]),
        .reg_do_2 (ireg_to_pe[1][2]),

        .enb    (ireg_enb_1),
        .clk    (clk),
        .reset (reset)
    );
    
    pe_reg ireg_2 (
        .reg_di_0 (ireg_idi[2][0]),
        .reg_di_1 (ireg_idi[2][1]),
        .reg_di_2 (ireg_idi[2][2]),

        .reg_do_0 (ireg_to_pe[2][0]),
        .reg_do_1 (ireg_to_pe[2][1]),
        .reg_do_2 (ireg_to_pe[2][2]),

        .enb    (ireg_enb_2),
        .clk    (clk),
        .reset (reset)
    );
    
    //weight reg
    pe_reg wreg_0_0 (
        .reg_di_0 (pe_arr_wdi_0_0_0),
        .reg_di_1 (pe_arr_wdi_0_0_1),
        .reg_di_2 (pe_arr_wdi_0_0_2),

        .reg_do_0 (wreg_to_pe[0][0][0]),
        .reg_do_1 (wreg_to_pe[0][0][1]),
        .reg_do_2 (wreg_to_pe[0][0][2]),

        .enb    (wreg_enb_0_0),
        .clk    (clk),
        .reset (reset)
    );
    
    pe_reg wreg_0_1 (
        .reg_di_0 (pe_arr_wdi_0_1_0),
        .reg_di_1 (pe_arr_wdi_0_1_1),
        .reg_di_2 (pe_arr_wdi_0_1_2),

        .reg_do_0 (wreg_to_pe[0][1][0]),
        .reg_do_1 (wreg_to_pe[0][1][1]),
        .reg_do_2 (wreg_to_pe[0][1][2]),

        .enb    (wreg_enb_0_1),
        .clk    (clk),
        .reset (reset)
    );
    
    pe_reg wreg_0_2 (
        .reg_di_0 (pe_arr_wdi_0_2_0),
        .reg_di_1 (pe_arr_wdi_0_2_1),
        .reg_di_2 (pe_arr_wdi_0_2_2),

        .reg_do_0 (wreg_to_pe[0][2][0]),
        .reg_do_1 (wreg_to_pe[0][2][1]),
        .reg_do_2 (wreg_to_pe[0][2][2]),

        .enb    (wreg_enb_0_2),
        .clk    (clk),
        .reset (reset)
    );
    
    pe_reg wreg_1_0 (
        .reg_di_0 (pe_arr_wdi_1_0_0),
        .reg_di_1 (pe_arr_wdi_1_0_1),
        .reg_di_2 (pe_arr_wdi_1_0_2),

        .reg_do_0 (wreg_to_pe[1][0][0]),
        .reg_do_1 (wreg_to_pe[1][0][1]),
        .reg_do_2 (wreg_to_pe[1][0][2]),

        .enb    (wreg_enb_1_0),
        .clk    (clk),
        .reset (reset)
    );
    
    pe_reg wreg_1_1 (
        .reg_di_0 (pe_arr_wdi_1_1_0),
        .reg_di_1 (pe_arr_wdi_1_1_1),
        .reg_di_2 (pe_arr_wdi_1_1_2),

        .reg_do_0 (wreg_to_pe[1][1][0]),
        .reg_do_1 (wreg_to_pe[1][1][1]),
        .reg_do_2 (wreg_to_pe[1][1][2]),

        .enb    (wreg_enb_1_1),
        .clk    (clk),
        .reset (reset)
    );
    
    pe_reg wreg_1_2 (
        .reg_di_0 (pe_arr_wdi_1_2_0),
        .reg_di_1 (pe_arr_wdi_1_2_1),
        .reg_di_2 (pe_arr_wdi_1_2_2),

        .reg_do_0 (wreg_to_pe[1][2][0]),
        .reg_do_1 (wreg_to_pe[1][2][1]),
        .reg_do_2 (wreg_to_pe[1][2][2]),

        .enb    (wreg_enb_1_2),
        .clk    (clk),
        .reset (reset)
    );
    
    pe_reg wreg_2_0 (
        .reg_di_0 (pe_arr_wdi_2_0_0),
        .reg_di_1 (pe_arr_wdi_2_0_1),
        .reg_di_2 (pe_arr_wdi_2_0_2),

        .reg_do_0 (wreg_to_pe[2][0][0]),
        .reg_do_1 (wreg_to_pe[2][0][1]),
        .reg_do_2 (wreg_to_pe[2][0][2]),

        .enb    (wreg_enb_2_0),
        .clk    (clk),
        .reset (reset)
    );
    
    pe_reg wreg_2_1 (
        .reg_di_0 (pe_arr_wdi_2_1_0),
        .reg_di_1 (pe_arr_wdi_2_1_1),
        .reg_di_2 (pe_arr_wdi_2_1_2),

        .reg_do_0 (wreg_to_pe[2][1][0]),
        .reg_do_1 (wreg_to_pe[2][1][1]),
        .reg_do_2 (wreg_to_pe[2][1][2]),

        .enb    (wreg_enb_2_1),
        .clk    (clk),
        .reset (reset)
    );
    
    pe_reg wreg_2_2 (
        .reg_di_0 (pe_arr_wdi_2_2_0),
        .reg_di_1 (pe_arr_wdi_2_2_1),
        .reg_di_2 (pe_arr_wdi_2_2_2),

        .reg_do_0 (wreg_to_pe[2][2][0]),
        .reg_do_1 (wreg_to_pe[2][2][1]),
        .reg_do_2 (wreg_to_pe[2][2][2]),

        .enb    (wreg_enb_2_2),
        .clk    (clk),
        .reset (reset)
    );
    
    //PE units
    PE_unit pe_0 (
        .clk(clk), 
        .rst(reset), 
        .enb(pe_enb_0), 
        .pe_input_offset(pe_arr_input_offset),
        .pe_wdi_0_0(wreg_to_pe[0][0][0]), 
        .pe_wdi_0_1(wreg_to_pe[0][0][1]), 
        .pe_wdi_0_2(wreg_to_pe[0][0][2]),
        .pe_wdi_1_0(wreg_to_pe[0][1][0]), 
        .pe_wdi_1_1(wreg_to_pe[0][1][1]), 
        .pe_wdi_1_2(wreg_to_pe[0][1][2]),
        .pe_wdi_2_0(wreg_to_pe[0][2][0]), 
        .pe_wdi_2_1(wreg_to_pe[0][2][1]), 
        .pe_wdi_2_2(wreg_to_pe[0][2][2]),
        .pe_idi_0(ireg_to_pe[0][0]), 
        .pe_idi_1(ireg_to_pe[0][1]), 
        .pe_idi_2(ireg_to_pe[0][2]),
        .pe_odo_0(pe_arr_odo_0_0), 
        .pe_odo_1(pe_arr_odo_0_1), 
        .pe_odo_2(pe_arr_odo_0_2),
        .valid(valid_0)
    );
    
    PE_unit pe_1 (
        .clk(clk), 
        .rst(reset), 
        .enb(pe_enb_1), 
        .pe_input_offset(pe_arr_input_offset),
        .pe_wdi_0_0(wreg_to_pe[1][0][0]), 
        .pe_wdi_0_1(wreg_to_pe[1][0][1]), 
        .pe_wdi_0_2(wreg_to_pe[1][0][2]),
        .pe_wdi_1_0(wreg_to_pe[1][1][0]), 
        .pe_wdi_1_1(wreg_to_pe[1][1][1]), 
        .pe_wdi_1_2(wreg_to_pe[1][1][2]),
        .pe_wdi_2_0(wreg_to_pe[1][2][0]), 
        .pe_wdi_2_1(wreg_to_pe[1][2][1]), 
        .pe_wdi_2_2(wreg_to_pe[1][2][2]),
        .pe_idi_0(ireg_to_pe[1][0]), 
        .pe_idi_1(ireg_to_pe[1][1]), 
        .pe_idi_2(ireg_to_pe[1][2]),
        .pe_odo_0(pe_arr_odo_1_0), 
        .pe_odo_1(pe_arr_odo_1_1), 
        .pe_odo_2(pe_arr_odo_1_2),
        .valid(valid_1)
    );
    
    PE_unit pe_2(
        .clk(clk), 
        .rst(reset), 
        .enb(pe_enb_2), 
        .pe_input_offset(pe_arr_input_offset),
        .pe_wdi_0_0(wreg_to_pe[2][0][0]), 
        .pe_wdi_0_1(wreg_to_pe[2][0][1]), 
        .pe_wdi_0_2(wreg_to_pe[2][0][2]),
        .pe_wdi_1_0(wreg_to_pe[2][1][0]), 
        .pe_wdi_1_1(wreg_to_pe[2][1][1]), 
        .pe_wdi_1_2(wreg_to_pe[2][1][2]),
        .pe_wdi_2_0(wreg_to_pe[2][2][0]), 
        .pe_wdi_2_1(wreg_to_pe[2][2][1]), 
        .pe_wdi_2_2(wreg_to_pe[2][2][2]),
        .pe_idi_0(ireg_to_pe[2][0]), 
        .pe_idi_1(ireg_to_pe[2][1]), 
        .pe_idi_2(ireg_to_pe[2][2]),
        .pe_odo_0(pe_arr_odo_2_0), 
        .pe_odo_1(pe_arr_odo_2_1), 
        .pe_odo_2(pe_arr_odo_2_2),
        .valid(valid_2)
    );
    
endmodule
