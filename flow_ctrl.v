`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2026 03:38:53 PM
// Design Name: 
// Module Name: flow_ctrl
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


module flow_ctrl(
        input clk,
        input resetn,
        input enb,

        input [3:0] cfg_layer_type,
        input [31:0] i_base_addr,
        input [31:0] o_base_addr,
        input [31:0] bp_base_addr,
        input [31:0] ps_base_addr,
        input [31:0] kw_base_addr,

        input [3:0] w_stride,
        input [3:0] h_stride,

        input [15:0] out_total_kernel_ofm_depth,
        input [15:0] kernel_ifm_depth,
        input [15:0] w_ifm,
        input [15:0] h_ifm,
        input [15:0] w_ofm,
        input [15:0] h_ofm,

        input [15:0] weight_kernel_height,
        input [15:0] weight_kernel_width,

        input [31:0] kernel3D_size,
        input [15:0] in2D_size,
        input [15:0] out2D_size,

    //input ctrl sigs
        //soc bus
        input ctrl_mem_read_ready,
        input ctrl_mem_write_ready,
        //read stage
        input [2:0] ctrl_ibuf_0_valid,
        input [2:0] ctrl_ibuf_1_valid,
        input [2:0] ctrl_ibuf_2_valid,
        input [2:0] ctrl_ibuf_0_valid_next,
        input [2:0] ctrl_ibuf_1_valid_next,
        input [2:0] ctrl_ibuf_2_valid_next,

        //comp stage
        input ctrl_pe_matrix_ready,

        //write back stage
        input [2:0] ctrl_elw_quant_act_ready,

    //output ctrl sigs
      //read stage
        output [31:0] ctrl_mem_read_addr,
        output ctrl_mem_read_enb,

        //weight ctrl
        output [2:0] ctrl_wbuf_enb,
        output [2:0] ctrl_wbuf_ld,
        output [5:0] ctrl_wbuf_wstrb,
        output [5:0] ctrl_wbuf_bank_sel,

        //input ctrl
        output [2:0] ctrl_ibuf_conv_wstrb,
        output [1:0] ctrl_ibuf_dense_wstrb,
        output [2:0] ctrl_ibuf_ld,
        output [2:0] ctrl_ibuf_enb,
        output [2:0] ctrl_ibuf_di_reverse,
        output [2:0] ctrl_ibuf_do_reverse,
        output [5:0] ctrl_ibuf_bank_sel,
        output ctrl_ibuf_conv_fi_load,
        output ctrl_ibuf_conv_se_load,

        //bias /partial sum ctrl
        output [2:0] ctrl_bpbuf_ld,
        output [2:0] ctrl_bpbuf_enb,

        //input demux reg enb
        output [1:0] ctrl_idemux,
        output [8:0] ctrl_ireg_enb,

        //weight demux reg enb
        output [1:0] ctrl_wdemux,
        output [26:0] ctrl_wreg_enb,

        output [1:0] ctrl_pe_matrix_conv_dir,

        //acc matrix
        output ctrl_acc_matrix_enb_0,
        output ctrl_acc_matrix_bp_ld,

        //elw
        output ctrl_compare_enb,
        output ctrl_compare_clear,

      //comp stage
        //acc matrix
        output ctrl_acc_matrix_enb_1,
        output ctrl_acc_matrix_bp_write,
        output ctrl_acc_matrix_sum_write,

        output [8:0] ctrl_pe_enb,

      //write back stage
        output [31:0] ctrl_mem_write_addr,
        output [3:0] ctrl_mem_wstrb,
        output ctrl_mem_write_enb0,
        output ctrl_mem_write_enb1,
        output ctrl_mem_write_enb2,

        //elw
        output [2:0] ctrl_elw_quant_act_enb,

        //output reg
        output [2:0] ctrl_obuf_enb,
        output [2:0] ctrl_obuf_ld,

        //out signal ctrl
        output ctrl_out_done,
        output [3:0] ctrl_o_quant_sel,

        output flow_ctrl_done
    );

  wire read_ready, read_done, comp_ready, comp_done, wb_ready, wb_done;
  wire wb_start, comp_start;
  wire read_out_done, comp_out_done, wb_out_done;

  wire [3:0] read_o_quant_sel, comp_o_quant_sel, wb_o_quant_sel;
  wire [31:0] read_o_addr, comp_o_addr, wb_o_addr;
  wire [31:0] read_ps_addr, comp_ps_addr, wb_ps_addr;

  assign ctrl_out_done = wb_out_done;
  assign ctrl_o_quant_sel = wb_o_quant_sel;

  assign flow_ctrl_done = wb_done;

  flow_ctrl_read read_ctrl(
    .clk (clk),
    .resetn(resetn),
    .enb(enb),

    .cfg_layer_type(cfg_layer_type),
    .w_stride(w_stride),
    .h_stride(h_stride),
    .weight_kernel_width(weight_kernel_width),
    .weight_kernel_height(weight_kernel_height),

    .mem_read_ready(ctrl_mem_read_ready),
    .i_base_addr(i_base_addr),
    .kw_base_addr(kw_base_addr),
    .o_base_addr(o_base_addr),
    .bp_base_addr(bp_base_addr),
    .ps_base_addr(ps_base_addr),

    .w_ifm(w_ifm),
    .h_ifm(h_ifm),
    .kernel_ifm_depth(kernel_ifm_depth),
    .w_ofm(w_ofm),
    .h_ofm(h_ofm),
    .out_total_kernel_ofm_depth(out_total_kernel_ofm_depth),

    .comp_ready(comp_ready),
    .comp_start(comp_start),

    .wb_start(wb_start),
    .wb_ready(wb_ready),

    .ibuf_0_valid(ctrl_ibuf_0_valid),
    .ibuf_1_valid(ctrl_ibuf_1_valid),
    .ibuf_2_valid(ctrl_ibuf_2_valid),
    .ibuf_0_valid_next(ctrl_ibuf_0_valid_next),
    .ibuf_1_valid_next(ctrl_ibuf_1_valid_next),
    .ibuf_2_valid_next(ctrl_ibuf_2_valid_next),

    .kernel3D_size(kernel3D_size),
    .in2D_size(in2D_size),
    .out2D_size(out2D_size),

    .read_done(read_done),
    .read_ready(read_ready),
    .read_out_done(read_out_done),
    .read_ps_addr(read_ps_addr),
    .read_o_addr(read_o_addr),
    .read_o_quant_sel(read_o_quant_sel),

    .mem_read_addr(ctrl_mem_read_addr),
    .mem_read_enb(ctrl_mem_read_enb),
    .pe_matrix_conv_dir(ctrl_pe_matrix_conv_dir),

    .wbuf_enb(ctrl_wbuf_enb),
    .wbuf_wstrb(ctrl_wbuf_wstrb),
    .wbuf_ld(ctrl_wbuf_ld),
    .wbuf_bank_sel(ctrl_wbuf_bank_sel),
    .wdemux(ctrl_wdemux),
    .wreg_enb(ctrl_wreg_enb),

    .bpbuf_enb(ctrl_bpbuf_enb),
    .bpbuf_ld(ctrl_bpbuf_ld),

    .ibuf_conv_wstrb(ctrl_ibuf_conv_wstrb),
    .ibuf_dense_wstrb(ctrl_ibuf_dense_wstrb),
    .ibuf_ld(ctrl_ibuf_ld),
    .ibuf_di_reverse(ctrl_ibuf_di_reverse),
    .ibuf_do_reverse(ctrl_ibuf_do_reverse),
    .ibuf_bank_sel(ctrl_ibuf_bank_sel),
    .ibuf_conv_fi_load(ctrl_ibuf_conv_fi_load),
    .ibuf_conv_se_load(ctrl_ibuf_conv_se_load),
    .ibuf_enb(ctrl_ibuf_enb),
    .idemux(ctrl_idemux),
    .ireg_enb(ctrl_ireg_enb),

    .compare_enb(ctrl_compare_enb),
    .compare_clear(ctrl_compare_clear),

    .acc_matrix_enb(ctrl_acc_matrix_enb_0),
    .acc_matrix_bp_ld(ctrl_acc_matrix_bp_ld)
  );

  flow_ctrl_comp comp_ctrl(
    .clk(clk),
    .enb(enb),
    .resetn(resetn),

    .cfg_layer_type(cfg_layer_type),
    .pe_matrix_ready(ctrl_pe_matrix_ready),

    .read_ready(read_ready),
    .read_done(read_done),
    .read_out_done(read_out_done),
    .read_o_addr(read_o_addr),
    .read_ps_addr(read_ps_addr),
    .read_o_quant_sel(read_o_quant_sel),

    .wb_ready(wb_ready),
    .wb_start(wb_start),

    .pe_enb(ctrl_pe_enb),
    .acc_matrix_enb(ctrl_acc_matrix_enb_1),
    .acc_matrix_bp_write(ctrl_acc_matrix_bp_write),
    .acc_matrix_sum_write(ctrl_acc_matrix_sum_write),

    .comp_ps_addr(comp_ps_addr),
    .comp_o_addr(comp_o_addr),
    .comp_o_quant_sel(comp_o_quant_sel),
    .comp_start(comp_start),
    .comp_done(comp_done),
    .comp_ready(comp_ready),
    .comp_out_done(comp_out_done)
  );

  flow_ctrl_wb wb_ctrl(
    .clk(clk),
    .resetn(resetn),
    .enb(enb),

    .cfg_layer_type(cfg_layer_type),
    .out2D_size(out2D_size),
    .elw_quant_act_ready(ctrl_elw_quant_act_ready),

    .mem_write_ready(ctrl_mem_write_ready),

    .read_ready(read_ready),
    .read_done(read_done),
    .read_out_done(read_out_done),
    .read_o_addr(read_o_addr),

    .comp_ready(comp_ready),
    .comp_done(comp_done),
    //.comp_start(comp_start),
    .comp_out_done(comp_out_done),
    .comp_o_addr(comp_o_addr),
    .comp_o_quant_sel(comp_o_quant_sel),
    .comp_ps_addr(comp_ps_addr),

    .elw_quant_act_enb(ctrl_elw_quant_act_enb),
    .obuf_enb(ctrl_obuf_enb),
    .obuf_ld(ctrl_obuf_ld),
    .mem_write_addr(ctrl_mem_write_addr),
    .mem_wstrb(ctrl_mem_wstrb),
    .mem_write_enb0(ctrl_mem_write_enb0),
    .mem_write_enb1(ctrl_mem_write_enb1),
    .mem_write_enb2(ctrl_mem_write_enb2),

    .wb_done(wb_done),
    .wb_ready(wb_ready),
    .wb_start(wb_start),
    .wb_out_done(wb_out_done),
    .wb_o_addr(wb_o_addr),
    .wb_ps_addr(wb_ps_addr),
    .wb_o_quant_sel(wb_o_quant_sel)
  );

endmodule
