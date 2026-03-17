`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 09:14:35 PM
// Design Name: 
// Module Name: main_accel
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


module main_accel(
        input clk,
        input reset,
        input enb,

        input accel_cfgreg_write_enb,
        input [31:0] accel_Cfgreg_di,
        input [4:0] accel_cfg_reg_sel,

        input [31:0] accel_read_data,
        input accel_mem_read_ready,
        input accel_mem_write_ready,

        input accel_ctrl_enb,
        input accel_ctrl_reset,

        output accel_read_enb,
        output [31:0] accel_read_addr,
        output [31:0] accel_write_data,
        output [31:0] accel_write_addr,
        output [3:0] accel_wstrb,
        output accel_write_enb,

        output accel_done
    );

    localparam CONV = 4'd0,
               POOLING = 4'd1,
               DENSE = 4'd2;

    wire is_conv_layer;
    wire [3:0] o_quant_sel;
    wire flow_ctrl_out_done;

    //input sigs
    wire [7:0] ibuf0_do_0, ibuf0_do_1, ibuf0_do_2,
               ibuf1_do_0, ibuf1_do_1, ibuf1_do_2,
               ibuf2_do_0, ibuf2_do_1, ibuf2_do_2;

    wire [2:0] ibuf0_valid, ibuf1_valid, ibuf2_valid,
               ibuf0_valid_next, ibuf1_valid_next, ibuf2_valid_next;

    wire ibuf0_di_reverse, ibuf1_di_reverse, ibuf2_di_reverse,
         ibuf0_do_reverse, ibuf1_do_reverse, ibuf2_do_reverse;

    wire [1:0] ibuf0_bank_sel, ibuf1_bank_sel, ibuf2_bank_sel;
    wire ibuf0_ld, ibuf1_ld, ibuf2_ld;
    wire ibuf0_enb, ibuf1_enb, ibuf2_enb; 

    wire ibuf_conv_fi_load, ibuf_conv_se_load;

    wire [2:0] ibuf_conv_wstrb;
    wire [1:0] ibuf_dense_wstrb;

    //weight sigs
    wire [7:0] wbuf0_do_0, wbuf0_do_1, wbuf0_do_2,
               wbuf1_do_0, wbuf1_do_1, wbuf1_do_2,
               wbuf2_do_0, wbuf2_do_1, wbuf2_do_2;

    wire [1:0] wbuf0_bank_sel, wbuf1_bank_sel, wbuf2_bank_sel;
    wire wbuf0_ld, wbuf1_ld, wbuf2_ld;
    wire wbuf0_enb, wbuf1_enb, wbuf2_enb; 

    wire [1:0] wbuf0_wstrb, wbuf1_wstrb, wbuf2_wstrb;

    //bias sigs
        wire [31:0] bpbuf0_do, bpbuf1_do, bpbuf2_do;
    wire bpbuf0_ld, bpbuf1_ld, bpbuf2_ld;
    wire bpbuf0_enb, bpbuf1_enb, bpbuf2_enb;

    //matrix sigs
    wire [1:0] pe_matrix_isel, pe_matrix_wsel;
    wire [31:0] pe_matrix_odo0_0_0, pe_matrix_odo0_0_1, pe_matrix_odo0_0_2,
                pe_matrix_odo0_1_0, pe_matrix_odo0_1_1, pe_matrix_odo0_1_2,
                pe_matrix_odo0_2_0, pe_matrix_odo0_2_1, pe_matrix_odo0_2_2,
                pe_matrix_odo1_0_0, pe_matrix_odo1_0_1, pe_matrix_odo1_0_2,
                pe_matrix_odo1_1_0, pe_matrix_odo1_1_1, pe_matrix_odo1_1_2,
                pe_matrix_odo1_2_0, pe_matrix_odo1_2_1, pe_matrix_odo1_2_2,
                pe_matrix_odo2_0_0, pe_matrix_odo2_0_1, pe_matrix_odo2_0_2,
                pe_matrix_odo2_1_0, pe_matrix_odo2_1_1, pe_matrix_odo2_1_2,
                pe_matrix_odo2_2_0, pe_matrix_odo2_2_1, pe_matrix_odo2_2_2;

    wire pe_matrix_ready;
    wire [1:0] pe_matrix_conv_dir;

    wire ireg_enb0_0, ireg_enb0_1, ireg_enb0_2,
         ireg_enb1_0, ireg_enb1_1, ireg_enb1_2,
         ireg_enb2_0, ireg_enb2_1, ireg_enb2_2;

    wire wreg_enb0_0_0, wreg_enb0_0_1, wreg_enb0_0_2,
         wreg_enb0_1_0, wreg_enb0_1_1, wreg_enb0_1_2,
         wreg_enb0_2_0, wreg_enb0_2_1, wreg_enb0_2_2,
         wreg_enb1_0_0, wreg_enb1_0_1, wreg_enb1_0_2,
         wreg_enb1_1_0, wreg_enb1_1_1, wreg_enb1_1_2,
         wreg_enb1_2_0, wreg_enb1_2_1, wreg_enb1_2_2,
         wreg_enb2_0_0, wreg_enb2_0_1, wreg_enb2_0_2,
         wreg_enb2_1_0, wreg_enb2_1_1, wreg_enb2_1_2,
         wreg_enb2_2_0, wreg_enb2_2_1, wreg_enb2_2_2;

    wire pe_enb0_0, pe_enb0_1, pe_enb0_2,
         pe_enb1_0, pe_enb1_1, pe_enb1_2,
         pe_enb2_0, pe_enb2_1, pe_enb2_2;

    wire [31:0] acc_matrix_do0, acc_matrix_do1, acc_matrix_do2;
    wire acc_matrix_enb0, acc_matrix_enb1;
    wire acc_matrix_bp_write, acc_matrix_bp_ld;
    wire acc_matrix_sum_write;

    wire obuf0_ld, obuf1_ld, obuf2_ld;
    wire obuf0_enb, obuf1_enb, obuf2_enb;
    wire [31:0] obuf0_di, obuf1_di, obuf2_di;
    wire [31:0] obuf0_do, obuf1_do, obuf2_do;

    wire [7:0] elew_do1;
    wire [7:0] elew_do0_0, elew_do0_1, elew_do0_2;

    wire compare_enb, compare_clear;

    wire quant_act_func_enb0, quant_act_func_enb1, quant_act_func_enb2;
    wire quant_act_func_ready0, quant_act_func_ready1, quant_act_func_ready2;

    wire [31:0] i_base_addr;
    wire [31:0] kw_base_addr;
    wire [31:0] o_base_addr;
    wire [31:0] bp_base_addr;
    wire [31:0] ps_base_addr;

    wire [3:0] cfg_layer_type;
    wire [3:0] cfg_act_func_type;
    wire [3:0] w_stride, h_stride;
    wire [15:0] weight_kernel_height, weight_kernel_width;
    wire [15:0] kernel_ifm_depth;
    wire [15:0] out_total_kernel_ofm_depth;
    wire [15:0] w_ifm, h_ifm;
    wire [15:0] w_ofm, h_ofm;
    wire [15:0] input2D_size;
    wire [15:0] output2D_size;
    wire [31:0] kernel3D_size;

    wire [31:0] output_mult0, output_mult1, output_mult2;
    wire [31:0] output_shift0, output_shift1, output_shift2; 
    wire [31:0] input_offset, output_offset;

    wire accel_write_enb0, accel_write_enb1, accel_write_enb2;
    assign accel_write_enb = accel_write_enb0 || accel_write_enb1 || accel_write_enb2;

    assign accel_write_data = accel_write_enb0 ? obuf0_do :
                              accel_write_enb1 ? obuf1_do :
                              accel_write_enb2 ? obuf2_do : 0;

    assign obuf0_di = flow_ctrl_out_done ?
                      {4{(cfg_layer_type == POOLING) ? elew_do1 : elew_do0_0}} : acc_matrix_do0;
    assign obuf1_di = flow_ctrl_out_done ?
                      {4{(cfg_layer_type == POOLING) ? elew_do1 : elew_do0_1}} : acc_matrix_do1;
    assign obuf2_di = flow_ctrl_out_done ?
                      {4{(cfg_layer_type == POOLING) ? elew_do1 : elew_do0_2}} : acc_matrix_do2;

    //instantiate submodules
    //bias/partial sum buffers
    bias_point_buf bpbuf0(
        .clk(clk),
        .enb(bpbuf0_enb && accel_ctrl_enb),
        .reset(reset && accel_ctrl_reset),

        .bpbuf_ld(bpbuf0_ld),
        .bpbuf_di(accel_read_data),
        .bpbuf_do(bpbuf0_do)
    );

    bias_point_buf bpbuf1(
        .clk(clk),
        .enb(bpbuf1_enb && accel_ctrl_enb),
        .reset(reset && accel_ctrl_reset),

        .bpbuf_ld(bpbuf1_ld),
        .bpbuf_di(accel_read_data),
        .bpbuf_do(bpbuf1_do)
    );

    bias_point_buf bpbuf2(
        .clk(clk),
        .enb(bpbuf2_enb && accel_ctrl_enb),
        .reset(reset && accel_ctrl_reset),

        .bpbuf_ld(bpbuf2_ld),
        .bpbuf_di(accel_read_data),
        .bpbuf_do(bpbuf2_do)
    );

    //input buffers
    input_buf ibuf0(
        .clk(clk),
        .enb(ibuf0_enb && accel_ctrl_enb),
        .reset(reset && accel_ctrl_reset),

        .cfg_layer_type(cfg_layer_type),
        .ibuf_dense_wstrb(ibuf_dense_wstrb),
        .ibuf_conv_wstrb(ibuf_conv_wstrb),

        .ibuf_di_reverse(ibuf0_di_reverse),
        .ibuf_do_reverse(ibuf0_do_reverse),
        .ibuf_ld(ibuf0_ld),
        .ibuf_bank_sel(ibuf0_bank_sel),

        .ibuf_conv_fi_load(ibuf_conv_fi_load),
        .ibuf_conv_se_load(ibuf_conv_se_load),

        .ibuf_di(accel_read_data),

        .ibuf_do_0(ibuf0_do_0),
        .ibuf_do_1(ibuf0_do_1),
        .ibuf_do_2(ibuf0_do_2),

        .ibuf_valid(ibuf0_valid),
        .ibuf_nxt_valid(ibuf0_valid_next)
    );

    input_buf ibuf1(
        .clk(clk),
        .enb(ibuf1_enb && accel_ctrl_enb),
        .reset(reset && accel_ctrl_reset),

        .cfg_layer_type(cfg_layer_type),
        .ibuf_dense_wstrb(ibuf_dense_wstrb),
        .ibuf_conv_wstrb(ibuf_conv_wstrb),

        .ibuf_di_reverse(ibuf1_di_reverse),
        .ibuf_do_reverse(ibuf1_do_reverse),
        .ibuf_ld(ibuf1_ld),
        .ibuf_bank_sel(ibuf1_bank_sel),

        .ibuf_conv_fi_load(ibuf_conv_fi_load),
        .ibuf_conv_se_load(ibuf_conv_se_load),

        .ibuf_di(accel_read_data),

        .ibuf_do_0(ibuf1_do_0),
        .ibuf_do_1(ibuf1_do_1),
        .ibuf_do_2(ibuf1_do_2),

        .ibuf_valid(ibuf1_valid),
        .ibuf_nxt_valid(ibuf1_valid_next)
    );

    input_buf ibuf2(
        .clk(clk),
        .enb(ibuf2_enb && accel_ctrl_enb),
        .reset(reset && accel_ctrl_reset),

        .cfg_layer_type(cfg_layer_type),
        .ibuf_dense_wstrb(ibuf_dense_wstrb),
        .ibuf_conv_wstrb(ibuf_conv_wstrb),

        .ibuf_di_reverse(ibuf2_di_reverse),
        .ibuf_do_reverse(ibuf2_do_reverse),
        .ibuf_ld(ibuf2_ld),
        .ibuf_bank_sel(ibuf2_bank_sel),

        .ibuf_conv_fi_load(ibuf_conv_fi_load),
        .ibuf_conv_se_load(ibuf_conv_se_load),

        .ibuf_di(accel_read_data),

        .ibuf_do_0(ibuf2_do_0),
        .ibuf_do_1(ibuf2_do_1),
        .ibuf_do_2(ibuf2_do_2),

        .ibuf_valid(ibuf2_valid),
        .ibuf_nxt_valid(ibuf2_valid_next)
    );

    //weight buffers
    weight_buf wbuf0(
        .clk(clk),
        .reset(reset && accel_ctrl_reset),
        .enb(wbuf0_enb && accel_ctrl_enb),

        .wbuf_di(accel_read_data),
        .wbuf_bank_sel(wbuf0_bank_sel),
        .wbuf_wstrb(wbuf0_wstrb),
        .wbuf_ld(wbuf0_ld),

        .wbuf_do_0(wbuf0_do_0),
        .wbuf_do_1(wbuf0_do_1),
        .wbuf_do_2(wbuf0_do_2)
    );

    weight_buf wbuf1(
        .clk(clk),
        .reset(reset && accel_ctrl_reset),
        .enb(wbuf1_enb && accel_ctrl_enb),

        .wbuf_di(accel_read_data),
        .wbuf_bank_sel(wbuf1_bank_sel),
        .wbuf_wstrb(wbuf1_wstrb),
        .wbuf_ld(wbuf1_ld),

        .wbuf_do_0(wbuf1_do_0),
        .wbuf_do_1(wbuf1_do_1),
        .wbuf_do_2(wbuf1_do_2)
    );

    weight_buf wbuf2(
        .clk(clk),
        .reset(reset && accel_ctrl_reset),
        .enb(wbuf2_enb && accel_ctrl_enb),

        .wbuf_di(accel_read_data),
        .wbuf_bank_sel(wbuf2_bank_sel),
        .wbuf_wstrb(wbuf2_wstrb),
        .wbuf_ld(wbuf2_ld),

        .wbuf_do_0(wbuf2_do_0),
        .wbuf_do_1(wbuf2_do_1),
        .wbuf_do_2(wbuf2_do_2)
    );

    //computation matrix
    PE_matrix pe_matrix (
        .clk(clk),
        .reset(reset && accel_ctrl_reset),
        .matrix_is_conv_layer(cfg_layer_type == CONV),
        .matrix_conv_dir(pe_matrix_conv_dir),
        .matrix_input_offset(input_offset),

        .pe_matrix_wreg_enb_0_0_0(wreg_enb0_0_0 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_0_0_1(wreg_enb0_0_1 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_0_0_2(wreg_enb0_0_2 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_0_1_0(wreg_enb0_1_0 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_0_1_1(wreg_enb0_1_1 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_0_1_2(wreg_enb0_1_2 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_0_2_0(wreg_enb0_2_0 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_0_2_1(wreg_enb0_2_1 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_0_2_2(wreg_enb0_2_2 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_1_0_0(wreg_enb1_0_0 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_1_0_1(wreg_enb1_0_1 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_1_0_2(wreg_enb1_0_2 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_1_1_0(wreg_enb1_1_0 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_1_1_1(wreg_enb1_1_1 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_1_1_2(wreg_enb1_1_2 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_1_2_0(wreg_enb1_2_0 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_1_2_1(wreg_enb1_2_1 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_1_2_2(wreg_enb1_2_2 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_2_0_0(wreg_enb2_0_0 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_2_0_1(wreg_enb2_0_1 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_2_0_2(wreg_enb2_0_2 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_2_1_0(wreg_enb2_1_0 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_2_1_1(wreg_enb2_1_1 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_2_1_2(wreg_enb2_1_2 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_2_2_0(wreg_enb2_2_0 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_2_2_1(wreg_enb2_2_1 && accel_ctrl_enb),
        .pe_matrix_wreg_enb_2_2_2(wreg_enb2_2_2 && accel_ctrl_enb),

        .pe_matrix_ireg_enb_0_0(ireg_enb0_0 && accel_ctrl_enb),
        .pe_matrix_ireg_enb_0_1(ireg_enb0_1 && accel_ctrl_enb),
        .pe_matrix_ireg_enb_0_2(ireg_enb0_2 && accel_ctrl_enb),
        .pe_matrix_ireg_enb_1_0(ireg_enb1_0 && accel_ctrl_enb),
        .pe_matrix_ireg_enb_1_1(ireg_enb1_1 && accel_ctrl_enb),
        .pe_matrix_ireg_enb_1_2(ireg_enb1_2 && accel_ctrl_enb),
        .pe_matrix_ireg_enb_2_0(ireg_enb2_0 && accel_ctrl_enb),
        .pe_matrix_ireg_enb_2_1(ireg_enb2_1 && accel_ctrl_enb),
        .pe_matrix_ireg_enb_2_2(ireg_enb2_2 && accel_ctrl_enb),

        .pe_enb_0_0(pe_enb0_0 && accel_ctrl_enb),
        .pe_enb_0_1(pe_enb0_1 && accel_ctrl_enb),
        .pe_enb_0_2(pe_enb0_2 && accel_ctrl_enb),
        .pe_enb_1_0(pe_enb1_0 && accel_ctrl_enb),
        .pe_enb_1_1(pe_enb1_1 && accel_ctrl_enb),
        .pe_enb_1_2(pe_enb1_2 && accel_ctrl_enb),
        .pe_enb_2_0(pe_enb2_0 && accel_ctrl_enb),
        .pe_enb_2_1(pe_enb2_1 && accel_ctrl_enb),
        .pe_enb_2_2(pe_enb2_2 && accel_ctrl_enb),

        .pe_matrix_wdi_0_0(wbuf0_do_0),
        .pe_matrix_wdi_0_1(wbuf0_do_1),
        .pe_matrix_wdi_0_2(wbuf0_do_2),
        .pe_matrix_wdi_1_0(wbuf1_do_0),
        .pe_matrix_wdi_1_1(wbuf1_do_1),
        .pe_matrix_wdi_1_2(wbuf1_do_2),
        .pe_matrix_wdi_2_0(wbuf2_do_0),
        .pe_matrix_wdi_2_1(wbuf2_do_1),
        .pe_matrix_wdi_2_2(wbuf2_do_2),

        .pe_matrix_wsel_0(pe_matrix_wsel),
        .pe_matrix_wsel_1(pe_matrix_wsel),
        .pe_matrix_wsel_2(pe_matrix_wsel),

        .pe_matrix_idi_0_0(ibuf0_do_0),
        .pe_matrix_idi_0_1(ibuf0_do_1),
        .pe_matrix_idi_0_2(ibuf0_do_2),
        .pe_matrix_idi_1_0(ibuf1_do_0),
        .pe_matrix_idi_1_1(ibuf1_do_1),
        .pe_matrix_idi_1_2(ibuf1_do_2),
        .pe_matrix_idi_2_0(ibuf2_do_0),
        .pe_matrix_idi_2_1(ibuf2_do_1),
        .pe_matrix_idi_2_2(ibuf2_do_2),

        .pe_matrix_isel_0(pe_matrix_isel),
        .pe_matrix_isel_1(pe_matrix_isel),
        .pe_matrix_isel_2(pe_matrix_isel),

        .pe_matrix_odo_0_0_0(pe_matrix_odo0_0_0),
        .pe_matrix_odo_0_0_1(pe_matrix_odo0_0_1),
        .pe_matrix_odo_0_0_2(pe_matrix_odo0_0_2),
        .pe_matrix_odo_0_1_0(pe_matrix_odo0_1_0),
        .pe_matrix_odo_0_1_1(pe_matrix_odo0_1_1),
        .pe_matrix_odo_0_1_2(pe_matrix_odo0_1_2),
        .pe_matrix_odo_0_2_0(pe_matrix_odo0_2_0),
        .pe_matrix_odo_0_2_1(pe_matrix_odo0_2_1),
        .pe_matrix_odo_0_2_2(pe_matrix_odo0_2_2),
        .pe_matrix_odo_1_0_0(pe_matrix_odo1_0_0),
        .pe_matrix_odo_1_0_1(pe_matrix_odo1_0_1),
        .pe_matrix_odo_1_0_2(pe_matrix_odo1_0_2),
        .pe_matrix_odo_1_1_0(pe_matrix_odo1_1_0),
        .pe_matrix_odo_1_1_1(pe_matrix_odo1_1_1),
        .pe_matrix_odo_1_1_2(pe_matrix_odo1_1_2),
        .pe_matrix_odo_1_2_0(pe_matrix_odo1_2_0),
        .pe_matrix_odo_1_2_1(pe_matrix_odo1_2_1),
        .pe_matrix_odo_1_2_2(pe_matrix_odo1_2_2),
        .pe_matrix_odo_2_0_0(pe_matrix_odo2_0_0),
        .pe_matrix_odo_2_0_1(pe_matrix_odo2_0_1),
        .pe_matrix_odo_2_0_2(pe_matrix_odo2_0_2),
        .pe_matrix_odo_2_1_0(pe_matrix_odo2_1_0),
        .pe_matrix_odo_2_1_1(pe_matrix_odo2_1_1),
        .pe_matrix_odo_2_1_2(pe_matrix_odo2_1_2),
        .pe_matrix_odo_2_2_0(pe_matrix_odo2_2_0),
        .pe_matrix_odo_2_2_1(pe_matrix_odo2_2_1),
        .pe_matrix_odo_2_2_2(pe_matrix_odo2_2_2),

        .valid(pe_matrix_ready)
    );

    //accumulate matrix
    acc_matrix acc_matrix(
        .clk(clk),
        .reset(reset && accel_ctrl_reset),
        .enb((acc_matrix_enb0 || acc_matrix_enb1) && accel_ctrl_enb),

        .acc_matrix_bps_load(acc_matrix_bp_ld),
        .acc_matrix_bps_write(acc_matrix_bp_write),
        .acc_matrix_inter_sum_write(acc_matrix_sum_write),

        .acc_matrix_bps_0(bpbuf0_do),
        .acc_matrix_bps_1(bpbuf1_do),
        .acc_matrix_bps_2(bpbuf2_do),

        .acc_matrix_di_0_0_0(pe_matrix_odo0_0_0),
        .acc_matrix_di_0_0_1(pe_matrix_odo0_0_1),
        .acc_matrix_di_0_0_2(pe_matrix_odo0_0_2),
        .acc_matrix_di_0_1_0(pe_matrix_odo0_1_0),
        .acc_matrix_di_0_1_1(pe_matrix_odo0_1_1),
        .acc_matrix_di_0_1_2(pe_matrix_odo0_1_2),
        .acc_matrix_di_0_2_0(pe_matrix_odo0_2_0),
        .acc_matrix_di_0_2_1(pe_matrix_odo0_2_1),
        .acc_matrix_di_0_2_2(pe_matrix_odo0_2_2),
        .acc_matrix_di_1_0_0(pe_matrix_odo1_0_0),
        .acc_matrix_di_1_0_1(pe_matrix_odo1_0_1),
        .acc_matrix_di_1_0_2(pe_matrix_odo1_0_2),
        .acc_matrix_di_1_1_0(pe_matrix_odo1_1_0),
        .acc_matrix_di_1_1_1(pe_matrix_odo1_1_1),
        .acc_matrix_di_1_1_2(pe_matrix_odo1_1_2),
        .acc_matrix_di_1_2_0(pe_matrix_odo1_2_0),
        .acc_matrix_di_1_2_1(pe_matrix_odo1_2_1),
        .acc_matrix_di_1_2_2(pe_matrix_odo1_2_2),
        .acc_matrix_di_2_0_0(pe_matrix_odo2_0_0),
        .acc_matrix_di_2_0_1(pe_matrix_odo2_0_1),
        .acc_matrix_di_2_0_2(pe_matrix_odo2_0_2),
        .acc_matrix_di_2_1_0(pe_matrix_odo2_1_0),
        .acc_matrix_di_2_1_1(pe_matrix_odo2_1_1),
        .acc_matrix_di_2_1_2(pe_matrix_odo2_1_2),
        .acc_matrix_di_2_2_0(pe_matrix_odo2_2_0),
        .acc_matrix_di_2_2_1(pe_matrix_odo2_2_1),
        .acc_matrix_di_2_2_2(pe_matrix_odo2_2_2),

        .acc_matrix_do_0(acc_matrix_do0),
        .acc_matrix_do_1(acc_matrix_do1),
        .acc_matrix_do_2(acc_matrix_do2)
    );

    //output buffers
    output_buf obuf0(
        .clk(clk),
        .reset(reset && accel_ctrl_reset),
        .enb(obuf0_enb && accel_ctrl_enb),

        .obuf_di(obuf0_di),
        .obuf_do(obuf0_do),

        .obuf_ld(obuf0_ld)
    );

    output_buf obuf1(
        .clk(clk),
        .reset(reset && accel_ctrl_reset),
        .enb(obuf1_enb && accel_ctrl_enb),

        .obuf_di(obuf1_di),
        .obuf_do(obuf1_do),

        .obuf_ld(obuf1_ld)
    );

    output_buf obuf2(
        .clk(clk),
        .reset(reset && accel_ctrl_reset),
        .enb(obuf2_enb && accel_ctrl_enb),

        .obuf_di(obuf2_di),
        .obuf_do(obuf2_do),

        .obuf_ld(obuf2_ld)
    );

    //element wise unit
    elw_unit elw_unit(
        .clk(clk),
        .reset(reset && accel_ctrl_reset),

        .quant_act_func_enb_0(quant_act_func_enb0),
        .quant_act_func_enb_1(quant_act_func_enb1),
        .quant_act_func_enb_2(quant_act_func_enb2),

        .cp_clr(compare_clear),
        .cp2h_enb(weight_kernel_height == 2),
        .cp2w_enb(weight_kernel_width == 2),
        .cp_enb(compare_enb),

        .elew_quant_muler_0(output_mult0),
        .elew_quant_muler_1((cfg_layer_type == CONV) ? output_mult1 : output_mult0),
        .elew_quant_muler_2((cfg_layer_type == CONV) ? output_mult2 : output_mult0),

        .elew_quant_rshift_0(output_shift0),
        .elew_quant_rshift_1((cfg_layer_type == CONV) ? output_shift1 :output_shift0),
        .elew_quant_rshift_2((cfg_layer_type == CONV) ? output_shift2 :output_shift0),

        .elew_output_offset(output_offset),
        .elew_act_func_type(cfg_act_func_type),

        .elew_di_0_0(acc_matrix_do0),
        .elew_di_0_1(acc_matrix_do1),
        .elew_di_0_2(acc_matrix_do2),
        .elew_di_1_0(ibuf0_do_0),
        .elew_di_1_1(ibuf0_do_1),
        .elew_di_1_2(ibuf0_do_2),

        .elew_do_0_0(elew_do0_0),
        .elew_do_0_1(elew_do0_1),
        .elew_do_0_2(elew_do0_2),

        .valid_0(quant_act_func_ready0),
        .valid_1(quant_act_func_ready1),
        .valid_2(quant_act_func_ready2)
    );

    config_regs config_regs(
        .clk(clk),
        .reset(reset && accel_ctrl_reset),

        .config_wen(accel_cfgreg_write_enb),
        .config_data(accel_Cfgreg_di),
        .config_sel(accel_cfg_reg_sel),
        .output_quant_buf_outsel(o_quant_sel),

        .i_base_addr(i_base_addr),
        .kw_base_addr(kw_base_addr),
        .o_base_addr(o_base_addr),
        .b_base_addr(bp_base_addr),
        .ps_base_addr(ps_base_addr),

        .cfg_layer_type(cfg_layer_type),
        .cfg_act_func_type(cfg_act_func_type),

        .stride_width(w_stride),
        .stride_height(h_stride),

        .weight_kernel_width(weight_kernel_width),
        .weight_kernel_height(weight_kernel_height),

        .kernel_ifm_depth(kernel_ifm_depth),
        .out_total_kernel_ofm_depth(out_total_kernel_ofm_depth),

        .ifm_height(h_ifm),
        .ifm_width(w_ifm),

        .ofm_height(h_ofm),
        .ofm_width(w_ofm),

        .input2D_size(input2D_size),
        .output2D_size(output2D_size),
        .kernel3D_size(kernel3D_size),

        .output_multiplier_0(output_mult0),
        .output_multiplier_1(output_mult1),
        .output_multiplier_2(output_mult2),

        .output_shift_0(output_shift0),
        .output_shift_1(output_shift1),
        .output_shift_2(output_shift2),

        .input_offset(input_offset),
        .output_offset(output_offset)
    );

    wire [2:0] ctrl_wbuf_enb, ctrl_wbuf_ld;
    wire [5:0] ctrl_wbuf_wstrb, ctrl_wbuf_bank_sel;
    assign ctrl_wbuf_enb = {wbuf2_enb, wbuf1_enb, wbuf0_enb};
    assign ctrl_wbuf_ld = {wbuf2_ld, wbuf1_ld, wbuf0_ld};
    assign ctrl_wbuf_wstrb = {wbuf2_wstrb, wbuf1_wstrb, wbuf0_wstrb};
    assign ctrl_wbuf_bank_sel = {wbuf2_bank_sel, wbuf1_bank_sel, wbuf0_bank_sel};

    wire [2:0] ctrl_ibuf_enb, ctrl_ibuf_ld;
    wire [2:0] ctrl_ibuf_di_reverse, ctrl_ibuf_do_reverse;
    wire [5:0] ctrl_ibuf_bank_sel;
    assign ctrl_ibuf_enb = {ibuf2_enb, ibuf1_enb, ibuf0_enb};
    assign ctrl_ibuf_ld = {ibuf2_ld, ibuf1_ld, ibuf0_ld};
    assign ctrl_ibuf_di_reverse = {ibuf2_di_reverse, ibuf1_di_reverse, ibuf0_di_reverse};
    assign ctrl_ibuf_do_reverse = {ibuf2_do_reverse, ibuf1_do_reverse, ibuf0_do_reverse};
    assign ctrl_ibuf_bank_sel = {ibuf2_bank_sel, ibuf1_bank_sel, ibuf0_bank_sel};
    
    wire [2:0] ctrl_bpbuf_enb, ctrl_bpbuf_ld;
    assign ctrl_bpbuf_enb = {bpbuf2_enb, bpbuf1_enb, bpbuf0_enb};
    assign ctrl_bpbuf_ld = {bpbuf2_ld, bpbuf1_ld, bpbuf0_ld};

    wire [8:0] ctrl_ireg_enb;
    assign ctrl_ireg_enb = {ireg_enb2_2, ireg_enb2_1, ireg_enb2_0,
                            ireg_enb1_2, ireg_enb1_1, ireg_enb1_0,
                            ireg_enb0_2, ireg_enb0_1, ireg_enb0_0};

    wire [26:0] ctrl_wreg_enb;
    assign ctrl_wreg_enb = {wreg_enb2_2_2, wreg_enb2_2_1, wreg_enb2_2_0,
                            wreg_enb2_1_2, wreg_enb2_1_1, wreg_enb2_1_0,
                            wreg_enb2_0_2, wreg_enb2_0_1, wreg_enb2_0_0,
                            wreg_enb1_2_2, wreg_enb1_2_1, wreg_enb1_2_0,
                            wreg_enb1_1_2, wreg_enb1_1_1, wreg_enb1_1_0,
                            wreg_enb1_0_2, wreg_enb1_0_1, wreg_enb1_0_0,
                            wreg_enb0_2_2, wreg_enb0_2_1, wreg_enb0_2_0,
                            wreg_enb0_1_2, wreg_enb0_1_1, wreg_enb0_1_0,
                            wreg_enb0_0_2, wreg_enb0_0_1, wreg_enb0_0_0};

    wire [8:0] ctrl_pe_enb;
    assign ctrl_ireg_enb = {pe_enb2_2, pe_enb2_1, pe_enb2_0,
                            pe_enb1_2, pe_enb1_1, pe_enb1_0,
                            pe_enb0_2, pe_enb0_1, pe_enb0_0};

    wire [2:0] ctrl_elw_quant_act_enb;
    assign ctrl_elw_quant_act_enb = {quant_act_func_enb2, quant_act_func_enb1, quant_act_func_enb0};

    wire [2:0] ctrl_obuf_enb, ctrl_obuf_ld;
    assign ctrl_obuf_enb = {obuf2_enb, obuf1_enb, obuf0_enb};
    assign ctrl_obuf_ld = {obuf2_ld, obuf1_ld, obuf0_ld};

    flow_ctrl flow_ctrl(
        .clk(clk),
        .reset(reset),
        .enb(accel_ctrl_enb),

        .cfg_layer_type(cfg_layer_type),

        .i_base_addr(i_base_addr),
        .o_base_addr(o_base_addr),
        .bp_base_addr(bp_base_addr),
        .ps_base_addr(ps_base_addr),
        .kw_base_addr(kw_base_addr),

        .w_stride(w_stride),
        .h_stride(h_stride),

        .out_total_kernel_ofm_depth(out_total_kernel_ofm_depth),
        .kernel_ifm_depth(kernel_ifm_depth),
        .w_ifm(w_ifm),
        .h_ifm(h_ifm),
        .w_ofm(w_ofm),
        .h_ofm(h_ofm),

        .weight_kernel_height(weight_kernel_height),
        .weight_kernel_width(weight_kernel_width),

        .kernel3D_size(kernel3D_size),
        .in2D_size(input2D_size),
        .out2D_size(output2D_size),

        .ctrl_mem_read_ready(accel_mem_read_ready),
        .ctrl_mem_write_ready(accel_mem_write_ready),

        .ctrl_ibuf_0_valid(ibuf0_valid),
        .ctrl_ibuf_1_valid(ibuf1_valid),
        .ctrl_ibuf_2_valid(ibuf2_valid),
        .ctrl_ibuf_0_valid_next(ibuf0_valid_next),
        .ctrl_ibuf_1_valid_next(ibuf1_valid_next),
        .ctrl_ibuf_2_valid_next(ibuf2_valid_next),

        .ctrl_pe_matrix_ready(pe_matrix_ready),
        .ctrl_elw_quant_act_ready(elw_quant_act_ready),

        .ctrl_mem_read_addr(accel_read_addr),
        .ctrl_mem_read_enb(accel_read_enb),

        .ctrl_wbuf_enb(ctrl_wbuf_enb),
        .ctrl_wbuf_ld(ctrl_wbuf_ld),
        .ctrl_wbuf_bank_sel(ctrl_wbuf_bank_sel),
        .ctrl_wbuf_wstrb(ctrl_wbuf_wstrb),

        .ctrl_ibuf_conv_wstrb(ibuf_conv_wstrb),
        .ctrl_ibuf_dense_wstrb(ibuf_dense_wstrb),
        .ctrl_ibuf_ld(ctrl_ibuf_ld),
        .ctrl_ibuf_enb(ctrl_ibuf_enb),
        .ctrl_ibuf_di_reverse(ctrl_ibuf_di_reverse),
        .ctrl_ibuf_do_reverse(ctrl_ibuf_do_reverse),
        .ctrl_ibuf_bank_sel(ctrl_ibuf_bank_sel),
        .ctrl_ibuf_conv_fi_load(ibuf_conv_fi_load),
        .ctrl_ibuf_conv_se_load(ibuf_conv_se_load),

        .ctrl_bpbuf_enb(ctrl_bpbuf_enb),
        .ctrl_bpbuf_ld(ctrl_bpbuf_ld),

        .ctrl_idemux(pe_matrix_isel),
        .ctrl_ireg_enb(ctrl_ireg_enb),

        .ctrl_wdemux(pe_matrix_wsel),
        .ctrl_wreg_enb(ctrl_wreg_enb),

        .ctrl_pe_matrix_conv_dir(pe_matrix_conv_dir),

        .ctrl_acc_matrix_enb_0(acc_matrix_enb0),
        .ctrl_acc_matrix_bp_ld(acc_matrix_bp_ld),

        .ctrl_compare_enb(compare_enb),
        .ctrl_compare_clear(compare_clear),

        .ctrl_acc_matrix_enb_1(acc_matrix_enb1),
        .ctrl_acc_matrix_bp_write(acc_matrix_bp_write),
        .ctrl_acc_matrix_sum_write(acc_matrix_sum_write),

        .ctrl_pe_enb(ctrl_pe_enb),

        .ctrl_mem_write_addr(accel_write_addr),
        .ctrl_mem_wstrb(accel_wstrb),
        .ctrl_mem_write_enb0(accel_write_enb0),
        .ctrl_mem_write_enb1(accel_write_enb1),
        .ctrl_mem_write_enb2(accel_write_enb2),

        .ctrl_elw_quant_act_enb(ctrl_elw_quant_act_enb),
        .ctrl_obuf_enb(ctrl_obuf_enb),
        .ctrl_obuf_ld(ctrl_obuf_ld),

        .ctrl_out_done(flow_ctrl_out_done),
        .ctrl_o_quant_sel(o_quant_sel),

        .flow_ctrl_done(accel_done)
    );
endmodule
