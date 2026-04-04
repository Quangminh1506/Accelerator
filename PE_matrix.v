`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2026 06:25:25 PM
// Design Name: 
// Module Name: PE_matrix
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


module PE_matrix(
        input clk,
        input resetn,

        //Config sigs
        input matrix_is_conv_layer,
        input [1:0] matrix_conv_dir,     
        input [31:0] matrix_input_offset,       
        
        //Control sigs
        input   pe_matrix_wreg_enb_0_0_0,
        input   pe_matrix_wreg_enb_0_0_1,
        input   pe_matrix_wreg_enb_0_0_2,
        input   pe_matrix_wreg_enb_0_1_0,
        input   pe_matrix_wreg_enb_0_1_1,
        input   pe_matrix_wreg_enb_0_1_2,
        input   pe_matrix_wreg_enb_0_2_0,
        input   pe_matrix_wreg_enb_0_2_1,
        input   pe_matrix_wreg_enb_0_2_2,
        input   pe_matrix_wreg_enb_1_0_0,
        input   pe_matrix_wreg_enb_1_0_1,
        input   pe_matrix_wreg_enb_1_0_2,
        input   pe_matrix_wreg_enb_1_1_0,
        input   pe_matrix_wreg_enb_1_1_1,
        input   pe_matrix_wreg_enb_1_1_2,
        input   pe_matrix_wreg_enb_1_2_0,
        input   pe_matrix_wreg_enb_1_2_1,
        input   pe_matrix_wreg_enb_1_2_2,
        input   pe_matrix_wreg_enb_2_0_0,
        input   pe_matrix_wreg_enb_2_0_1,
        input   pe_matrix_wreg_enb_2_0_2,
        input   pe_matrix_wreg_enb_2_1_0,
        input   pe_matrix_wreg_enb_2_1_1,
        input   pe_matrix_wreg_enb_2_1_2,
        input   pe_matrix_wreg_enb_2_2_0,
        input   pe_matrix_wreg_enb_2_2_1,
        input   pe_matrix_wreg_enb_2_2_2,
                 
        input   pe_matrix_ireg_enb_0_0,
        input   pe_matrix_ireg_enb_0_1,
        input   pe_matrix_ireg_enb_0_2,
        input   pe_matrix_ireg_enb_1_0,
        input   pe_matrix_ireg_enb_1_1,
        input   pe_matrix_ireg_enb_1_2,
        input   pe_matrix_ireg_enb_2_0,
        input   pe_matrix_ireg_enb_2_1,
        input   pe_matrix_ireg_enb_2_2,
                 
        input   pe_enb_0_0,
        input   pe_enb_0_1,
        input   pe_enb_0_2,
        input   pe_enb_1_0,
        input   pe_enb_1_1,
        input   pe_enb_1_2,
        input   pe_enb_2_0,
        input   pe_enb_2_1,
        input   pe_enb_2_2,
        
        //Weight
        input   [7:0] pe_matrix_wdi_0_0,
        input   [7:0] pe_matrix_wdi_0_1,
        input   [7:0] pe_matrix_wdi_0_2,
        input   [7:0] pe_matrix_wdi_1_0,
        input   [7:0] pe_matrix_wdi_1_1,
        input   [7:0] pe_matrix_wdi_1_2,
        input   [7:0] pe_matrix_wdi_2_0,
        input   [7:0] pe_matrix_wdi_2_1,
        input   [7:0] pe_matrix_wdi_2_2,
        
        //Weight sel                
        input   [1:0] pe_matrix_wsel_0,
        input   [1:0] pe_matrix_wsel_1,
        input   [1:0] pe_matrix_wsel_2,
       
        //Data               
        input   [7:0] pe_matrix_idi_0_0,
        input   [7:0] pe_matrix_idi_0_1,
        input   [7:0] pe_matrix_idi_0_2,
        input   [7:0] pe_matrix_idi_1_0,
        input   [7:0] pe_matrix_idi_1_1,
        input   [7:0] pe_matrix_idi_1_2,
        input   [7:0] pe_matrix_idi_2_0,
        input   [7:0] pe_matrix_idi_2_1,
        input   [7:0] pe_matrix_idi_2_2,
        
        //Data sel                
        input   [1:0] pe_matrix_isel_0,
        input   [1:0] pe_matrix_isel_1,
        input   [1:0] pe_matrix_isel_2,
        
        //Output                
        output  [31:0] pe_matrix_odo_0_0_0,
        output  [31:0] pe_matrix_odo_0_0_1,
        output  [31:0] pe_matrix_odo_0_0_2,
        output  [31:0] pe_matrix_odo_0_1_0,
        output  [31:0] pe_matrix_odo_0_1_1,
        output  [31:0] pe_matrix_odo_0_1_2,
        output  [31:0] pe_matrix_odo_0_2_0,
        output  [31:0] pe_matrix_odo_0_2_1,
        output  [31:0] pe_matrix_odo_0_2_2,
        output  [31:0] pe_matrix_odo_1_0_0,
        output  [31:0] pe_matrix_odo_1_0_1,
        output  [31:0] pe_matrix_odo_1_0_2,
        output  [31:0] pe_matrix_odo_1_1_0,
        output  [31:0] pe_matrix_odo_1_1_1,
        output  [31:0] pe_matrix_odo_1_1_2,
        output  [31:0] pe_matrix_odo_1_2_0,
        output  [31:0] pe_matrix_odo_1_2_1,
        output  [31:0] pe_matrix_odo_1_2_2,
        output  [31:0] pe_matrix_odo_2_0_0,
        output  [31:0] pe_matrix_odo_2_0_1,
        output  [31:0] pe_matrix_odo_2_0_2,
        output  [31:0] pe_matrix_odo_2_1_0,
        output  [31:0] pe_matrix_odo_2_1_1,
        output  [31:0] pe_matrix_odo_2_1_2,
        output  [31:0] pe_matrix_odo_2_2_0,
        output  [31:0] pe_matrix_odo_2_2_1,
        output  [31:0] pe_matrix_odo_2_2_2,
        
        output ready
        
    );
    
    wire  [7:0] wdemux_to_pe_arr [2:0][2:0][2:0];
    wire  [7:0] idemux_to_pe_arr [2:0][2:0][2:0];

    wire ready_0, ready_1, ready_2;
    assign ready = ready_0 || ready_1 || ready_2; 

    //weight demux
    wi_demux wdemux_0 (
        .demux_di_0(pe_matrix_wdi_0_0), 
        .demux_di_1(pe_matrix_wdi_0_1), 
        .demux_di_2(pe_matrix_wdi_0_2), 
        .demux_do_0_0(wdemux_to_pe_arr[0][0][0]), 
        .demux_do_0_1(wdemux_to_pe_arr[0][0][1]), 
        .demux_do_0_2(wdemux_to_pe_arr[0][0][2]),
        .demux_do_1_0(wdemux_to_pe_arr[1][0][0]), 
        .demux_do_1_1(wdemux_to_pe_arr[1][0][1]), 
        .demux_do_1_2(wdemux_to_pe_arr[1][0][2]),
        .demux_do_2_0(wdemux_to_pe_arr[2][0][0]), 
        .demux_do_2_1(wdemux_to_pe_arr[2][0][1]), 
        .demux_do_2_2(wdemux_to_pe_arr[2][0][2]),
        .demux_sel(pe_matrix_wsel_0)
    );

    wi_demux wdemux_1 (
        .demux_di_0(pe_matrix_wdi_1_0), 
        .demux_di_1(pe_matrix_wdi_1_1), 
        .demux_di_2(pe_matrix_wdi_1_2), 
        .demux_do_0_0(wdemux_to_pe_arr[0][1][0]), 
        .demux_do_0_1(wdemux_to_pe_arr[0][1][1]), 
        .demux_do_0_2(wdemux_to_pe_arr[0][1][2]),
        .demux_do_1_0(wdemux_to_pe_arr[1][1][0]), 
        .demux_do_1_1(wdemux_to_pe_arr[1][1][1]), 
        .demux_do_1_2(wdemux_to_pe_arr[1][1][2]),
        .demux_do_2_0(wdemux_to_pe_arr[2][1][0]), 
        .demux_do_2_1(wdemux_to_pe_arr[2][1][1]), 
        .demux_do_2_2(wdemux_to_pe_arr[2][1][2]),
        .demux_sel(pe_matrix_wsel_1)
    );

    wi_demux wdemux_2 (
        .demux_di_0(pe_matrix_wdi_2_0), 
        .demux_di_1(pe_matrix_wdi_2_1), 
        .demux_di_2(pe_matrix_wdi_2_2), 
        .demux_do_0_0(wdemux_to_pe_arr[0][2][0]), 
        .demux_do_0_1(wdemux_to_pe_arr[0][2][1]), 
        .demux_do_0_2(wdemux_to_pe_arr[0][2][2]),
        .demux_do_1_0(wdemux_to_pe_arr[1][2][0]), 
        .demux_do_1_1(wdemux_to_pe_arr[1][2][1]), 
        .demux_do_1_2(wdemux_to_pe_arr[1][2][2]),
        .demux_do_2_0(wdemux_to_pe_arr[2][2][0]), 
        .demux_do_2_1(wdemux_to_pe_arr[2][2][1]), 
        .demux_do_2_2(wdemux_to_pe_arr[2][2][2]),
        .demux_sel(pe_matrix_wsel_2)
    );

    //input demux
    wi_demux idemux_0 (
        .demux_di_0(pe_matrix_idi_0_0), 
        .demux_di_1(pe_matrix_idi_0_1), 
        .demux_di_2(pe_matrix_idi_0_2),
        .demux_do_0_0(idemux_to_pe_arr[0][0][0]), 
        .demux_do_0_1(idemux_to_pe_arr[0][0][1]), 
        .demux_do_0_2(idemux_to_pe_arr[0][0][2]),
        .demux_do_1_0(idemux_to_pe_arr[0][1][0]), 
        .demux_do_1_1(idemux_to_pe_arr[0][1][1]), 
        .demux_do_1_2(idemux_to_pe_arr[0][1][2]),
        .demux_do_2_0(idemux_to_pe_arr[0][2][0]), 
        .demux_do_2_1(idemux_to_pe_arr[0][2][1]), 
        .demux_do_2_2(idemux_to_pe_arr[0][2][2]),
        .demux_sel(pe_matrix_isel_0)
    );

    wi_demux idemux_1 (
        .demux_di_0(pe_matrix_idi_1_0), 
        .demux_di_1(pe_matrix_idi_1_1), 
        .demux_di_2(pe_matrix_idi_1_2),
        .demux_do_0_0(idemux_to_pe_arr[1][0][0]), 
        .demux_do_0_1(idemux_to_pe_arr[1][0][1]), 
        .demux_do_0_2(idemux_to_pe_arr[1][0][2]),
        .demux_do_1_0(idemux_to_pe_arr[1][1][0]), 
        .demux_do_1_1(idemux_to_pe_arr[1][1][1]), 
        .demux_do_1_2(idemux_to_pe_arr[1][1][2]),
        .demux_do_2_0(idemux_to_pe_arr[1][2][0]), 
        .demux_do_2_1(idemux_to_pe_arr[1][2][1]), 
        .demux_do_2_2(idemux_to_pe_arr[1][2][2]),
        .demux_sel(pe_matrix_isel_1)
    );

    wi_demux idemux_2 (
        .demux_di_0(pe_matrix_idi_2_0), 
        .demux_di_1(pe_matrix_idi_2_1), 
        .demux_di_2(pe_matrix_idi_2_2),
        .demux_do_0_0(idemux_to_pe_arr[2][0][0]), 
        .demux_do_0_1(idemux_to_pe_arr[2][0][1]), 
        .demux_do_0_2(idemux_to_pe_arr[2][0][2]),
        .demux_do_1_0(idemux_to_pe_arr[2][1][0]), 
        .demux_do_1_1(idemux_to_pe_arr[2][1][1]), 
        .demux_do_1_2(idemux_to_pe_arr[2][1][2]),
        .demux_do_2_0(idemux_to_pe_arr[2][2][0]), 
        .demux_do_2_1(idemux_to_pe_arr[2][2][1]), 
        .demux_do_2_2(idemux_to_pe_arr[2][2][2]),
        .demux_sel(pe_matrix_isel_2)
    );
    
    //PE array
    PE_array pe_array_0 (
        .clk(clk), 
        .resetn(resetn),

        .wreg_enb_0_0(pe_matrix_wreg_enb_0_0_0),
        .wreg_enb_0_1(pe_matrix_wreg_enb_0_0_1),
        .wreg_enb_0_2(pe_matrix_wreg_enb_0_0_2),
        .wreg_enb_1_0(pe_matrix_wreg_enb_0_1_0),
        .wreg_enb_1_1(pe_matrix_wreg_enb_0_1_1),
        .wreg_enb_1_2(pe_matrix_wreg_enb_0_1_2),
        .wreg_enb_2_0(pe_matrix_wreg_enb_0_2_0),
        .wreg_enb_2_1(pe_matrix_wreg_enb_0_2_1),
        .wreg_enb_2_2(pe_matrix_wreg_enb_0_2_2),

        .ireg_enb_0(pe_matrix_ireg_enb_0_0),
        .ireg_enb_1(pe_matrix_ireg_enb_0_1),
        .ireg_enb_2(pe_matrix_ireg_enb_0_2),

        .pe_enb_0(pe_enb_0_0),
        .pe_enb_1(pe_enb_0_1),
        .pe_enb_2(pe_enb_0_2),

        .pe_arr_is_conv_layer(matrix_is_conv_layer),
        .pe_arr_conv_dir(matrix_conv_dir),
        .pe_arr_input_offset(matrix_input_offset),

        .pe_arr_wdi_0_0_0(wdemux_to_pe_arr[0][0][0]), 
        .pe_arr_wdi_0_0_1(wdemux_to_pe_arr[0][0][1]), 
        .pe_arr_wdi_0_0_2(wdemux_to_pe_arr[0][0][2]),
        .pe_arr_wdi_0_1_0(wdemux_to_pe_arr[0][1][0]), 
        .pe_arr_wdi_0_1_1(wdemux_to_pe_arr[0][1][1]), 
        .pe_arr_wdi_0_1_2(wdemux_to_pe_arr[0][1][2]),
        .pe_arr_wdi_0_2_0(wdemux_to_pe_arr[0][2][0]), 
        .pe_arr_wdi_0_2_1(wdemux_to_pe_arr[0][2][1]), 
        .pe_arr_wdi_0_2_2(wdemux_to_pe_arr[0][2][2]),

        .pe_arr_wdi_1_0_0(wdemux_to_pe_arr[1][0][0]),
        .pe_arr_wdi_1_0_1(wdemux_to_pe_arr[1][0][1]),
        .pe_arr_wdi_1_0_2(wdemux_to_pe_arr[1][0][2]),
        .pe_arr_wdi_1_1_0(wdemux_to_pe_arr[1][1][0]), 
        .pe_arr_wdi_1_1_1(wdemux_to_pe_arr[1][1][1]), 
        .pe_arr_wdi_1_1_2(wdemux_to_pe_arr[1][1][2]),
        .pe_arr_wdi_1_2_0(wdemux_to_pe_arr[1][2][0]), 
        .pe_arr_wdi_1_2_1(wdemux_to_pe_arr[1][2][1]), 
        .pe_arr_wdi_1_2_2(wdemux_to_pe_arr[1][2][2]),

        .pe_arr_wdi_2_0_0(wdemux_to_pe_arr[2][0][0]), 
        .pe_arr_wdi_2_0_1(wdemux_to_pe_arr[2][0][1]), 
        .pe_arr_wdi_2_0_2(wdemux_to_pe_arr[2][0][2]),
        .pe_arr_wdi_2_1_0(wdemux_to_pe_arr[2][1][0]), 
        .pe_arr_wdi_2_1_1(wdemux_to_pe_arr[2][1][1]), 
        .pe_arr_wdi_2_1_2(wdemux_to_pe_arr[2][1][2]),
        .pe_arr_wdi_2_2_0(wdemux_to_pe_arr[2][2][0]), 
        .pe_arr_wdi_2_2_1(wdemux_to_pe_arr[2][2][1]), 
        .pe_arr_wdi_2_2_2(wdemux_to_pe_arr[2][2][2]),
          
        .pe_arr_idi_0_0(idemux_to_pe_arr[0][0][0]),
        .pe_arr_idi_0_1(idemux_to_pe_arr[0][0][1]),
        .pe_arr_idi_0_2(idemux_to_pe_arr[0][0][2]),
        .pe_arr_idi_1_0(idemux_to_pe_arr[0][1][0]),
        .pe_arr_idi_1_1(idemux_to_pe_arr[0][1][1]),
        .pe_arr_idi_1_2(idemux_to_pe_arr[0][1][2]),
        .pe_arr_idi_2_0(idemux_to_pe_arr[0][2][0]),
        .pe_arr_idi_2_1(idemux_to_pe_arr[0][2][1]),
        .pe_arr_idi_2_2(idemux_to_pe_arr[0][2][2]),

        .pe_arr_odo_0_0(pe_matrix_odo_0_0_0), 
        .pe_arr_odo_0_1(pe_matrix_odo_0_0_1), 
        .pe_arr_odo_0_2(pe_matrix_odo_0_0_2),
        .pe_arr_odo_1_0(pe_matrix_odo_0_1_0), 
        .pe_arr_odo_1_1(pe_matrix_odo_0_1_1), 
        .pe_arr_odo_1_2(pe_matrix_odo_0_1_2),
        .pe_arr_odo_2_0(pe_matrix_odo_0_2_0), 
        .pe_arr_odo_2_1(pe_matrix_odo_0_2_1), 
        .pe_arr_odo_2_2(pe_matrix_odo_0_2_2),
        
        .ready(ready_0)
    );
    
    PE_array pe_array_1(
        .clk(clk), 
        .resetn(resetn),

        .wreg_enb_0_0(pe_matrix_wreg_enb_1_0_0),
        .wreg_enb_0_1(pe_matrix_wreg_enb_1_0_1),
        .wreg_enb_0_2(pe_matrix_wreg_enb_1_0_2),
        .wreg_enb_1_0(pe_matrix_wreg_enb_1_1_0),
        .wreg_enb_1_1(pe_matrix_wreg_enb_1_1_1),
        .wreg_enb_1_2(pe_matrix_wreg_enb_1_1_2),
        .wreg_enb_2_0(pe_matrix_wreg_enb_1_2_0),
        .wreg_enb_2_1(pe_matrix_wreg_enb_1_2_1),
        .wreg_enb_2_2(pe_matrix_wreg_enb_1_2_2),

        .ireg_enb_0(pe_matrix_ireg_enb_1_0),
        .ireg_enb_1(pe_matrix_ireg_enb_1_1),
        .ireg_enb_2(pe_matrix_ireg_enb_1_2),

        .pe_enb_0(pe_enb_1_0),
        .pe_enb_1(pe_enb_1_1),
        .pe_enb_2(pe_enb_1_2),
        
        .pe_arr_is_conv_layer(matrix_is_conv_layer),
        .pe_arr_conv_dir(matrix_conv_dir),
        .pe_arr_input_offset(matrix_input_offset),

        .pe_arr_wdi_0_0_0(wdemux_to_pe_arr[0][0][0]), 
        .pe_arr_wdi_0_0_1(wdemux_to_pe_arr[0][0][1]), 
        .pe_arr_wdi_0_0_2(wdemux_to_pe_arr[0][0][2]),
        .pe_arr_wdi_0_1_0(wdemux_to_pe_arr[0][1][0]), 
        .pe_arr_wdi_0_1_1(wdemux_to_pe_arr[0][1][1]), 
        .pe_arr_wdi_0_1_2(wdemux_to_pe_arr[0][1][2]),
        .pe_arr_wdi_0_2_0(wdemux_to_pe_arr[0][2][0]), 
        .pe_arr_wdi_0_2_1(wdemux_to_pe_arr[0][2][1]), 
        .pe_arr_wdi_0_2_2(wdemux_to_pe_arr[0][2][2]),
                                                                                                                                 
        .pe_arr_wdi_1_0_0(wdemux_to_pe_arr[1][0][0]), 
        .pe_arr_wdi_1_0_1(wdemux_to_pe_arr[1][0][1]), 
        .pe_arr_wdi_1_0_2(wdemux_to_pe_arr[1][0][2]),
        .pe_arr_wdi_1_1_0(wdemux_to_pe_arr[1][1][0]), 
        .pe_arr_wdi_1_1_1(wdemux_to_pe_arr[1][1][1]), 
        .pe_arr_wdi_1_1_2(wdemux_to_pe_arr[1][1][2]),
        .pe_arr_wdi_1_2_0(wdemux_to_pe_arr[1][2][0]), 
        .pe_arr_wdi_1_2_1(wdemux_to_pe_arr[1][2][1]), 
        .pe_arr_wdi_1_2_2(wdemux_to_pe_arr[1][2][2]),
                                                                                                                                 
        .pe_arr_wdi_2_0_0(wdemux_to_pe_arr[2][0][0]), 
        .pe_arr_wdi_2_0_1(wdemux_to_pe_arr[2][0][1]), 
        .pe_arr_wdi_2_0_2(wdemux_to_pe_arr[2][0][2]),
        .pe_arr_wdi_2_1_0(wdemux_to_pe_arr[2][1][0]), 
        .pe_arr_wdi_2_1_1(wdemux_to_pe_arr[2][1][1]), 
        .pe_arr_wdi_2_1_2(wdemux_to_pe_arr[2][1][2]),
        .pe_arr_wdi_2_2_0(wdemux_to_pe_arr[2][2][0]), 
        .pe_arr_wdi_2_2_1(wdemux_to_pe_arr[2][2][1]), 
        .pe_arr_wdi_2_2_2(wdemux_to_pe_arr[2][2][2]),
          
        .pe_arr_idi_0_0(idemux_to_pe_arr[1][0][0]), 
        .pe_arr_idi_0_1(idemux_to_pe_arr[1][0][1]), 
        .pe_arr_idi_0_2(idemux_to_pe_arr[1][0][2]),
        .pe_arr_idi_1_0(idemux_to_pe_arr[1][1][0]), 
        .pe_arr_idi_1_1(idemux_to_pe_arr[1][1][1]), 
        .pe_arr_idi_1_2(idemux_to_pe_arr[1][1][2]),
        .pe_arr_idi_2_0(idemux_to_pe_arr[1][2][0]), 
        .pe_arr_idi_2_1(idemux_to_pe_arr[1][2][1]), 
        .pe_arr_idi_2_2(idemux_to_pe_arr[1][2][2]),

        .pe_arr_odo_0_0(pe_matrix_odo_1_0_0), 
        .pe_arr_odo_0_1(pe_matrix_odo_1_0_1), 
        .pe_arr_odo_0_2(pe_matrix_odo_1_0_2),
        .pe_arr_odo_1_0(pe_matrix_odo_1_1_0), 
        .pe_arr_odo_1_1(pe_matrix_odo_1_1_1), 
        .pe_arr_odo_1_2(pe_matrix_odo_1_1_2),
        .pe_arr_odo_2_0(pe_matrix_odo_1_2_0), 
        .pe_arr_odo_2_1(pe_matrix_odo_1_2_1), 
        .pe_arr_odo_2_2(pe_matrix_odo_1_2_2),
        
        .ready(ready_1)
    );
    
    PE_array pe_array_2 (
        .clk(clk), 
        .resetn(resetn),
        
        .wreg_enb_0_0(pe_matrix_wreg_enb_2_0_0),
        .wreg_enb_0_1(pe_matrix_wreg_enb_2_0_1),
        .wreg_enb_0_2(pe_matrix_wreg_enb_2_0_2),
        .wreg_enb_1_0(pe_matrix_wreg_enb_2_1_0),
        .wreg_enb_1_1(pe_matrix_wreg_enb_2_1_1),
        .wreg_enb_1_2(pe_matrix_wreg_enb_2_1_2),
        .wreg_enb_2_0(pe_matrix_wreg_enb_2_2_0),
        .wreg_enb_2_1(pe_matrix_wreg_enb_2_2_1),
        .wreg_enb_2_2(pe_matrix_wreg_enb_2_2_2),

        .ireg_enb_0(pe_matrix_ireg_enb_2_0),
        .ireg_enb_1(pe_matrix_ireg_enb_2_1),
        .ireg_enb_2(pe_matrix_ireg_enb_2_2),

        .pe_enb_0(pe_enb_2_0),
        .pe_enb_1(pe_enb_2_1),
        .pe_enb_2(pe_enb_2_2),
        
        .pe_arr_is_conv_layer(matrix_is_conv_layer),
        .pe_arr_conv_dir(matrix_conv_dir),
        .pe_arr_input_offset(matrix_input_offset),

        .pe_arr_wdi_0_0_0(wdemux_to_pe_arr[0][0][0]), 
        .pe_arr_wdi_0_0_1(wdemux_to_pe_arr[0][0][1]), 
        .pe_arr_wdi_0_0_2(wdemux_to_pe_arr[0][0][2]),
        .pe_arr_wdi_0_1_0(wdemux_to_pe_arr[0][1][0]), 
        .pe_arr_wdi_0_1_1(wdemux_to_pe_arr[0][1][1]), 
        .pe_arr_wdi_0_1_2(wdemux_to_pe_arr[0][1][2]),
        .pe_arr_wdi_0_2_0(wdemux_to_pe_arr[0][2][0]), 
        .pe_arr_wdi_0_2_1(wdemux_to_pe_arr[0][2][1]), 
        .pe_arr_wdi_0_2_2(wdemux_to_pe_arr[0][2][2]),
                                                                                                                                 
        .pe_arr_wdi_1_0_0(wdemux_to_pe_arr[1][0][0]), 
        .pe_arr_wdi_1_0_1(wdemux_to_pe_arr[1][0][1]), 
        .pe_arr_wdi_1_0_2(wdemux_to_pe_arr[1][0][2]),
        .pe_arr_wdi_1_1_0(wdemux_to_pe_arr[1][1][0]), 
        .pe_arr_wdi_1_1_1(wdemux_to_pe_arr[1][1][1]), 
        .pe_arr_wdi_1_1_2(wdemux_to_pe_arr[1][1][2]),
        .pe_arr_wdi_1_2_0(wdemux_to_pe_arr[1][2][0]), 
        .pe_arr_wdi_1_2_1(wdemux_to_pe_arr[1][2][1]), 
        .pe_arr_wdi_1_2_2(wdemux_to_pe_arr[1][2][2]),
                                                                                                                                 
        .pe_arr_wdi_2_0_0(wdemux_to_pe_arr[2][0][0]), 
        .pe_arr_wdi_2_0_1(wdemux_to_pe_arr[2][0][1]), 
        .pe_arr_wdi_2_0_2(wdemux_to_pe_arr[2][0][2]),
        .pe_arr_wdi_2_1_0(wdemux_to_pe_arr[2][1][0]), 
        .pe_arr_wdi_2_1_1(wdemux_to_pe_arr[2][1][1]), 
        .pe_arr_wdi_2_1_2(wdemux_to_pe_arr[2][1][2]),
        .pe_arr_wdi_2_2_0(wdemux_to_pe_arr[2][2][0]), 
        .pe_arr_wdi_2_2_1(wdemux_to_pe_arr[2][2][1]), 
        .pe_arr_wdi_2_2_2(wdemux_to_pe_arr[2][2][2]),
          
        .pe_arr_idi_0_0(idemux_to_pe_arr[2][0][0]), 
        .pe_arr_idi_0_1(idemux_to_pe_arr[2][0][1]), 
        .pe_arr_idi_0_2(idemux_to_pe_arr[2][0][2]),
        .pe_arr_idi_1_0(idemux_to_pe_arr[2][1][0]), 
        .pe_arr_idi_1_1(idemux_to_pe_arr[2][1][1]), 
        .pe_arr_idi_1_2(idemux_to_pe_arr[2][1][2]),
        .pe_arr_idi_2_0(idemux_to_pe_arr[2][2][0]), 
        .pe_arr_idi_2_1(idemux_to_pe_arr[2][2][1]), 
        .pe_arr_idi_2_2(idemux_to_pe_arr[2][2][2]),

        .pe_arr_odo_0_0(pe_matrix_odo_2_0_0), 
        .pe_arr_odo_0_1(pe_matrix_odo_2_0_1), 
        .pe_arr_odo_0_2(pe_matrix_odo_2_0_2),
        .pe_arr_odo_1_0(pe_matrix_odo_2_1_0), 
        .pe_arr_odo_1_1(pe_matrix_odo_2_1_1), 
        .pe_arr_odo_1_2(pe_matrix_odo_2_1_2),
        .pe_arr_odo_2_0(pe_matrix_odo_2_2_0), 
        .pe_arr_odo_2_1(pe_matrix_odo_2_2_1), 
        .pe_arr_odo_2_2(pe_matrix_odo_2_2_2),
        
        .ready(ready_2)
    );
    
endmodule
