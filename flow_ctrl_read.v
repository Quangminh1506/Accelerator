`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2026 03:24:49 PM
// Design Name: 
// Module Name: flow_ctrl_read
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


module flow_ctrl_read(
        input clk,
        input reset,
        input enb,

        //layer data
        input [3:0] cfg_layer_type,
        input [3:0] w_stride, 
        input [3:0] h_stride,
        //kernel width and height
        input [15:0] weight_kernel_width, 
        input [15:0] weight_kernel_height,

        input mem_read_ready,

        input [31:0] i_base_addr,
        input [31:0] kw_base_addr,
        input [31:0] o_base_addr,
        input [31:0] bp_base_addr,
        input [31:0] ps_base_addr,

        input [15:0] w_ifm,
        input [15:0] h_ifm,
        input [15:0] kernel_ifm_depth,

        input [15:0] w_ofm,
        input [15:0] h_ofm,
        input [15:0] out_total_kernel_ofm_depth,
        
        
        input comp_ready,
        input comp_start,
        
        input wb_ready,
        input wb_start,
        
        //input buffer feedback ctrl
        input [2:0] ibuf_0_valid,
        input [2:0] ibuf_1_valid,
        input [2:0] ibuf_2_valid,
        
        input [2:0] ibuf_0_valid_next,
        input [2:0] ibuf_1_valid_next,
        input [2:0] ibuf_2_valid_next,
        
        // kernel and ifm size
        input [31:0] kernel3D_size, // = kw * kh * kd
        input [15:0] in2D_size, // = ifm_w * ifm_h 
        input [15:0] out2D_size, // = ofm_w * ofm_h
        
        //stage ctrl sig
        output reg read_done,
        output reg read_ready,
        output reg read_out_done,
        output reg [31:0] read_ps_addr,
        output reg [31:0] read_o_addr,
        output reg [3:0] read_o_quant_sel,

        //output soc read sigs
        output reg [31:0] mem_read_addr,
        output reg mem_read_enb,
        
        //conv direction
        output reg [1:0] pe_matrix_conv_dir,
        
        //weight buffer ctrl
        output reg [2:0] wbuf_enb,
        output reg [5:0] wbuf_wstrb,
        output reg [2:0] wbuf_ld,
        output reg [5:0] wbuf_bank_sel,
        output reg [1:0] wdemux,
        output reg [26:0] wreg_enb,
        
        //bias point buffer ctrl
        output reg [2:0] bpbuf_enb,
        output reg [2:0] bpbuf_ld,
        
        //input buffer ctrl
        output reg [2:0] ibuf_conv_wstrb,
        output reg [1:0] ibuf_dense_wstrb,
        output reg [2:0] ibuf_ld,
        output reg [2:0] ibuf_di_reverse,
        output reg [2:0] ibuf_do_reverse,
        output reg [5:0] ibuf_bank_sel,
        output reg ibuf_conv_fi_load,
        output reg ibuf_conv_se_load,
        output reg [2:0] ibuf_enb,
        output reg [1:0] idemux,
        output reg [8:0] ireg_enb,
        
        //pooling reg
        output reg compare_enb,
        output reg compare_clear,

        //acc matrix
        output reg acc_matrix_enb,
        output reg acc_matrix_bp_ld
    );
    
    //state defines
    reg [3:0] read_g_state, read_weight_state, read_input_state;
    
    //define coor
    reg [15:0] x_in, y_in, x_out, y_out;
    reg [15:0] x_kw, y_kw, z_kw_in, z_kw_num_out;
    reg mem_read_state;
    
    //address
    reg [31:0] i_addr0_0; //RAM base addr
    wire [31:0] i_addr0_1 = i_addr0_0 + w_ifm;
    wire [31:0] i_addr0_2 = i_addr0_1 + w_ifm;
    wire [31:0] i_addr1_0 = i_addr0_0 + in2D_size;
    wire [31:0] i_addr1_1 = i_addr1_0 + w_ifm;
    wire [31:0] i_addr1_2 = i_addr1_1 + w_ifm;
    wire [31:0] i_addr2_0 = i_addr1_0 + in2D_size;
    wire [31:0] i_addr2_1 = i_addr2_0 + w_ifm;
    wire [31:0] i_addr2_2 = i_addr2_1 + w_ifm;

    //shift left/right addr
    wire [31:0] i_sl_addr0_0 = i_addr0_0 + 3;
    wire [31:0] i_sl_addr0_1 = i_addr0_1 + 3;
    wire [31:0] i_sl_addr0_2 = i_addr0_2 + 3;
    wire [31:0] i_sl_addr1_0 = i_addr1_0 + 3;
    wire [31:0] i_sl_addr1_1 = i_addr1_1 + 3;
    wire [31:0] i_sl_addr1_2 = i_addr1_2 + 3;
    wire [31:0] i_sl_addr2_0 = i_addr2_0 + 3;
    wire [31:0] i_sl_addr2_1 = i_addr2_1 + 3;
    wire [31:0] i_sl_addr2_2 = i_addr2_2 + 3;
    
    wire [31:0] i_sr_addr0_0 = i_addr0_0 - 1;
    wire [31:0] i_sr_addr0_1 = i_addr0_1 - 1;
    wire [31:0] i_sr_addr0_2 = i_addr0_2 - 1;
    wire [31:0] i_sr_addr1_0 = i_addr1_0 - 1;
    wire [31:0] i_sr_addr1_1 = i_addr1_1 - 1;
    wire [31:0] i_sr_addr1_2 = i_addr1_2 - 1;
    wire [31:0] i_sr_addr2_0 = i_addr2_0 - 1;
    wire [31:0] i_sr_addr2_1 = i_addr2_1 - 1;
    wire [31:0] i_sr_addr2_2 = i_addr2_2 - 1;
    
    //shift down left -> right addr
    wire [31:0] i_sdlr_addr0 = i_addr0_2 + w_ifm;
    wire [31:0] i_sdlr_addr1 = i_addr1_2 + w_ifm;
    wire [31:0] i_sdlr_addr2 = i_addr2_2 + w_ifm;

    //shift down right -> left addr
    wire [31:0] i_sdrl_addr0 = i_addr0_2 + w_ifm + 2;
    wire [31:0] i_sdrl_addr1 = i_addr1_2 + w_ifm + 2;
    wire [31:0] i_sdrl_addr2 = i_addr2_2 + w_ifm + 2;

    wire [31:0] i_p_addr0 = i_addr0_0;
    wire [31:0] i_p_addr1 = i_addr0_1;
    wire [31:0] i_p_addr2 = i_addr0_2;

    reg [31:0] ps_addr0;
    wire [31:0] ps_addr1, ps_addr2;
    assign ps_addr1[1:0] = ps_addr0[1:0];
    assign ps_addr2[1:0] = ps_addr1[1:0];
    assign ps_addr1[31:2] = ps_addr0[31:2] + out2D_size;
    assign ps_addr2[31:2] = ps_addr1[31:2] + out2D_size;
    
    reg [31:0] o_addr0;
    wire [31:0] o_addr1 = o_addr0 + out2D_size;
    wire [31:0] o_addr2 = o_addr1 + out2D_size;
    reg [3:0] o_quant_sel;
    
    reg [31:0] kw_addr0_0;
    wire [31:0] kw_addr0_1 = kw_addr0_0 + 9;
    wire [31:0] kw_addr0_2 = kw_addr0_1 + 9;
    wire [31:0] kw_addr1 = kw_addr0_0 + weight_kernel_width;
    wire [31:0] kw_addr1_0 = kw_addr0_0 + kernel3D_size;
    wire [31:0] kw_addr1_1 = kw_addr1_0 + 9;
    wire [31:0] kw_addr1_2 = kw_addr1_1 + 9;
    wire [31:0] kw_addr2 = kw_addr1 + weight_kernel_width;
    wire [31:0] kw_addr2_0 = kw_addr1_0 + kernel3D_size;
    wire [31:0] kw_addr2_1 = kw_addr2_0 + 9;
    wire [31:0] kw_addr2_2 = kw_addr2_1 + 9;
    

    reg [31:0] bp_addr0;
    
    reg is_out_done;
    
    //pre calculate address
    reg [15:0] w_ifm_x_h_stride_left;

    always @* begin
        w_ifm_x_h_stride_left = 1;
        case (h_stride) 
            4'd1: w_ifm_x_h_stride_left = kernel3D_size + 1;
            4'd2: w_ifm_x_h_stride_left = kernel3D_size + 1 + w_ifm;
            4'd3: w_ifm_x_h_stride_left = kernel3D_size + 1 + w_ifm + w_ifm;
        endcase
    end

    reg [15:0] w_ifm_x_padding;
    reg [15:0] w_ifm_x_kernel_height_left;
    always @* begin
        w_ifm_x_padding = 0;
        case (kernel3D_size)
            4'd1: w_ifm_x_padding = w_ifm;
            4'd2: w_ifm_x_padding = w_ifm + w_ifm;
        endcase 
    end

    // jump = (kernel_w - 1) x w_ifm + k + pad
    always @* begin
        w_ifm_x_kernel_height_left = 0;
        case (weight_kernel_width) 
            4'd1: w_ifm_x_kernel_height_left = kernel3D_size + 1 + w_ifm_x_padding;
            4'd2: w_ifm_x_kernel_height_left = kernel3D_size + 1 + w_ifm_x_padding + w_ifm;
            4'd3: w_ifm_x_kernel_height_left = kernel3D_size + 1 + w_ifm_x_padding + w_ifm + w_ifm;
        endcase
    end

    //counter
    reg [4:0] cnt,stride_cnt;
    reg [4:0] valid_pixel_cnt, valid_pixel_cnt_next;
    wire [4:0] max_stride_cnt = (x_in < weight_kernel_width) ? weight_kernel_width : w_stride;

    reg [4:0] valid_pixel_iter_cnt;
    
    localparam CONV = 4'd0, POOLING = 4'd1, DENSE = 4'd2;
    
    //FSM transitions
    localparam GL_BEGIN = 4'd0,
               GL_WREAD = 4'd1,
               GL_WLOAD = 4'd2,
               GL_BPREAD = 4'd3,
               GL_PSREAD = 4'd4,
               GL_BPLOAD = 4'd5,
               GL_IREAD = 4'd6,
               GL_ILOAD = 4'd7,
               GL_WAIT = 4'd8,
               GL_DONE = 4'd9;
    
    localparam WREAD_0 = 4'd0,
               WREAD_1 = 4'd1,
               WREAD_2 = 4'd2,
               WLOAD_0 = 4'd3,
               WLOAD_1 = 4'd4,
               WLOAD_2 = 4'd5;
    
    localparam I_BEGIN = 4'd0,
               I_LEFT = 4'd1,
               I_RIGHT = 4'd2,
               I_DOWN_LEFT_RIGHT = 4'd3,     
               I_DOWN_RIGHT_LEFT = 4'd4,
               I_LEFT_DONE = 4'd5,
               I_RIGHT_DONE = 4'd6;          
    
    localparam NON = 4'd0,
               LEFT = 4'd1,
               RIGHT = 4'd2,
               DOWN = 4'd3;
    
    always @* begin
        is_out_done = 0;
        case (cfg_layer_type) 
            CONV: is_out_done = (z_kw_in + 3 >= kernel_ifm_depth) ? 1 : 0;
            POOLING: is_out_done = 1;
            DENSE: is_out_done = (x_in + 9 >= weight_kernel_width) ? 1 : 0;
        endcase
    end
               
    always @(posedge clk) begin
        if (reset) begin
            read_g_state <= GL_BEGIN;
            read_weight_state <= WREAD_0;
            read_input_state <= I_BEGIN;
        end
        else if (enb) begin
            case (cfg_layer_type) 
                CONV: begin
                    case (read_g_state)
                        GL_BEGIN: begin
                            read_g_state <= GL_WREAD;
                            read_weight_state <= WREAD_0;
                            read_input_state <= I_BEGIN;
                        end
                        
                        GL_WREAD: begin
                            if (cnt >= 8 && mem_read_state) begin
                                if (mem_read_ready) begin
                                    read_g_state <= GL_WLOAD;
                                    case (read_weight_state) 
                                        WREAD_0: read_weight_state <= WLOAD_0;  
                                        WREAD_1: read_weight_state <= WLOAD_1;
                                        WREAD_2: read_weight_state <= WLOAD_2;
                                        default: read_weight_state <= WREAD_0;  
                                    endcase
                                end
                            end
                        end
                        
                        GL_WLOAD: begin
                            if (cnt >= 2) begin
                                case (read_weight_state)
                                    WLOAD_0: begin
                                        read_g_state <= GL_WREAD;
                                        read_weight_state <= WREAD_1;
                                    end
                                    
                                    WLOAD_1: begin
                                        read_g_state <= GL_WREAD;
                                        read_weight_state <= WREAD_2;
                                    end
                                    
                                    WLOAD_2: begin
                                        if (z_kw_in < 3) read_g_state <= GL_BPREAD;
                                        else read_g_state <= GL_PSREAD;
                                        
                                        read_weight_state <= WREAD_0;
                                    end
                                    
                                endcase
                            end
                        end
                        
                        GL_BPREAD, GL_PSREAD: begin
                            if (cnt >= 2 && mem_read_state && mem_read_ready) read_g_state <= GL_BPLOAD; 
                        end
                        
                        GL_BPLOAD: begin
                            if (read_input_state == I_LEFT || read_input_state == I_RIGHT) begin
                                if (valid_pixel_cnt < 9) begin //(not in buffer -> read from RAM)
                                    read_g_state <= GL_IREAD;
                                end
                                else read_g_state <= GL_ILOAD;
                            end
                            else read_g_state <= GL_IREAD;
                        end
                        
                        GL_IREAD: begin
                            if (mem_read_state) begin
                                if (mem_read_ready) begin
                                    case (read_input_state) 
                                        I_BEGIN: begin //read 9 ifm
                                            if (cnt >= 17) read_g_state <= GL_ILOAD;
                                        end
                                        
                                        I_LEFT, I_RIGHT: begin
                                            if (valid_pixel_iter_cnt >= 9) read_g_state <= GL_ILOAD;
                                        end
                                        
                                        I_DOWN_LEFT_RIGHT, I_DOWN_RIGHT_LEFT: begin
                                            if (cnt >= 5) read_g_state <= GL_ILOAD;
                                        end
                                        
                                    endcase
                                end
                            end
                        end
                        
                        GL_ILOAD: begin
                            case (read_input_state) 
                                I_BEGIN: begin
                                    if (cnt >= 2) begin
                                        read_input_state <= I_LEFT;
                                        read_g_state <= GL_WAIT;
                                    end
                                end
                                
                                I_LEFT: begin
                                    if (stride_cnt >= w_stride - 1) begin
                                        if (x_in + weight_kernel_width + w_stride  >= w_ifm) begin
                                            if (y_in + weight_kernel_height >= h_ifm) begin
                                                read_input_state <= I_LEFT_DONE;
                                            end
                                            else begin
                                                read_input_state <= I_DOWN_RIGHT_LEFT;
                                            end
                                        end
                                        read_g_state <= GL_WAIT;
                                    end
                                    else begin
                                        if (valid_pixel_cnt_next < 9) read_g_state <= GL_IREAD;
                                        else read_g_state <= GL_ILOAD;
                                    end
                                end
                                
                                I_DOWN_LEFT_RIGHT: begin
                                    if (stride_cnt >= h_stride - 1) begin
                                        read_input_state <= I_LEFT;
                                        read_g_state <= GL_WAIT;
                                    end
                                    else read_g_state <= GL_IREAD;
                                end
                                
                                I_RIGHT: begin
                                    if (stride_cnt >= w_stride - 1) begin
                                        if (x_in <= w_stride) begin
                                            if (y_in + weight_kernel_height >= h_ifm) begin
                                                read_input_state <= I_RIGHT_DONE;
                                            end
                                            else begin
                                                read_input_state <= I_DOWN_LEFT_RIGHT;
                                            end
                                        end
                                        read_g_state <= GL_WAIT;
                                    end
                                    else begin
                                        if (valid_pixel_cnt_next < 9) read_g_state <= GL_IREAD;
                                        else read_g_state <= GL_ILOAD;
                                    end
                                end
                                
                                I_DOWN_RIGHT_LEFT: begin
                                    if (stride_cnt >= h_stride - 1) begin
                                        read_input_state <= I_RIGHT;
                                        read_g_state <= GL_WAIT;
                                    end
                                    else read_g_state <= GL_IREAD;
                                end
                                
                            endcase
                        end
                        
                        GL_WAIT: begin
                            if (read_ready && (comp_ready || comp_start) && (wb_ready || wb_start)) begin
                                if (read_input_state == I_LEFT_DONE || read_input_state == I_RIGHT_DONE) begin
                                    read_input_state <= I_BEGIN;
                                    if (z_kw_in + 3 >= kernel_ifm_depth && z_kw_num_out + 3 >=  out_total_kernel_ofm_depth ) begin
                                        read_g_state <= GL_DONE;
                                    end
                                    else read_g_state <= GL_WREAD;
                                end
                                else begin
                                    if (z_kw_in < 3) read_g_state <= GL_BPLOAD;
                                    else read_g_state <= GL_PSREAD;
                                end
                            end
                        end
                    endcase
                end
                POOLING: begin
                    case (read_g_state) 
                        GL_BEGIN: read_g_state <= GL_IREAD;

                        GL_IREAD: begin
                            if (mem_read_state) begin
                                if (mem_read_ready) begin
                                    if (x_in == 0) begin //at the begin
                                        if (cnt >= weight_kernel_height - 1) begin 
                                            read_g_state <= GL_ILOAD;
                                        end
                                    end
                                    else begin //middle
                                        if (valid_pixel_iter_cnt >= weight_kernel_height) begin
                                            read_g_state <= GL_ILOAD;
                                        end 
                                    end
                                end
                            end
                        end

                        GL_ILOAD: begin
                            if (stride_cnt >= max_stride_cnt - 1) begin
                                read_g_state <= GL_WAIT;
                            end
                            else begin
                                if (valid_pixel_cnt_next < weight_kernel_height) read_g_state <= GL_IREAD;
                                else read_g_state <= GL_ILOAD;
                            end
                        end

                        GL_WAIT: begin
                            if (read_ready && (comp_ready || comp_start) && (wb_ready || wb_start)) begin
                                if (z_kw_in >= kernel_ifm_depth) read_g_state <= GL_DONE;
                                else begin
                                    if (x_in == 0) read_g_state <= GL_IREAD;
                                    else begin
                                        if (valid_pixel_cnt < weight_kernel_height) read_g_state <= GL_IREAD;
                                        else read_g_state <= GL_ILOAD;
                                    end
                                end
                            end
                        end
                    endcase
                end
                DENSE: begin
                    case (read_g_state) 
                        GL_BEGIN: read_g_state <= GL_IREAD;

                        GL_IREAD: begin
                            if (cnt >= 2) begin
                                if (mem_read_state) begin
                                    if (mem_read_ready) read_g_state <= GL_ILOAD;
                                end
                            end
                        end

                        GL_ILOAD: begin
                            if (cnt >= 2) begin
                                if (x_in < 9) read_g_state <= GL_BPREAD;
                                else read_g_state <= GL_PSREAD;
                            end 
                        end

                        GL_BPREAD, GL_PSREAD: begin
                            if (cnt >= 2) begin
                                if (mem_read_state) begin
                                    if (mem_read_ready) read_g_state <= GL_BPLOAD;
                                end
                            end
                        end

                        GL_BPLOAD: read_g_state <= GL_WREAD;

                        GL_WREAD: begin
                            if (cnt >= 8) begin
                                if (mem_read_state) begin
                                    if (mem_read_ready) read_g_state <= GL_WLOAD;
                                end
                            end
                        end

                        GL_WLOAD: if (cnt >= 2) read_g_state <= GL_WAIT;

                        GL_WAIT: begin
                            if (read_ready && (comp_ready || comp_start) && (wb_ready || wb_start)) begin
                                if (x_out + 3 >= weight_kernel_height) begin
                                    if (x_in + 9 >= weight_kernel_width) read_g_state <= GL_DONE;
                                    else read_g_state <= GL_IREAD;
                                end
                                else begin
                                    if (x_in < 9) read_g_state <= GL_BPREAD;
                                    else read_g_state <= GL_PSREAD;
                                end
                            end
                        end

                    endcase
                end

            endcase
        end
    end
    
    reg [31:0] process_ps_addr;
    reg [31:0] process_o_addr;
    reg [31:0] process_quant_sel;
    
    //control sigs           
    always @(posedge clk) begin
        if (reset) begin
            stride_cnt <= 0;
            x_in <= 0;
            y_in <= 0;
            x_out <= 0;
            y_out <= 0;
            x_kw <= 0;
            y_kw <= 0;
            z_kw_in <= 0;
            z_kw_num_out <= 0;
            
            i_addr0_0 <= 0;
            bp_addr0 <= 0;
            ps_addr0 <= 0;
            o_addr0 <= 0;
            kw_addr0_0 <= 0;
            o_quant_sel <= 0;
            
            process_ps_addr <= 0;
            process_o_addr <= 0;
            process_quant_sel <= 0;
            

            cnt <= 0;
            mem_read_state <= 0;
        end
        else if (enb) begin
            case (cfg_layer_type) 
                CONV: begin
                    case (read_g_state) 
                        GL_BEGIN: begin
                            cnt <= 0;
                            stride_cnt <= 0;

                            x_in <= 0;
                            y_in <= 0;
                            x_out <= 0;
                            y_out <= 0;
                            x_kw <= 0;
                            y_kw <= 0;
                            z_kw_in <= 0;
                            z_kw_num_out <= 0;

                            bp_addr0 <= bp_base_addr;
                            kw_addr0_0 <= kw_base_addr;
                            ps_addr0 <= ps_base_addr;
                            o_quant_sel <= 1;
                            i_addr0_0 <= i_base_addr;
                            o_addr0 <= o_base_addr;

                            mem_read_state <= 0;
                        end
                        
                        GL_WREAD: begin
                            if (mem_read_state) begin
                                if (mem_read_ready) begin
                                    if (cnt < 8) cnt <= cnt + 1;        
                                    else cnt <= 0;
                                    mem_read_state <= ~mem_read_state;
                                end
                            end      
                            else mem_read_state <= ~mem_read_state;
                        end
                        
                        GL_WLOAD: begin
                            if (cnt < 2) cnt <= cnt + 1;
                            else cnt <= 0;
                        end
                        
                        GL_BPREAD, GL_PSREAD: begin
                            if (mem_read_state) begin
                                if (mem_read_ready) begin
                                    if (cnt < 2) cnt <= cnt + 1;
                                    else cnt <= 0;
                                    mem_read_state <= ~mem_read_state;
                                end
                            end
                            else mem_read_state <= ~mem_read_state;
                        end
                        
                        GL_BPLOAD: begin
                            if (read_input_state == I_LEFT || read_input_state == I_RIGHT) begin
                                if (valid_pixel_cnt < 9) begin
                                    cnt <= valid_pixel_cnt;
                                end
                            end
                        end
                        
                        GL_IREAD: begin
                            if (mem_read_state) begin
                                if (mem_read_ready) begin
                                    case (read_input_state) 
                                        I_BEGIN: begin
                                            if (cnt < 17) begin
                                                if (ibuf_conv_wstrb < 2) cnt <= cnt + 2;
                                                else cnt <= cnt + 1;
                                            end
                                            else cnt <= 0;
                                        end 
                                        
                                        I_LEFT, I_RIGHT: begin
                                            if (valid_pixel_iter_cnt < 9) cnt <= valid_pixel_iter_cnt;
                                            else cnt <= 0;
                                        end
                                        
                                        I_DOWN_LEFT_RIGHT, I_DOWN_RIGHT_LEFT: begin
                                            if (cnt >= 5) begin
                                                cnt <= 0;
                                            end
                                            else begin
                                                if (ibuf_conv_wstrb < 2) cnt <= cnt + 2;
                                                else cnt <= cnt + 1;
                                            end
                                        end
                                        
                                    endcase
                                    mem_read_state <= ~mem_read_state;
                                end
                            end
                            else mem_read_state <= ~mem_read_state;
                        end
                        
                        GL_ILOAD: begin
                            process_ps_addr <= ps_addr0;
                            process_quant_sel <= o_quant_sel;
                            process_o_addr <= o_addr0;
                            case (read_input_state) 
                                I_BEGIN: begin
                                    if (cnt < 2) begin
                                        cnt <= cnt + 1;
                                    end
                                    else begin
                                        ps_addr0[31:2] <= ps_addr0[31:2] + 1;
                                        if (is_out_done) o_addr0 <= o_addr0 + 1;
                                        cnt <= 0;
                                    end
                                end
                                
                                I_LEFT: begin
                                    x_in <= x_in + 1;
                                    i_addr0_0 <= i_addr0_0 + 1;
                                    if (stride_cnt >= w_stride - 1) begin
                                        x_out <= x_out + 1;
                                        stride_cnt <= 0;
                                        if (x_in + weight_kernel_width + w_stride >= w_ifm) begin //done left
                                            if (y_in + weight_kernel_height >= h_ifm) begin //done down
                                                if (z_kw_in + 3 >= kernel_ifm_depth) begin //done 3 kernel
                                                    ps_addr0 <= ps_base_addr;
                                                    if (is_out_done) begin
                                                        o_addr0 <= o_addr2 + 1;
                                                        o_quant_sel <= o_quant_sel + 1;
                                                    end    
                                                    
                                                end
                                                else begin //done 1 kernel
                                                    ps_addr0[31:2] <= ps_addr0[31:2] - out2D_size + 1;
                                                end
                                            end
                                            else begin //not done down 
                                                ps_addr0[31:2] <= ps_addr0[31:2] + w_ofm;
                                                if (is_out_done) o_addr0 <= o_addr0 +  w_ofm;
                                            end
                                        end
                                        else begin
                                            ps_addr0[31:2] <= ps_addr0[31:2] + 1;
                                            if (is_out_done) o_addr0 <= o_addr0 +  1;
                                        end
                                    end
                                    else begin
                                        if (valid_pixel_cnt_next < 9) cnt <= valid_pixel_cnt_next;

                                        stride_cnt <= stride_cnt + 1;
                                    end
                                end
                                
                                I_RIGHT: begin
                                    x_in <= x_in - 1;
                                    i_addr0_0 <= i_addr0_0 - 1;
                                    if (stride_cnt >= w_stride - 1) begin
                                        x_out <= x_out - 1;
                                        stride_cnt <= 0;
                                        if (x_in <= w_stride) begin //done right
                                            if (y_in + weight_kernel_height >= h_ifm) begin //done down
                                                if (z_kw_in + 3 >= kernel_ifm_depth) begin //done 3 kernel
                                                    ps_addr0 <= ps_base_addr;
                                                    if (is_out_done) begin
                                                        o_addr0 <= o_addr2 + w_ofm;
                                                        o_quant_sel <= o_quant_sel + 1;
                                                    end    
                                                    
                                                end
                                                else begin //done 1 kernel
                                                    ps_addr0[31:2] <= ps_addr0[31:2] - out2D_size + 1;
                                                end
                                            end
                                            else begin //not done down
                                                ps_addr0[31:2] <= ps_addr0[31:2] + w_ofm;
                                                if (is_out_done) o_addr0 <= o_addr0 +  w_ofm;
                                            end
                                        end
                                        else begin
                                            ps_addr0[31:2] <= ps_addr0[31:2] - 1;
                                            if (is_out_done) o_addr0 <= o_addr0 - 1;
                                        end
                                    end
                                    else begin
                                        if (valid_pixel_cnt_next < 9) begin
                                            cnt <= valid_pixel_cnt_next;
                                        end
                                        stride_cnt <= stride_cnt + 1;
                                    end
                                end
                                
                                I_DOWN_RIGHT_LEFT: begin
                                    y_in <= y_in + 1;
                                    i_addr0_0 <= i_addr0_0 + w_ifm;
                                    if (stride_cnt >= h_stride - 1) begin
                                        y_out <= y_out + 1;
                                        ps_addr0[31:2] <= ps_addr0[31:2] - 1;
                                        if (is_out_done && stride_cnt >= h_stride - 1) begin
                                            o_addr0 <= o_addr0 - 1;
                                        end
                                        stride_cnt <= 0;
                                    end
                                    else begin
                                        stride_cnt <= stride_cnt + 1;
                                    end
                                end
                                
                                I_DOWN_LEFT_RIGHT: begin
                                    y_in <= y_in + 1;
                                    i_addr0_0 <= i_addr0_0 + w_ifm;
                                    if (stride_cnt >= h_stride - 1) begin
                                        y_out <= y_out + 1;
                                        ps_addr0[31:2] <= ps_addr0[31:2] + 1;
                                        if (is_out_done) begin
                                            o_addr0 <= o_addr0 + 1;
                                        end
                                        stride_cnt <= 0;
                                    end
                                    else stride_cnt <= stride_cnt + 1;
                                end  
                            endcase
                        end
                        
                        GL_WAIT: begin
                            if (read_ready && (comp_ready || comp_start) && (wb_ready || wb_start)) begin
                                if (read_input_state == I_LEFT_DONE || read_input_state == I_RIGHT_DONE) begin
                                    x_in <= 0;
                                    y_in <= 0;
                                    x_out <= 0;
                                    y_out <= 0;
                                    
                                    if (z_kw_in < 3) begin
                                        bp_addr0 <= bp_addr0 + 12;
                                    end
                                    
                                    if (z_kw_in + 3 >= kernel_ifm_depth) begin
                                        z_kw_in <= 0;
                                        z_kw_num_out <= z_kw_num_out + 3;
                                        i_addr0_0 <= i_base_addr;
                                        kw_addr0_0 <= kw_addr2_2 + 9;
                                    end 
                                    else begin
                                        z_kw_in <= z_kw_in + 3;
                                        kw_addr0_0 <= kw_addr0_2 + 9;
                                        if (read_input_state == I_LEFT_DONE) begin
                                            i_addr0_0 <= i_addr2_2 + weight_kernel_width;
                                        end
                                        else begin
                                            i_addr0_0 <= i_addr2_2 + w_ifm;
                                        end
                                    end
                                end
                            end    
                        end
                    endcase    
                end

                POOLING: begin
                    case (read_g_state) 
                        GL_BEGIN: begin
                            cnt <= 0;
                            stride_cnt <= 0;

                            x_in <= 0;
                            y_in <= 0;
                            
                            i_addr0_0 <= i_base_addr;
                            o_addr0 <= o_base_addr;

                            mem_read_state <= 0;
                        end

                        GL_IREAD: begin
                            if (mem_read_state) begin
                                if (mem_read_ready) begin
                                    if (x_in == 0) begin
                                        if (cnt < weight_kernel_width) cnt <= cnt + 1;
                                        else cnt <= 0;
                                    end
                                    else begin
                                        if (valid_pixel_iter_cnt < weight_kernel_width) cnt <= valid_pixel_iter_cnt;
                                        else cnt <= 0;
                                    end
                                    mem_read_state <= ~mem_read_state;
                                end
                            end
                            else mem_read_state <= ~mem_read_state;
                        end

                        GL_ILOAD: begin
                            process_o_addr <= o_addr0;
                            if (stride_cnt >= max_stride_cnt - 1) begin
                                o_addr0 <= o_addr0 + 1;
                                stride_cnt <= 0;

                                if (x_in + w_stride >= w_ifm) begin
                                    if (y_in + h_stride + weight_kernel_height > h_ifm) begin
                                        x_in <= 0;
                                        y_in <= 0;
                                        z_kw_in <= z_kw_in + 1;
                                        i_addr0_0 <= i_addr0_0 + w_ifm_x_kernel_height_left;
                                    end
                                    else begin
                                        x_in <= 0;
                                        y_in <= y_in + h_stride;
                                        i_addr0_0 <= i_addr0_0 + w_ifm_x_h_stride_left;
                                    end
                                end
                                else begin
                                    x_in <= x_in + 1;
                                    i_addr0_0 <= i_addr0_0 + 1;
                                end
                            end
                            else begin
                                x_in <= x_in + 1;
                                i_addr0_0 <= i_addr0_0 + 1;
                                stride_cnt <= stride_cnt + 1;

                                if (valid_pixel_cnt_next < 3) cnt <= valid_pixel_cnt_next;
                                else cnt <= 0;
                            end
                        end

                        GL_WAIT: begin
                            if (x_in == 0) cnt <= 0;
                            else begin
                                if (valid_pixel_cnt < 3) cnt <= valid_pixel_cnt;
                                else cnt <= 0;
                            end
                        end

                    endcase
                end

                DENSE: begin
                    case (read_g_state)
                        GL_BEGIN: begin
                            x_in <= 0;
                            x_out <= 0;
                            kw_addr0_0 <= kw_base_addr;
                            i_addr0_0 <= i_base_addr;
                            bp_addr0 <= bp_base_addr;
                            ps_addr0 <= ps_base_addr;
                            o_addr0 <= o_base_addr;
                            o_quant_sel <= 1;
                            cnt <= 0;
                            mem_read_state <= 0;
                        end

                        GL_IREAD, GL_BPREAD, GL_PSREAD: begin
                            if (mem_read_state) begin
                                if (mem_read_ready) begin
                                    if (cnt >= 2) cnt <= 0;
                                    else cnt <= cnt + 1;
                                    mem_read_state <= ~mem_read_state;
                                end
                            end
                            else mem_read_state = ~mem_read_state;
                        end

                        GL_ILOAD: begin
                            if (cnt >= 2) cnt <= 0;
                            else cnt <= cnt + 1;
                        end

                        GL_BPLOAD: begin end

                        GL_WREAD: begin
                            if (mem_read_state) begin
                                if (mem_read_ready) begin
                                    if (cnt >= 8) cnt <= 0;
                                    else cnt <= cnt + 1;
                                    mem_read_state <= ~mem_read_state;
                                end
                            end
                            else mem_read_state = ~mem_read_state;
                        end

                        GL_WLOAD: begin
                            process_o_addr <= o_addr0;
                            process_ps_addr <= ps_addr0;
                            process_quant_sel <= o_quant_sel;
                            if (cnt >= 2) begin
                                cnt <= 0;
                                if (x_out + 3 >= weight_kernel_height) ps_addr0 <= ps_base_addr;
                                else ps_addr0 <= ps_addr0 + 12;
                                if (is_out_done) o_addr0 <= o_addr0 + 3;
                            end
                            else cnt <= cnt + 1;
                        end

                        GL_WAIT: begin
                            if (read_ready && (comp_ready || comp_start) && (wb_ready || wb_start)) begin
                                if (x_in < 9) bp_addr0 <= bp_addr0 + 12;
                                if (x_out + 3 >= weight_kernel_height) begin
                                    x_out <= 0;
                                    x_in <= x_in + 9;
                                    kw_addr0_0 <= kw_addr2  + weight_kernel_width - kernel3D_size + 9;
                                    i_addr0_0 <= i_addr0_0 + 9;
                                end
                                else begin
                                    x_out <= x_out + 3;
                                    kw_addr0_0 <= kw_addr2 + weight_kernel_width;
                                end
                            end
                        end
                    endcase
                end
            endcase
        end
    end
    
    //output signal      
    always @* begin
        mem_read_enb = 0;
        mem_read_addr = 0;
        
        wbuf_enb = 0;
        wbuf_bank_sel = 0;
        wbuf_wstrb = 0;
        wbuf_ld = 0;
        wdemux = 0;
        wreg_enb = 0;
        
        bpbuf_ld = 0;
        bpbuf_enb = 0;
        
        acc_matrix_enb = 0;
        acc_matrix_bp_ld = 0;
        
        pe_matrix_conv_dir = 0;
        
        ibuf_conv_wstrb = 0;
        ibuf_dense_wstrb = 0;
        ibuf_di_reverse = 0;
        ibuf_do_reverse = 0;
        ibuf_ld = 0;
        ibuf_bank_sel = 0;
        ibuf_enb = 0;
        ibuf_conv_fi_load = 0;
        ibuf_conv_se_load = 0;
        
        idemux = 0;
        ireg_enb = 0;
        
        read_ready = 0;
        read_done = 0;

        compare_clear = 0;
        compare_enb = 0;
        
        case (cfg_layer_type) 
            CONV: begin
                case (read_g_state) 
                    GL_WREAD: begin
                        mem_read_enb = 1;
                            case (cnt) 
                                4'd0: begin
                                   case (read_weight_state)
                                       WREAD_0: mem_read_addr = kw_addr0_0;
                                       WREAD_1: mem_read_addr = kw_addr0_1;
                                       WREAD_2: mem_read_addr = kw_addr0_2;
                                   endcase
                                end
                                
                                4'd1: begin
                                   case (read_weight_state)
                                       WREAD_0: mem_read_addr = kw_addr0_0 + 4;
                                       WREAD_1: mem_read_addr = kw_addr0_1 + 4;
                                       WREAD_2: mem_read_addr = kw_addr0_2 + 4;
                                   endcase
                                end
                                
                                4'd2: begin
                                   case (read_weight_state)
                                       WREAD_0: mem_read_addr = kw_addr0_0 + 8;
                                       WREAD_1: mem_read_addr = kw_addr0_1 + 8;
                                       WREAD_2: mem_read_addr = kw_addr0_2 + 8;
                                   endcase
                                end
                                
                                4'd3: begin
                                   case (read_weight_state)
                                       WREAD_0: mem_read_addr = kw_addr1_0;
                                       WREAD_1: mem_read_addr = kw_addr1_1;
                                       WREAD_2: mem_read_addr = kw_addr1_2;
                                   endcase
                                end
                                
                                4'd4: begin
                                   case (read_weight_state)
                                       WREAD_0: mem_read_addr = kw_addr1_0 + 4;
                                       WREAD_1: mem_read_addr = kw_addr1_1 + 4;
                                       WREAD_2: mem_read_addr = kw_addr1_2 + 4;
                                   endcase
                                end
                                
                                4'd5: begin
                                   case (read_weight_state)
                                       WREAD_0: mem_read_addr = kw_addr1_0 + 8;
                                       WREAD_1: mem_read_addr = kw_addr1_1 + 8;
                                       WREAD_2: mem_read_addr = kw_addr1_2 + 8;
                                   endcase
                                end
                                
                                4'd6: begin
                                   case (read_weight_state)
                                       WREAD_0: mem_read_addr = kw_addr2_0;
                                       WREAD_1: mem_read_addr = kw_addr2_1;
                                       WREAD_2: mem_read_addr = kw_addr2_2;
                                   endcase
                                end
                                
                                4'd7: begin
                                   case (read_weight_state)
                                       WREAD_0: mem_read_addr = kw_addr2_0 + 4;
                                       WREAD_1: mem_read_addr = kw_addr2_1 + 4;
                                       WREAD_2: mem_read_addr = kw_addr2_2 + 4;
                                   endcase
                                end
                                
                                4'd8: begin
                                   case (read_weight_state)
                                       WREAD_0: mem_read_addr = kw_addr2_0 + 8;
                                       WREAD_1: mem_read_addr = kw_addr2_1 + 8;
                                       WREAD_2: mem_read_addr = kw_addr2_2 + 8;
                                   endcase
                                end
                            endcase

                        if (mem_read_state) begin                            
                            if (mem_read_ready) begin
                                mem_read_enb = 0;
                                case (cnt) 
                                    4'd0: begin
                                        wbuf_enb[0] = 1;
                                        wbuf_ld[0] = 1;
                                        wbuf_bank_sel[1:0] = 1;
                                        case (read_weight_state)
                                            WREAD_0: wbuf_wstrb[1:0] = kw_addr0_0[1:0];
                                            WREAD_1: wbuf_wstrb[1:0] = kw_addr0_1[1:0];
                                            WREAD_2: wbuf_wstrb[1:0] = kw_addr0_2[1:0];
                                        endcase
                                    end
                                    
                                    4'd1: begin
                                        wbuf_enb[0] = 1;
                                        wbuf_ld[0] = 1;
                                        wbuf_bank_sel[1:0] = 2;
                                        case (read_weight_state)
                                            WREAD_0: wbuf_wstrb[1:0] = kw_addr0_0[1:0];
                                            WREAD_1: wbuf_wstrb[1:0] = kw_addr0_1[1:0];
                                            WREAD_2: wbuf_wstrb[1:0] = kw_addr0_2[1:0];
                                        endcase
                                    end
                                    
                                    4'd2: begin
                                        wbuf_enb[0] = 1;
                                        wbuf_ld[0] = 1;
                                        wbuf_bank_sel[1:0] = 3;
                                        case (read_weight_state)
                                            WREAD_0: wbuf_wstrb[1:0] = kw_addr0_0[1:0];
                                            WREAD_1: wbuf_wstrb[1:0] = kw_addr0_1[1:0];
                                            WREAD_2: wbuf_wstrb[1:0] = kw_addr0_2[1:0];
                                        endcase
                                    end
                                    
                                    4'd3: begin
                                        wbuf_enb[1] = 1;
                                        wbuf_ld[1] = 1;
                                        wbuf_bank_sel[3:2] = 1;
                                        case (read_weight_state)
                                            WREAD_0: wbuf_wstrb[3:2] = kw_addr1_0[1:0];
                                            WREAD_1: wbuf_wstrb[3:2] = kw_addr1_1[1:0];
                                            WREAD_2: wbuf_wstrb[3:2] = kw_addr1_2[1:0];
                                        endcase
                                    end
                                    
                                    4'd4: begin
                                        wbuf_enb[1] = 1;
                                        wbuf_ld[1] = 1;
                                        wbuf_bank_sel[3:2] = 2;
                                        case (read_weight_state)
                                            WREAD_0: wbuf_wstrb[3:2] = kw_addr1_0[1:0];
                                            WREAD_1: wbuf_wstrb[3:2] = kw_addr1_1[1:0];
                                            WREAD_2: wbuf_wstrb[3:2] = kw_addr1_2[1:0];
                                        endcase
                                    end
                                    
                                    4'd5: begin
                                        wbuf_enb[1] = 1;
                                        wbuf_ld[1] = 1;
                                        wbuf_bank_sel[3:2] = 3;
                                        case (read_weight_state)
                                            WREAD_0: wbuf_wstrb[3:2] = kw_addr1_0[1:0];
                                            WREAD_1: wbuf_wstrb[3:2] = kw_addr1_1[1:0];
                                            WREAD_2: wbuf_wstrb[3:2] = kw_addr1_2[1:0];
                                        endcase
                                    end
                                    
                                    4'd6: begin
                                        wbuf_enb[2] = 1;
                                        wbuf_ld[2] = 1;
                                        wbuf_bank_sel[5:4] = 1;
                                        case (read_weight_state)
                                            WREAD_0: wbuf_wstrb[5:4] = kw_addr2_0[1:0];
                                            WREAD_1: wbuf_wstrb[5:4] = kw_addr2_1[1:0];
                                            WREAD_2: wbuf_wstrb[5:4] = kw_addr2_2[1:0];
                                        endcase
                                    end
                                    
                                    4'd7: begin
                                        wbuf_enb[2] = 1;
                                        wbuf_ld[2] = 1;
                                        wbuf_bank_sel[5:4] = 2;
                                        case (read_weight_state)
                                            WREAD_0: wbuf_wstrb[5:4] = kw_addr2_0[1:0];
                                            WREAD_1: wbuf_wstrb[5:4] = kw_addr2_1[1:0];
                                            WREAD_2: wbuf_wstrb[5:4] = kw_addr2_2[1:0];
                                        endcase
                                    end
                                    
                                    4'd8: begin
                                        wbuf_enb[2] = 1;
                                        wbuf_ld[2] = 1;
                                        wbuf_bank_sel[5:4] = 3;
                                        case (read_weight_state)
                                            WREAD_0: wbuf_wstrb[5:4] = kw_addr2_0[1:0];
                                            WREAD_1: wbuf_wstrb[5:4] = kw_addr2_1[1:0];
                                            WREAD_2: wbuf_wstrb[5:4] = kw_addr2_2[1:0];
                                        endcase
                                    end
                                endcase
                            end
                        end                    
                    end
                    
                    GL_WLOAD: begin
                        wbuf_ld = 3'b000;
                        wbuf_enb = 3'b111;
                        case (cnt)
                            4'd0: begin
                                wdemux = 0;
                                case (read_weight_state)
                                    WLOAD_0: wreg_enb[2:0] = 3'b111;
                                    WLOAD_1: wreg_enb[11:9] = 3'b111;
                                    WLOAD_2: wreg_enb[20:18] = 3'b111;
                                endcase
                            end
                            
                            4'd1: begin
                                wdemux = 1;
                                case (read_weight_state)
                                    WLOAD_0: wreg_enb[5:3] = 3'b111;
                                    WLOAD_1: wreg_enb[14:12] = 3'b111;
                                    WLOAD_2: wreg_enb[23:21] = 3'b111;
                                endcase
                            end

                            4'd2: begin
                                wdemux = 2;
                                case (read_weight_state)
                                    WLOAD_0: wreg_enb[8:6] = 3'b111;
                                    WLOAD_1: wreg_enb[17:15] = 3'b111;
                                    WLOAD_2: wreg_enb[26:24] = 3'b111;
                                endcase
                            end
                        endcase  
                    end
                    
                    GL_BPREAD: begin
                        mem_read_enb = 1;
                        case (cnt) 
                            4'd0: mem_read_addr = bp_addr0;
                            4'd1: mem_read_addr = bp_addr0 + 4;
                            4'd2: mem_read_addr = bp_addr0 + 8;
                        endcase
                        
                        if (mem_read_state) begin
                            if (mem_read_ready) begin
                                mem_read_enb = 0;
                                case (cnt)
                                    4'd0: begin
                                        bpbuf_enb[0] = 1;
                                        bpbuf_ld[0] = 1;
                                    end
                                    
                                    4'd1: begin
                                        bpbuf_enb[1] = 1;
                                        bpbuf_ld[1] = 1;
                                    end
                                    
                                    4'd2: begin
                                        bpbuf_enb[2] = 1;
                                        bpbuf_ld[2] = 1;
                                    end
                                endcase
                            end
                        end
                    end
                    
                    GL_PSREAD: begin
                        mem_read_enb = 1;
                        case (cnt) 
                            4'd0: mem_read_addr = ps_addr0;
                            4'd1: mem_read_addr = ps_addr1;
                            4'd2: mem_read_addr = ps_addr2;
                        endcase
                        
                        if (mem_read_state) begin
                            if (mem_read_ready) begin
                                mem_read_enb = 0;
                                case (cnt)
                                    4'd0: begin
                                        bpbuf_enb[0] = 1;
                                        bpbuf_ld[0] = 1;
                                    end
                                    
                                    4'd1: begin
                                        bpbuf_enb[1] = 1;
                                        bpbuf_ld[1] = 1;
                                    end
                                    
                                    4'd2: begin
                                        bpbuf_enb[2] = 1;
                                        bpbuf_ld[2] = 1;
                                    end
                                endcase
                            end
                        end
                    end
                    
                    GL_BPLOAD: begin
                       bpbuf_ld = 3'b000;
                       bpbuf_enb = 3'b111;
                       acc_matrix_enb = 1;
                       acc_matrix_bp_ld = 1;
                    end
                    
                    GL_IREAD: begin
                        mem_read_enb = 1;
                        case (read_input_state)
                            I_BEGIN: begin
                                case (cnt)
                                    5'd0: mem_read_addr = i_addr0_0;
                                    5'd1: mem_read_addr = i_addr0_0 + 4;
                                    5'd2: mem_read_addr = i_addr0_1;
                                    5'd3: mem_read_addr = i_addr0_1 + 4;
                                    5'd4: mem_read_addr = i_addr0_2;
                                    5'd5: mem_read_addr = i_addr0_2 + 4;
                                    5'd6: mem_read_addr = i_addr1_0;
                                    5'd7: mem_read_addr = i_addr1_0 + 4;
                                    5'd8: mem_read_addr = i_addr1_1;
                                    5'd9: mem_read_addr = i_addr1_1 + 4;
                                    5'd10: mem_read_addr = i_addr1_2;
                                    5'd11: mem_read_addr = i_addr1_2 + 4;
                                    5'd12: mem_read_addr = i_addr2_0;
                                    5'd13: mem_read_addr = i_addr2_0 + 4;
                                    5'd14: mem_read_addr = i_addr2_1;
                                    5'd15: mem_read_addr = i_addr2_1 + 4;
                                    5'd16: mem_read_addr = i_addr2_2;
                                    5'd17: mem_read_addr = i_addr2_2 + 4;
                                endcase
                            end
                                
                            I_LEFT: begin
                                case (cnt) 
                                    5'd0: mem_read_addr = i_sl_addr0_0;
                                    5'd1: mem_read_addr = i_sl_addr0_1;
                                    5'd2: mem_read_addr = i_sl_addr0_2;
                                    5'd3: mem_read_addr = i_sl_addr1_0;
                                    5'd4: mem_read_addr = i_sl_addr1_1;
                                    5'd5: mem_read_addr = i_sl_addr1_2;
                                    5'd6: mem_read_addr = i_sl_addr2_0;
                                    5'd7: mem_read_addr = i_sl_addr2_1;
                                    5'd8: mem_read_addr = i_sl_addr2_2;
                                endcase
                            end
                                
                            I_DOWN_LEFT_RIGHT: begin
                                case (cnt)
                                    5'd0: mem_read_addr = i_sdlr_addr0;
                                    5'd1: mem_read_addr = i_sdlr_addr0 + 4;
                                    5'd2: mem_read_addr = i_sdlr_addr1;
                                    5'd3: mem_read_addr = i_sdlr_addr1 + 4;
                                    5'd4: mem_read_addr = i_sdlr_addr2;
                                    5'd5: mem_read_addr = i_sdlr_addr2 + 4;
                                endcase
                            end
                                
                            I_RIGHT: begin
                                case (cnt) 
                                    5'd0: mem_read_addr = i_sr_addr0_0;
                                    5'd1: mem_read_addr = i_sr_addr0_1;
                                    5'd2: mem_read_addr = i_sr_addr0_2;
                                    5'd3: mem_read_addr = i_sr_addr1_0;
                                    5'd4: mem_read_addr = i_sr_addr1_1;
                                    5'd5: mem_read_addr = i_sr_addr1_2;
                                    5'd6: mem_read_addr = i_sr_addr2_0;
                                    5'd7: mem_read_addr = i_sr_addr2_1;
                                    5'd8: mem_read_addr = i_sr_addr2_2;
                                endcase
                            end
                                
                            I_DOWN_RIGHT_LEFT: begin
                                case (cnt)
                                    5'd0: mem_read_addr = i_sdrl_addr0;
                                    5'd1: mem_read_addr = i_sdrl_addr0 - 4;
                                    5'd2: mem_read_addr = i_sdrl_addr1;
                                    5'd3: mem_read_addr = i_sdrl_addr1 - 4;
                                    5'd4: mem_read_addr = i_sdrl_addr2;
                                    5'd5: mem_read_addr = i_sdrl_addr2 - 4;
                                endcase
                            end
                        endcase

                        if (mem_read_state) begin
                            if (mem_read_ready) begin
                                mem_read_enb = 0;
                                case (read_input_state)
                                    I_BEGIN: begin
                                        case (cnt) 
                                            5'd0: begin
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 1;
                                                ibuf_conv_wstrb = {1'b0, i_addr0_0[1:0]};
                                            end
                                            
                                            5'd1: begin
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 1;
                                                ibuf_conv_wstrb = {1'b0, i_addr0_0[1:0]} + 3;
                                            end
                                            
                                            5'd2: begin
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 2;
                                                ibuf_conv_wstrb = {1'b0, i_addr0_1[1:0]};
                                            end
                                            
                                            5'd3: begin
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 2;
                                                ibuf_conv_wstrb = {1'b0, i_addr0_1[1:0]} + 3;
                                            end
                                            
                                            5'd4: begin
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_addr0_2[1:0]};
                                            end
                                            
                                            5'd5: begin
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_addr0_2[1:0]} + 3;
                                            end
                                            
                                            5'd6: begin
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 1;
                                                ibuf_conv_wstrb = {1'b0, i_addr1_0[1:0]};    
                                            end
                                            
                                            5'd7: begin
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 1;
                                                ibuf_conv_wstrb = {1'b0, i_addr1_0[1:0]} + 3;
                                            end
                                            
                                            5'd8: begin
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 2;
                                                ibuf_conv_wstrb = {1'b0, i_addr1_1[1:0]};
                                            end
                                            
                                            5'd9: begin
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 2;
                                                ibuf_conv_wstrb = {1'b0, i_addr1_1[1:0]} + 3;
                                            end
                                            
                                            5'd10: begin
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_addr1_2[1:0]};
                                            end
                                            
                                            5'd11: begin
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_addr1_2[1:0]} + 3;
                                            end
                                            
                                            5'd12: begin
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 1;
                                                ibuf_conv_wstrb = {1'b0, i_addr2_0[1:0]};    
                                            end
                                            
                                            5'd13: begin
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 1;
                                                ibuf_conv_wstrb = {1'b0, i_addr2_0[1:0]} + 3;
                                            end
                                            
                                            5'd14: begin
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 2;
                                                ibuf_conv_wstrb = {1'b0, i_addr2_1[1:0]};
                                            end
                                            
                                            5'd15: begin
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 2;
                                                ibuf_conv_wstrb = {1'b0, i_addr2_1[1:0]} + 3;
                                            end
                                            
                                            5'd16: begin
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_addr2_2[1:0]};
                                            end
                                            
                                            5'd17: begin
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_addr2_2[1:0]} + 3;
                                            end
                                        endcase
                                    end
                                    
                                    I_LEFT: begin
                                        case (cnt)
                                            5'd0: begin
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 1;
                                                ibuf_conv_wstrb = {1'b0, i_sl_addr0_0[1:0]};
                                            end
                                            
                                            5'd1: begin
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 2;
                                                ibuf_conv_wstrb = {1'b0, i_sl_addr0_1[1:0]};
                                            end
                                            
                                            5'd2: begin
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_sl_addr0_2[1:0]};
                                            end
                                            
                                            5'd3: begin
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 1;
                                                ibuf_conv_wstrb = {1'b0, i_sl_addr1_0[1:0]};
                                            end
                                            
                                            5'd4: begin
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 2;
                                                ibuf_conv_wstrb = {1'b0, i_sl_addr1_1[1:0]};
                                            end
                                            
                                            5'd5: begin
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_sl_addr1_2[1:0]};
                                            end
                                            
                                            5'd6: begin
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 1;
                                                ibuf_conv_wstrb = {1'b0, i_sl_addr2_0[1:0]};
                                            end
                                            
                                            5'd7: begin
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 2;
                                                ibuf_conv_wstrb = {1'b0, i_sl_addr2_1[1:0]};
                                            end
                                            
                                            5'd8: begin
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_sl_addr2_2[1:0]};
                                            end
                                        endcase
                                    end
                                    
                                    I_DOWN_LEFT_RIGHT: begin
                                        case (cnt)
                                            5'd0: begin
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_sdlr_addr0[1:0]};
                                            end
                                            
                                            5'd1: begin
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_sdlr_addr0[1:0]} + 3;
                                            end
                                            
                                            5'd2: begin
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_sdlr_addr1[1:0]};
                                            end
                                            
                                            5'd3: begin
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_sdlr_addr1[1:0]} + 3;
                                            end
                                            
                                            5'd4: begin
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_sdlr_addr2[1:0]};
                                            end
                                            
                                            5'd5: begin
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 3;
                                                ibuf_conv_wstrb = {1'b0, i_sdlr_addr2[1:0]} + 3;
                                            end  
                                        endcase
                                    end
                                    
                                    I_RIGHT: begin
                                        case (cnt)
                                            5'd0: begin
                                                ibuf_di_reverse[0] = 1;
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 1;
                                                ibuf_conv_wstrb = {1'b0, ~i_sr_addr0_0[1:0]};
                                            end
                                            
                                            5'd1: begin
                                                ibuf_di_reverse[0] = 1;
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 2;
                                                ibuf_conv_wstrb = {1'b0, ~i_sr_addr0_1[1:0]};
                                            end
                                            
                                            5'd2: begin
                                                ibuf_di_reverse[0] = 1;
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 3;
                                                ibuf_conv_wstrb = {1'b0, ~i_sr_addr0_2[1:0]};
                                            end
                                            
                                            5'd3: begin
                                                ibuf_di_reverse[1] = 1;
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 1;
                                                ibuf_conv_wstrb = {1'b0, ~i_sr_addr1_0[1:0]};
                                            end
                                            
                                            5'd4: begin
                                                ibuf_di_reverse[1] = 1;
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 2;
                                                ibuf_conv_wstrb = {1'b0, ~i_sr_addr1_1[1:0]};
                                            end
                                            
                                            5'd5: begin
                                                ibuf_di_reverse[1] = 1;
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 3;
                                                ibuf_conv_wstrb = {1'b0, ~i_sr_addr1_2[1:0]};
                                            end
                                            
                                            5'd6: begin
                                                ibuf_di_reverse[2] = 1;
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 1;
                                                ibuf_conv_wstrb = {1'b0, ~i_sr_addr2_0[1:0]};
                                            end
                                            
                                            5'd7: begin
                                                ibuf_di_reverse[2] = 1;
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 2;
                                                ibuf_conv_wstrb = {1'b0, ~i_sr_addr2_1[1:0]};
                                            end
                                            
                                            5'd8: begin
                                                ibuf_di_reverse[2] = 1;
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 3;
                                                ibuf_conv_wstrb = {1'b0, ~i_sr_addr2_2[1:0]};
                                            end
                                            
                                        endcase
                                    end
                                    
                                    I_DOWN_RIGHT_LEFT: begin
                                        case (cnt) 
                                            5'd0: begin
                                                ibuf_di_reverse[0] = 1;
                                                ibuf_do_reverse[0] = 1;
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 3;
                                                ibuf_conv_wstrb = {1'b0, ~i_sdrl_addr0[1:0]};
                                            end
                                            
                                            5'd1: begin
                                                ibuf_di_reverse[0] = 1;
                                                ibuf_do_reverse[0] = 1;
                                                ibuf_enb[0] = 1;
                                                ibuf_ld[0] = 1;
                                                ibuf_bank_sel[1:0] = 3;
                                                ibuf_conv_wstrb = {1'b0, ~i_sdrl_addr0[1:0]} + 3;
                                            end
                                            
                                            5'd2: begin
                                                ibuf_di_reverse[1] = 1;
                                                ibuf_do_reverse[1] = 1;
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 3;
                                                ibuf_conv_wstrb = {1'b0, ~i_sdrl_addr1[1:0]};
                                            end
                                            
                                            5'd3: begin
                                                ibuf_di_reverse[1] = 1;
                                                ibuf_do_reverse[1] = 1;
                                                ibuf_enb[1] = 1;
                                                ibuf_ld[1] = 1;
                                                ibuf_bank_sel[3:2] = 3;
                                                ibuf_conv_wstrb = {1'b0, ~i_sdrl_addr1[1:0]} + 3;
                                            end
                                            
                                            5'd4: begin
                                                ibuf_di_reverse[2] = 1;
                                                ibuf_do_reverse[2] = 1;
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 3;
                                                ibuf_conv_wstrb = {1'b0, ~i_sdrl_addr2[1:0]};
                                            end
                                            
                                            5'd5: begin
                                                ibuf_di_reverse[2] = 1;
                                                ibuf_do_reverse[2] = 1;
                                                ibuf_enb[2] = 1;
                                                ibuf_ld[2] = 1;
                                                ibuf_bank_sel[5:4] = 3;
                                                ibuf_conv_wstrb = {1'b0, ~i_sdrl_addr2[1:0]} + 3;
                                            end
                                        endcase
                                    end                                
                                endcase
                            end
                        end
                    end
                    
                    GL_ILOAD: begin
                        ibuf_enb = 3'b111;
                        ibuf_ld = 3'b000;
                        case (read_input_state) 
                            I_BEGIN: begin
                                pe_matrix_conv_dir = NON;
                                case (cnt) 
                                    5'd0: begin
                                        idemux = 0;
                                        {ireg_enb[0], ireg_enb[3], ireg_enb[6]} = 3'b111;
                                    end
                                    
                                    5'd1: begin
                                        idemux = 1;
                                        {ireg_enb[1], ireg_enb[4], ireg_enb[7]} = 3'b111;
                                    end
                                    
                                    5'd2: begin
                                        idemux = 2;
                                        {ireg_enb[2], ireg_enb[5], ireg_enb[8]} = 3'b111;
                                    end
                                endcase
                            end
                            
                            I_LEFT: begin
                                pe_matrix_conv_dir = LEFT;
                                idemux = 0;
                                ireg_enb = 9'b111111111;
                            end
                            
                            I_DOWN_LEFT_RIGHT: begin
                                pe_matrix_conv_dir = DOWN;
                                idemux = 0;
                                ireg_enb = 9'b111111111;
                                ibuf_conv_se_load = (h_stride == 2);
                                ibuf_conv_fi_load = (stride_cnt == h_stride - 1);
                            end
                            
                            I_RIGHT: begin
                                pe_matrix_conv_dir = RIGHT;
                                idemux = 0;
                                ireg_enb = 9'b111111111;
                            end
                            
                            I_DOWN_RIGHT_LEFT: begin
                                pe_matrix_conv_dir = DOWN;
                                idemux = 0;
                                ireg_enb = 9'b111111111;
                                ibuf_di_reverse = 3'b111;
                                ibuf_do_reverse = 3'b111;
                                ibuf_conv_se_load = (h_stride == 2);
                                ibuf_conv_fi_load = (stride_cnt == h_stride - 1);
                            end
                        endcase
                    end
                    
                    GL_WAIT: read_ready = 1;
                    
                    GL_DONE: read_done = 1;
                endcase
            end

            POOLING: begin
                case (read_g_state)
                    GL_IREAD: begin
                        mem_read_enb = 1;
                        case (cnt)
                            5'd0: mem_read_addr = i_p_addr0;
                            5'd1: mem_read_addr = i_p_addr1;
                            5'd2: mem_read_addr = i_p_addr2;
                        endcase
                        if (mem_read_state) begin
                            if (mem_read_ready) begin
                                mem_read_enb = 0;
                                case (cnt) 
                                    5'd0: begin
                                        ibuf_enb[0] = 1;
                                        ibuf_ld[0] = 1;
                                        ibuf_bank_sel[1:0] = 2'd1;
                                        ibuf_conv_wstrb = {1'b0, i_p_addr0[1:0]};
                                    end

                                    5'd1: begin
                                        ibuf_enb[0] = 1;
                                        ibuf_ld[0] = 1;
                                        ibuf_bank_sel[1:0] = 2'd2;
                                        ibuf_conv_wstrb = {1'b0, i_p_addr1[1:0]};
                                    end

                                    5'd2: begin
                                        ibuf_enb[0] = 1;
                                        ibuf_ld[0] = 1;
                                        ibuf_bank_sel[1:0] = 2'd3;
                                        ibuf_conv_wstrb = {1'b0, i_p_addr2[1:0]};
                                    end
                                endcase
                            end
                        end
                    end

                    GL_ILOAD: begin
                        ibuf_enb[0] = 1;
                        ibuf_ld[0] = 0;
                        compare_clear = 0;
                        compare_enb = 1;
                    end
                    
                    GL_WAIT: begin
                        compare_enb = 1;
                        compare_clear = 1;
                        read_ready = 1;
                    end

                    GL_DONE: begin
                        read_done = 1;
                    end

                endcase
            end

            DENSE: begin
                case (read_g_state) 
                    GL_IREAD: begin
                        mem_read_enb = 1;
                        case (cnt) 
                            4'd0: mem_read_addr = i_addr0_0;
                            4'd1: mem_read_addr = i_addr0_0 + 4;
                            4'd2: mem_read_addr = i_addr0_0 + 8;
                        endcase
                        if (mem_read_state) begin
                            if (mem_read_ready) begin
                                mem_read_enb = 0;
                                ibuf_enb[0] = 1;
                                ibuf_ld[0] = 1;
                                case (cnt) 
                                    4'd0: begin
                                        ibuf_bank_sel[1:0] = 1;
                                        ibuf_dense_wstrb = kw_addr0_0[1:0];
                                    end

                                    4'd1: begin
                                        ibuf_bank_sel[1:0] = 2;
                                        ibuf_dense_wstrb = kw_addr0_0[1:0];
                                    end

                                    4'd2: begin
                                        ibuf_bank_sel[1:0] = 3;
                                        ibuf_dense_wstrb = kw_addr0_0[1:0];
                                    end
                                endcase
                            end
                        end
                    end

                    GL_ILOAD: begin
                        ibuf_enb[0] = 1;
                        ibuf_ld[0] = 0;
                        pe_matrix_conv_dir = NON;
                        case (cnt) 
                            5'd0: begin
                                idemux = 0;
                                ireg_enb[0] = 1;
                            end

                            5'd1: begin
                                idemux = 1;
                                ireg_enb[1] = 1;
                            end

                            5'd2: begin
                                idemux = 2;
                                ireg_enb[2] = 1;
                            end
                        endcase
                    end

                    GL_BPREAD: begin
                        mem_read_enb = 1;
                        case (cnt) 
                            4'd0: mem_read_addr = bp_addr0;
                            4'd1: mem_read_addr = bp_addr0 + 4;
                            4'd2: mem_read_addr = bp_addr0 + 8;
                        endcase
                        if (mem_read_state) begin
                            if (mem_read_ready) begin
                                mem_read_enb = 0;
                                case (cnt) 
                                    4'd0: begin
                                        bpbuf_enb[0] = 1;
                                        bpbuf_ld[0] = 1;
                                    end

                                    4'd1: begin
                                        bpbuf_enb[1] = 1;
                                        bpbuf_ld[1] = 1;
                                    end

                                    4'd2: begin
                                        bpbuf_enb[2] = 1;
                                        bpbuf_ld[2] = 1;
                                    end
                                endcase
                            end
                        end
                    end

                    GL_PSREAD: begin
                        mem_read_enb = 1;
                        case (cnt) 
                            4'd0: mem_read_addr = ps_addr0;
                            4'd1: mem_read_addr = ps_addr0 + 4;
                            4'd2: mem_read_addr = ps_addr0 + 8;
                        endcase
                        if (mem_read_state) begin
                            if (mem_read_ready) begin
                                mem_read_enb = 0;
                                case (cnt) 
                                    4'd0: begin
                                        bpbuf_enb[0] = 1;
                                        bpbuf_ld[0] = 1;
                                    end

                                    4'd1: begin
                                        bpbuf_enb[1] = 1;
                                        bpbuf_ld[1] = 1;
                                    end

                                    4'd2: begin
                                        bpbuf_enb[2] = 1;
                                        bpbuf_ld[2] = 1;
                                    end
                                endcase
                            end
                        end
                    end
                    
                    GL_BPLOAD: begin
                        bpbuf_enb = 3'b111;
                        bpbuf_ld = 3'b000;
                        acc_matrix_enb = 1;
                        acc_matrix_bp_ld = 1;
                    end
                    
                    GL_WREAD: begin
                        mem_read_enb = 1;
                        case (cnt)
                            4'd0: mem_read_addr = kw_addr0_0;
                            4'd1: mem_read_addr = kw_addr0_0 + 4;
                            4'd2: mem_read_addr = kw_addr0_0 + 8;
                            4'd3: mem_read_addr = kw_addr1;
                            4'd4: mem_read_addr = kw_addr1 + 4;
                            4'd5: mem_read_addr = kw_addr1 + 8;
                            4'd6: mem_read_addr = kw_addr2;
                            4'd7: mem_read_addr = kw_addr2 + 4;
                            4'd8: mem_read_addr = kw_addr2 + 8;
                        endcase
                        if (mem_read_state) begin
                            if (mem_read_ready) begin
                                mem_read_enb = 0;
                                case (cnt)
                                    4'd0: begin
                                        wbuf_enb[0] = 1;
                                        wbuf_ld[0] = 1;
                                        wbuf_bank_sel[1:0] = 1;
                                        wbuf_wstrb[1:0] = kw_addr0_0[1:0];
                                    end

                                    4'd1: begin
                                        wbuf_enb[0] = 1;
                                        wbuf_ld[0] = 1;
                                        wbuf_bank_sel[1:0] = 2;
                                        wbuf_wstrb[1:0] = kw_addr0_0[1:0];
                                    end

                                    4'd2: begin
                                        wbuf_enb[0] = 1;
                                        wbuf_ld[0] = 1;
                                        wbuf_bank_sel[1:0] = 3;
                                        wbuf_wstrb[1:0] = kw_addr0_0[1:0];
                                    end

                                    4'd3: begin
                                        wbuf_enb[1] = 1;
                                        wbuf_ld[1] = 1;
                                        wbuf_bank_sel[3:2] = 1;
                                        wbuf_wstrb[3:2] = kw_addr1[1:0];
                                    end

                                    4'd4: begin
                                        wbuf_enb[1] = 1;
                                        wbuf_ld[1] = 1;
                                        wbuf_bank_sel[3:2] = 2;
                                        wbuf_wstrb[3:2] = kw_addr1[1:0];
                                    end

                                    4'd5: begin
                                        wbuf_enb[1] = 1;
                                        wbuf_ld[1] = 1;
                                        wbuf_bank_sel[3:2] = 3;
                                        wbuf_wstrb[3:2] = kw_addr1[1:0];
                                    end

                                    4'd6: begin
                                        wbuf_enb[2] = 1;
                                        wbuf_ld[2] = 1;
                                        wbuf_bank_sel[5:4] = 1;
                                        wbuf_wstrb[5:4] = kw_addr2[1:0];
                                    end

                                    4'd7: begin
                                        wbuf_enb[2] = 1;
                                        wbuf_ld[2] = 1;
                                        wbuf_bank_sel[5:4] = 2;
                                        wbuf_wstrb[5:4] = kw_addr2[1:0];
                                    end

                                    4'd8: begin
                                        wbuf_enb[2] = 1;
                                        wbuf_ld[2] = 1;
                                        wbuf_bank_sel[5:4] = 3;
                                        wbuf_wstrb[5:4] = kw_addr2[1:0];
                                    end
                                endcase
                            end
                        end
                    end

                    GL_WLOAD: begin
                        wbuf_enb = 3'b111;
                        wbuf_ld = 3'b000;
                        case (cnt) 
                            4'd0: begin
                                wdemux = 0;
                                wreg_enb[2:0] = 3'b111;
                            end

                            4'd1: begin
                                wdemux = 1;
                                wreg_enb[5:3] = 3'b111;
                            end

                            4'd2: begin
                                wdemux = 2;
                                wreg_enb[8:6] = 3'b111;
                            end
                        endcase
                    end

                    GL_WAIT: read_ready = 1;

                    GL_DONE: read_done = 1;
                endcase
            end
        endcase
    end      
    
    //count valid pixel
    always @* begin
        valid_pixel_cnt = 0;
        if (ibuf_0_valid[0]) begin
            valid_pixel_cnt = 1;
            if (ibuf_0_valid[1]) begin
                valid_pixel_cnt = 2;
                if (ibuf_0_valid[2]) begin
                    valid_pixel_cnt = 3;
                    if (ibuf_1_valid[0]) begin
                        valid_pixel_cnt = 4;
                        if (ibuf_1_valid[1]) begin
                            valid_pixel_cnt = 5;
                            if (ibuf_1_valid[2]) begin
                                valid_pixel_cnt = 6;
                                if (ibuf_2_valid[0]) begin
                                    valid_pixel_cnt = 7;
                                    if (ibuf_2_valid[1]) begin
                                        valid_pixel_cnt = 8;
                                        if (ibuf_2_valid[2]) begin
                                            valid_pixel_cnt = 9;
                                        end
                                    end
                                end
                            end        
                        end
                    end
                end
            end
        end
    end
    
    //count next valid pixel
    always @* begin
        valid_pixel_cnt_next = 0;
        if (ibuf_0_valid_next[0]) begin
            valid_pixel_cnt_next = 1;
            if (ibuf_0_valid_next[1]) begin
                valid_pixel_cnt_next = 2;
                if (ibuf_0_valid_next[2]) begin
                    valid_pixel_cnt_next = 3;
                    if (ibuf_1_valid_next[0]) begin
                        valid_pixel_cnt_next = 4;
                        if (ibuf_1_valid_next[1]) begin
                            valid_pixel_cnt_next = 5;
                            if (ibuf_1_valid_next[2]) begin
                                valid_pixel_cnt_next = 6;
                                if (ibuf_2_valid_next[0]) begin
                                    valid_pixel_cnt_next = 7;
                                    if (ibuf_2_valid_next[1]) begin
                                        valid_pixel_cnt_next = 8;
                                        if (ibuf_2_valid_next[2]) begin
                                            valid_pixel_cnt_next = 9;
                                        end
                                    end
                                end
                            end        
                        end
                    end
                end
            end
        end
    end
    
    //count valid pixel in cache
    always @* begin
        valid_pixel_iter_cnt = 0;
        case (cnt) 
            5'd0: begin
                valid_pixel_iter_cnt = 1;
                if (ibuf_0_valid[1]) begin
                    valid_pixel_iter_cnt = 2;
                    if (ibuf_0_valid[2]) begin
                        valid_pixel_iter_cnt = 3;
                        if (ibuf_1_valid[0]) begin
                            valid_pixel_iter_cnt = 4;
                            if (ibuf_1_valid[1]) begin
                                valid_pixel_iter_cnt = 5;
                                if (ibuf_1_valid[2]) begin
                                    valid_pixel_iter_cnt = 6;
                                    if (ibuf_2_valid[0]) begin
                                        valid_pixel_iter_cnt = 7;
                                        if (ibuf_2_valid[1]) begin
                                            valid_pixel_iter_cnt = 8;
                                            if (ibuf_2_valid[2]) begin
                                                valid_pixel_iter_cnt = 9;
                                            end
                                        end
                                    end
                                end        
                            end
                        end
                    end
                end
            end
            
            5'd1: begin
                valid_pixel_iter_cnt = 2;
                if (ibuf_0_valid[2]) begin
                    valid_pixel_iter_cnt = 3;
                    if (ibuf_1_valid[0]) begin
                        valid_pixel_iter_cnt = 4;
                        if (ibuf_1_valid[1]) begin
                            valid_pixel_iter_cnt = 5;
                            if (ibuf_1_valid[2]) begin
                                valid_pixel_iter_cnt = 6;
                                if (ibuf_2_valid[0]) begin
                                    valid_pixel_iter_cnt = 7;
                                    if (ibuf_2_valid[1]) begin
                                        valid_pixel_iter_cnt = 8;
                                        if (ibuf_2_valid[2]) begin
                                            valid_pixel_iter_cnt = 9;
                                        end
                                    end
                                end
                            end        
                        end
                    end
                end
            end
            
            5'd2: begin
                valid_pixel_iter_cnt = 3;
                if (ibuf_1_valid[0]) begin
                    valid_pixel_iter_cnt = 4;
                    if (ibuf_1_valid[1]) begin
                        valid_pixel_iter_cnt = 5;
                        if (ibuf_1_valid[2]) begin
                            valid_pixel_iter_cnt = 6;
                            if (ibuf_2_valid[0]) begin
                                valid_pixel_iter_cnt = 7;
                                if (ibuf_2_valid[1]) begin
                                    valid_pixel_iter_cnt = 8;
                                    if (ibuf_2_valid[2]) begin
                                        valid_pixel_iter_cnt = 9;
                                    end
                                end
                            end
                        end        
                    end
                end
            end
            
            5'd3: begin
                valid_pixel_iter_cnt = 4;
                if (ibuf_1_valid[1]) begin
                   valid_pixel_iter_cnt = 5;
                   if (ibuf_1_valid[2]) begin
                       valid_pixel_iter_cnt = 6;
                       if (ibuf_2_valid[0]) begin
                           valid_pixel_iter_cnt = 7;
                           if (ibuf_2_valid[1]) begin
                               valid_pixel_iter_cnt = 8;
                               if (ibuf_2_valid[2]) begin
                                   valid_pixel_iter_cnt = 9;
                               end
                           end
                       end
                   end        
                end
            end
            
            5'd4: begin
                valid_pixel_iter_cnt = 5;
                if (ibuf_1_valid[2]) begin
                    valid_pixel_iter_cnt = 6;
                    if (ibuf_2_valid[0]) begin
                        valid_pixel_iter_cnt = 7;
                        if (ibuf_2_valid[1]) begin
                            valid_pixel_iter_cnt = 8;
                            if (ibuf_2_valid[2]) begin
                                valid_pixel_iter_cnt = 9;
                            end
                        end
                    end
                end  
            end
            
            5'd5: begin
                valid_pixel_iter_cnt = 6;
                if (ibuf_2_valid[0]) begin
                    valid_pixel_iter_cnt = 7;
                    if (ibuf_2_valid[1]) begin
                        valid_pixel_iter_cnt = 8;
                        if (ibuf_2_valid[2]) begin
                            valid_pixel_iter_cnt = 9;
                        end
                    end
                end
            end
            
            5'd6: begin
                valid_pixel_iter_cnt = 7;
                if (ibuf_2_valid[1]) begin
                    valid_pixel_iter_cnt = 8;
                    if (ibuf_2_valid[2]) begin
                        valid_pixel_iter_cnt = 9;
                    end
                end
            end
            
            5'd7: begin
                valid_pixel_iter_cnt = 8;
                if (ibuf_2_valid[2]) begin
                    valid_pixel_iter_cnt = 9;
                end
            end
            
            5'd8: begin
                valid_pixel_iter_cnt = 9;
            end
            
        endcase
    end    

    //FF for next stage
    always @(posedge clk) begin
        if (reset) begin
            read_out_done <= 0;
            read_ps_addr <= 0;
            read_o_addr <= 0;
            read_o_quant_sel <= 0;
        end
        else begin
            if (read_ready && (comp_ready || comp_start) && (wb_ready || wb_start) && enb) begin
                read_out_done <= is_out_done;
                read_ps_addr <= process_ps_addr;
                read_o_addr <= process_o_addr;
                read_o_quant_sel <= process_quant_sel;
            end
        end    
    end

endmodule
