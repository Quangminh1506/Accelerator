`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 12:40:06 PM
// Design Name: 
// Module Name: flow_ctrl_comp
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


module flow_ctrl_comp(
        input clk,
        input enb,
        input reset,

        input [3:0] cfg_layer_type,
        input pe_matrix_ready,

        input read_ready,
        input read_done,
        input read_out_done,
        input [31:0] read_o_addr,
        input [31:0] read_ps_addr,
        input [3:0] read_o_quant_sel,

        input wb_ready,
        input wb_start,

        output reg [8:0] pe_enb,
        output reg acc_matrix_enb,
        output reg acc_matrix_bp_write,
        output reg acc_matrix_sum_write,

        output reg [31:0] comp_ps_addr,
        output reg [31:0] comp_o_addr,
        output reg [3:0] comp_o_quant_sel,
        output reg comp_start,
        output reg comp_done,
        output reg comp_ready,
        output reg comp_out_done
    );
    localparam CONV = 4'd0,
               POOLING = 4'd1,
               DENSE = 4'd2;

    localparam GL_BEGIN = 3'd0,
               GL_MAC = 3'd1,
               GL_ACC = 3'd2,
               GL_WAIT = 3'd3,
               GL_DONE = 3'd4;

    reg [2:0] comp_g_state;

    reg first_cycle; //clear new

    always @(posedge clk) begin
        if (reset) begin
            comp_g_state <= GL_BEGIN;
            first_cycle <= 0;
        end
        else if (enb) begin
            case (cfg_layer_type)
                CONV, DENSE: begin
                    case (comp_g_state) 
                        GL_BEGIN: begin
                            if ((read_ready || read_done) && wb_start) begin
                                comp_g_state <= GL_MAC;
                                first_cycle <= 1;
                            end
                        end

                        GL_MAC: begin
                            if (pe_matrix_ready) comp_g_state <= GL_ACC;
                            first_cycle <= 0;
                        end

                        GL_ACC: begin
                            comp_g_state <= GL_WAIT;
                            first_cycle <= 0;
                        end

                        GL_WAIT: begin
                            if ((read_done || read_ready) && (wb_ready || wb_start) && comp_ready) begin
                                if (read_done) comp_g_state <= GL_DONE;
                                else begin
                                    comp_g_state <= GL_MAC;
                                    first_cycle <= 1;
                                end
                            end
                        end
                    endcase
                end

                POOLING: begin
                    
                end
            endcase
        end
    end

    always @* begin
        pe_enb = 0;
        acc_matrix_bp_write = 0;
        acc_matrix_enb = 0;
        acc_matrix_sum_write = 0;

        comp_start = 0;
        comp_done = 0;
        comp_ready = 0;
        
        case (cfg_layer_type) 
            CONV, DENSE: begin
                case (comp_g_state)
                    GL_BEGIN: comp_start = 1;

                    GL_MAC: begin
                        if (cfg_layer_type == CONV) pe_enb = 9'b111111111;
                        else pe_enb = 9'b000000111;

                        if (first_cycle) begin
                            acc_matrix_enb = 1;
                            acc_matrix_bp_write = 1;
                        end
                    end

                    GL_ACC: begin
                        acc_matrix_enb = 1;
                        acc_matrix_sum_write = 1;
                    end

                    GL_WAIT: comp_ready = 1;

                    GL_DONE: comp_done = 1;
                endcase
            end

            POOLING: comp_start = 1;
        endcase
    end

    //FF for next stage
    always @(posedge clk) begin
        if (reset) begin
            comp_out_done = 0;
            comp_o_addr = 0;
            comp_ps_addr = 0;
            comp_o_quant_sel = 0;
        end
        else if ((read_ready || read_done) && (wb_ready || wb_start) && comp_ready && enb) begin
            comp_out_done = read_out_done;
            comp_o_addr = read_o_addr;
            comp_ps_addr = read_ps_addr;
            comp_o_quant_sel = read_o_quant_sel;
        end
    end

endmodule
