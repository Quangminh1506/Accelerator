`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 12:40:23 PM
// Design Name: 
// Module Name: flow_ctrl_wb
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


module flow_ctrl_wb(
        input clk,
        input resetn,
        input enb,

        input [3:0] cfg_layer_type,
        input [15:0] out2D_size,
        //element wise unit
        input [2:0] elw_quant_act_ready,

        input mem_write_ready,

        //from read signals
        input read_ready,
        input read_done,
        input read_out_done,
        input [31:0] read_o_addr,

        //from comp signals
        input comp_ready,
        input comp_done,
        //input comp_start,
        input comp_out_done,
        input [31:0] comp_o_addr,
        input [31:0] comp_ps_addr,
        input [3:0] comp_o_quant_sel,

        output reg [2:0] elw_quant_act_enb,
        output reg [2:0] obuf_enb,
        output reg [2:0] obuf_ld,
        output reg [31:0] mem_write_addr,
        output reg [3:0] mem_wstrb,
        output reg mem_write_enb0,
        output reg mem_write_enb1,
        output reg mem_write_enb2,

        output reg wb_done,
        output reg wb_ready,
        output reg wb_start,
        output wb_out_done,
        output [31:0] wb_ps_addr,
        output [31:0] wb_o_addr,
        output [3:0] wb_o_quant_sel

    );

    localparam CONV = 4'd0,
               POOLING = 4'd1,
               DENSE = 4'd2;

    localparam GL_BEGIN = 3'd0,
               GL_CHECK = 3'd1,
               GL_LOAD = 3'd2,
               GL_WRITE = 3'd3,
               GL_WAIT = 3'd4,
               GL_DONE = 3'd5;

    assign wb_out_done = (cfg_layer_type == POOLING) ? read_out_done : comp_out_done;
    assign wb_o_addr = (cfg_layer_type == POOLING) ? read_o_addr : comp_o_addr;
    assign wb_o_quant_sel = comp_o_quant_sel;
    assign wb_ps_addr = comp_ps_addr;

    wire [31:0] ps_addr0, ps_addr1, ps_addr2;
    assign ps_addr0 = wb_ps_addr;
    assign ps_addr1[1:0] = ps_addr0[1:0];
    assign ps_addr1[31:2] = ps_addr0[31:2] + out2D_size;
    assign ps_addr2[1:0] = ps_addr1[1:0];
    assign ps_addr2[31:2] = ps_addr1[31:2] + out2D_size;

    wire [31:0] o_addr0, o_addr1, o_addr2;
    assign o_addr0 = wb_o_addr;
    assign o_addr1 = o_addr0 + out2D_size;
    assign o_addr2 = o_addr1 + out2D_size;

    reg [1:0] cnt;
    reg [2:0] wb_g_state;
    reg mem_write_state;

    reg [1:0] addr_write_pos;
    reg [3:0] out_pos_write;

    assign quant_ready = |elw_quant_act_ready;

    always @* begin
        case (addr_write_pos) 
            2'd0: out_pos_write = 4'b0001;
            2'd1: out_pos_write = 4'b0010;
            2'd2: out_pos_write = 4'b0100;
            2'd3: out_pos_write = 4'b1000;
        endcase
    end

    always @(posedge clk) begin
        if (!resetn) begin
            wb_g_state <= GL_BEGIN;
            cnt <= 0;
            mem_write_state <= 0;
        end
        else if (enb) begin
            case (cfg_layer_type)
                CONV, DENSE: begin
                    case (wb_g_state)
                        GL_BEGIN: if ((read_ready || read_done) && (comp_ready || comp_done))
                                wb_g_state <= GL_CHECK;
    
                        GL_CHECK: begin
                            if (wb_out_done) begin
                                if (quant_ready) wb_g_state <= GL_LOAD;
                            end
                            else wb_g_state <= GL_WRITE;
                        end
    
                        GL_LOAD: wb_g_state <= GL_WRITE;
    
                        GL_WRITE: begin
                            if (mem_write_state) begin
                                if (mem_write_ready) begin
                                    if (cnt >= 2) begin
                                        cnt <= 0;
                                        wb_g_state <= GL_WAIT;
                                    end
                                    else cnt <= cnt + 1;
                                    mem_write_state <= !mem_write_state;
                                end
                            end
                            else mem_write_state <= !mem_write_state;
                        end
    
                        GL_WAIT: begin
                            if ((read_ready || read_done) && (comp_ready || comp_done) && wb_ready) begin
                                if (comp_done) wb_g_state <= GL_DONE;
                                else wb_g_state <= GL_CHECK;
                            end
                        end
                    endcase
                end

                POOLING: begin
                    case (wb_g_state)
                    GL_BEGIN: if (read_ready || read_done) wb_g_state <= GL_LOAD;

                    GL_LOAD: wb_g_state <= GL_WRITE;

                    GL_WRITE: begin
                        if (mem_write_state) begin
                            if (mem_write_ready) begin
                                wb_g_state <= GL_WAIT;
                                mem_write_state <= !mem_write_state;
                            end
                        end
                        else mem_write_state <= !mem_write_state;
                    end

                    GL_WAIT: begin
                        if ((read_ready || read_done) && wb_ready) begin
                            if (read_done) wb_g_state <= GL_DONE;
                            else wb_g_state <= GL_LOAD;
                        end
                    end
                    endcase
                end
            endcase
        end
    end

    always @* begin
        mem_write_addr = 0;
        mem_wstrb = 0;
        mem_write_enb0 = 0;
        mem_write_enb1 = 0;
        mem_write_enb2 = 0;

        obuf_enb = 0;
        obuf_ld = 0;
        elw_quant_act_enb = 0;

        wb_done = 0;
        wb_start = 0;
        wb_ready = 0;
        addr_write_pos = 0;

        case (cfg_layer_type)
            CONV, DENSE: begin
                case (wb_g_state)
                    GL_BEGIN: wb_start = 1;

                    GL_CHECK: begin
                        if (wb_out_done) elw_quant_act_enb = 3'b111;
                        else begin
                            obuf_enb = 3'b111;
                            obuf_ld = 3'b111;
                        end
                    end

                    GL_LOAD: begin
                        obuf_enb = 3'b111;
                        obuf_ld = 3'b111;
                    end

                    GL_WRITE: begin
                        if (wb_out_done) begin
                            mem_wstrb = out_pos_write;
                            case (cnt)
                                2'd0: begin
                                    mem_write_addr = o_addr0;
                                    addr_write_pos = o_addr0[1:0];
                                    mem_write_enb0 = 1;
                                end

                                2'd1: begin
                                    if (cfg_layer_type == CONV) begin
                                        mem_write_addr = o_addr1;
                                        addr_write_pos = o_addr1[1:0];
                                    end
                                    else begin
                                        mem_write_addr = o_addr0 + 1;
                                        addr_write_pos = o_addr0[1:0] + 1;
                                    end
                                    mem_write_enb1 = 1;
                                end

                                2'd2: begin
                                    if (cfg_layer_type == CONV) begin
                                        mem_write_addr = o_addr2;
                                        addr_write_pos = o_addr2[1:0];
                                    end
                                    else begin
                                        mem_write_addr = o_addr0 + 2;
                                        addr_write_pos = o_addr0[1:0] + 2;
                                    end
                                    mem_write_enb2 = 1;
                                end
                            endcase
                        end
                        else begin
                            mem_wstrb = 4'b1111;
                            case (cnt)
                                2'd0: begin
                                    mem_write_addr = ps_addr0;
                                    mem_write_enb0 = 1;
                                end

                                2'd1: begin
                                    if (cfg_layer_type == CONV) mem_write_addr = ps_addr1;
                                    else mem_write_addr = ps_addr0 + 4;
                                    mem_write_enb1 = 1;
                                end

                                2'd2: begin
                                    if (cfg_layer_type == CONV) mem_write_addr = ps_addr2;
                                    else mem_write_addr = ps_addr0 + 8;
                                    mem_write_enb2 = 1;
                                end
                            endcase
                        end

                        if (mem_write_state) begin
                            if (mem_write_ready) begin
                                mem_write_enb0 = 0;
                                mem_write_enb1 = 0;
                                mem_write_enb2 = 0;
                            end
                        end
                    end

                    GL_WAIT: wb_ready = 1;

                    GL_DONE: wb_done = 1;
                endcase
            end

            POOLING: begin
                case (wb_g_state)
                    GL_BEGIN: wb_start = 1;

                    GL_LOAD: begin
                        obuf_enb = 3'b001;
                        obuf_ld = 3'b001;
                    end

                    GL_WRITE: begin
                        mem_wstrb = out_pos_write;
                        mem_write_addr = o_addr0;
                        mem_write_enb0 = 1;
                        addr_write_pos = o_addr0[1:0];

                        if (mem_write_state) begin
                            if (mem_write_ready) mem_write_enb0= 0;
                        end
                    end

                    GL_WAIT: wb_ready = 1;

                    GL_DONE: wb_done = 1;
                endcase
            end
        endcase
    end

endmodule