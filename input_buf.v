`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 09:35:03 PM
// Design Name: 
// Module Name: input_buf
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


module input_buf(
        input clk,
        input reset,
        input enb,
        
        input [3:0] cfg_layer_type,
        input [1:0] ibuf_dense_wstrb,
        input [2:0] ibuf_conv_wstrb,
        
        input ibuf_di_reverse,
        input ibuf_do_reverse,
        input ibuf_ld,
        input [1:0] ibuf_bank_sel,


        input ibuf_conv_fi_load,
        input ibuf_conv_se_load,

        input [31:0] ibuf_di,

        output reg [7:0] ibuf_do_0,
        output reg [7:0] ibuf_do_1,
        output reg [7:0] ibuf_do_2,

        // Feedback Sigs
        output reg [ 2:0] ibuf_valid,
        output reg [ 2:0] ibuf_nxt_valid

    );
    
    localparam CONV = 4'd0, POOLING = 4'd1, DENSE = 4'd2;
    
    wire [31:0] ibuf_di_data;
    assign ibuf_di_data = ibuf_di_reverse ? {ibuf_di[7:0], ibuf_di[15:8], ibuf_di[23:16], ibuf_di[31:24]} : ibuf_di;
    
    reg [6*8-1:0] buf_b0_data;
    reg [6*8-1:0] buf_b1_data;
    reg [6*8-1:0] buf_b2_data;
    reg [5:0] buf_b0_valid;
    reg [5:0] buf_b1_valid;
    reg [5:0] buf_b2_valid;
    
    always @(posedge clk) begin
        if (reset) begin
            buf_b0_data <= 0;
            buf_b1_data <= 0;
            buf_b2_data <= 0;
            buf_b0_valid <= 0;
            buf_b1_valid <= 0;
            buf_b2_valid <= 0;
        end
        else if (enb) begin
            if (ibuf_ld) begin
                case (cfg_layer_type) 
                CONV, POOLING: begin
                    case (ibuf_bank_sel) 
                        2'd1: begin
                            case (ibuf_conv_wstrb) 
                                3'd0: begin
                                    buf_b0_data[31:0] <= ibuf_di_data;
                                    buf_b0_valid[3:0] <= 4'b1111;
                                    
                                    buf_b0_data[47:32] <= 0;
                                    buf_b0_valid[5:4] <= 0;
                                end
                                
                                3'd1: begin
                                    buf_b0_data[23:0] <= ibuf_di_data[31:8];
                                    buf_b0_valid[2:0] <= 3'b111;
                                    
                                    buf_b0_data[47:24] <= 0;
                                    buf_b0_valid[5:3] <= 0;
                                end
                                
                                3'd2: begin
                                    buf_b0_data[15:0] <= ibuf_di_data[31:16];
                                    buf_b0_valid[1:0] <= 2'b11;
                                    
                                    buf_b0_data[47:16] <= 0;
                                    buf_b0_valid[5:2] <= 0;
                                end
                                
                                3'd3: begin
                                    buf_b0_data[7:0] <= ibuf_di_data[31:23];
                                    buf_b0_valid[0] <= 1'b1;
                                    
                                    buf_b0_data[47:8] <= 0;
                                    buf_b0_valid[5:1] <= 0;
                                end
                                
                                3'd5: begin
                                    buf_b0_data[47:16] <= ibuf_di_data;
                                    buf_b0_valid[5:2] <= 4'b1111;
                                end
                                
                                3'd6: begin
                                    buf_b0_data[39:8] <= ibuf_di_data;
                                    buf_b0_valid[4:1] <= 4'b1111;
                                end
                            endcase
                        end
                        
                        2'd2: begin
                            case (ibuf_conv_wstrb) 
                                3'd0: begin
                                    buf_b1_data[31:0] <= ibuf_di_data;
                                    buf_b1_valid[3:0] <= 4'b1111;
                                    
                                    buf_b1_data[47:32] <= 0;
                                    buf_b1_valid[5:4] <= 0;
                                end
                                
                                3'd1: begin
                                    buf_b1_data[23:0] <= ibuf_di_data[31:8];
                                    buf_b1_valid[2:0] <= 3'b111;
                                    
                                    buf_b1_data[47:24] <= 0;
                                    buf_b1_valid[5:3] <= 0;
                                end
                                
                                3'd2: begin
                                    buf_b1_data[15:0] <= ibuf_di_data[31:16];
                                    buf_b1_valid[1:0] <= 2'b11;
                                    
                                    buf_b1_data[47:16] <= 0;
                                    buf_b1_valid[5:2] <= 0;
                                end
                                
                                3'd3: begin
                                    buf_b1_data[7:0] <= ibuf_di_data[31:23];
                                    buf_b1_valid[0] <= 1'b1;
                                    
                                    buf_b1_data[47:8] <= 0;
                                    buf_b1_valid[5:1] <= 0;
                                end
                                
                                3'd5: begin
                                    buf_b1_data[47:16] <= ibuf_di_data;
                                    buf_b1_valid[5:2] <= 4'b1111;
                                end
                                
                                3'd6: begin
                                    buf_b1_data[39:8] <= ibuf_di_data;
                                    buf_b1_valid[4:1] <= 4'b1111;
                                end
                            endcase
                        end
                        
                        2'd3: begin
                            case (ibuf_conv_wstrb) 
                                3'd0: begin
                                    buf_b2_data[31:0] <= ibuf_di_data;
                                    buf_b2_valid[3:0] <= 4'b1111;
                                    
                                    buf_b2_data[47:32] <= 0;
                                    buf_b2_valid[5:4] <= 0;
                                end
                                
                                3'd1: begin
                                    buf_b2_data[23:0] <= ibuf_di_data[31:8];
                                    buf_b2_valid[2:0] <= 3'b111;
                                    
                                    buf_b2_data[47:24] <= 0;
                                    buf_b2_valid[5:3] <= 0;
                                end
                                
                                3'd2: begin
                                    buf_b2_data[15:0] <= ibuf_di_data[31:16];
                                    buf_b2_valid[1:0] <= 2'b11;
                                    
                                    buf_b2_data[47:16] <= 0;
                                    buf_b2_valid[5:2] <= 0;
                                end
                                
                                3'd3: begin
                                    buf_b2_data[7:0] <= ibuf_di_data[31:23];
                                    buf_b2_valid[0] <= 1'b1;
                                    
                                    buf_b2_data[47:8] <= 0;
                                    buf_b2_valid[5:1] <= 0;
                                end
                                
                                3'd5: begin
                                    buf_b2_data[47:16] <= ibuf_di_data;
                                    buf_b2_valid[5:2] <= 4'b1111;
                                end
                                
                                3'd6: begin
                                    buf_b2_data[39:8] <= ibuf_di_data;
                                    buf_b2_valid[4:1] <= 4'b1111;
                                end
                            endcase
                        end
                    endcase         
                end       
                
                DENSE: begin
                    case (ibuf_bank_sel) 
                        2'd1: begin
                            case (ibuf_dense_wstrb)
                                2'd0: begin
                                    buf_b0_data[23:0] <= ibuf_di_data[23:0];
                                    buf_b1_data[7:0] <=  ibuf_di_data[31:24];
                                end       
                                
                                2'd1: begin
                                    buf_b0_data[23:0] <= ibuf_di_data[31:8];
                                end       
                                
                                2'd2: begin
                                    buf_b0_data[15:0] <= ibuf_di_data[31:16];
                                end
                                
                                2'd3: begin
                                    buf_b0_data[7:0] <= ibuf_di_data[31:23];
                                end           
                            endcase
                        end
                        
                        2'd2: begin
                            case (ibuf_dense_wstrb)
                                2'd0: begin
                                    buf_b1_data[23:8] <= ibuf_di_data[15:0];
                                    buf_b2_data[15:0] <= ibuf_di_data[31:16];
                                end
                                
                                2'd1: begin
                                    buf_b1_data[23:0] <= ibuf_di_data[23:0];
                                    buf_b2_data[7:0] <= ibuf_di_data[31:24];
                                end
                                
                                2'd2: begin
                                    buf_b0_data[23:16] <= ibuf_di_data[7:0];
                                    buf_b1_data[23:0] <= ibuf_di_data[31:8];
                                end
                                
                                2'd3: begin
                                    buf_b0_data[23:8] <= ibuf_di_data[15:0];
                                    buf_b1_data[15:0] <= ibuf_di_data[31:16];
                                end
                            endcase
                        end
                        
                        2'd3: begin
                            case (ibuf_dense_wstrb)
                                2'd0: begin
                                    buf_b2_data[23:16] <= ibuf_di_data[7:0]; 
                                end
                                
                                2'd1: begin
                                    buf_b2_data[23:8] <= ibuf_di_data[15:0];
                                end
                                
                                2'd2: begin
                                    buf_b2_data[23:0] <= ibuf_di_data[23:0];
                                end
                                
                                2'd3: begin
                                    buf_b1_data[23:16] <= ibuf_di_data[7:0];
                                    buf_b2_data[23:0] <= ibuf_di_data[31:8];
                                end
                            endcase
                        end
                        
                    endcase
                end
                             
                endcase
            end
        end
        
        else begin
            case (cfg_layer_type)
                CONV: begin 
                    if (ibuf_conv_se_load) begin
                        if (ibuf_conv_fi_load) begin
                            buf_b0_data[47:0] <= 0;
                            buf_b0_valid[5:0] <= 0;

                            buf_b1_data[23:0] <= buf_b1_data[47:24];
                            buf_b1_valid[2:0] <= buf_b1_valid[5:3];

                            buf_b1_data[47:24] <= 0;
                            buf_b1_valid[5:3] <= 0;

                            buf_b2_data[23:0] <= buf_b2_data[47:24];
                            buf_b2_valid[2:0] <= buf_b2_valid[5:3];

                            buf_b2_data[47:24] <= 0;
                            buf_b2_valid[5:3] <= 0;
                        end 
                        else begin
                            buf_b0_data[47:0] <= 0;
                            buf_b0_valid[5:0] <= 0;

                            buf_b1_data[47:24] <= buf_b2_data[47:24];
                            buf_b1_valid[5:3] <= buf_b2_valid[5:3];

                            buf_b1_data[23:0] <= 0;
                            buf_b1_valid[2:0] <= 0;

                            buf_b2_data[47:0] <= 0;
                            buf_b2_valid[5:0] <= 0;
                        end
                    end 
                    else begin
                        if (ibuf_conv_fi_load) begin
                            buf_b0_data[47:0] <= 0;
                            buf_b0_valid[5:0] <= 0;

                            buf_b1_data[47:0] <= 0;
                            buf_b1_valid[5:0] <= 0;

                            buf_b2_data[23:0] <= buf_b2_data[47:24];
                            buf_b2_valid[2:0] <= buf_b2_valid[5:3];

                            buf_b2_data[47:24] <= 0;
                            buf_b2_valid[5:3] <= 0;
                        end 
                        else begin
                            buf_b0_data[39:0] <= buf_b0_data[47:8];
                            buf_b0_data[47:40] <= 0;
                            buf_b0_valid[4:0] <= buf_b0_valid[ 5:1];
                            buf_b0_valid[5] <= 0;

                            buf_b1_data[39:0] <= buf_b1_data[ 47:  8];
                            buf_b1_data[47:40] <= 0;
                            buf_b1_valid[4:0] <= buf_b1_valid[ 5:  1];
                            buf_b1_valid[5] <= 0;

                            buf_b2_data[39:0] <= buf_b2_data[47:8];
                            buf_b2_data[47:40] <= 0;
                            buf_b2_valid[4:0] <= buf_b2_valid[5:1];
                            buf_b2_valid[5] <= 0;
                        end
                    end
                end 

                DENSE: begin
                    buf_b0_data[15: 0] <= buf_b0_data[23: 8];
                    buf_b0_data[23:16] <= 0; 

                    buf_b1_data[15: 0] <= buf_b1_data[23: 8];
                    buf_b1_data[23:16] <= 0; 

                    buf_b2_data[15: 0] <= buf_b2_data[23: 8];
                    buf_b2_data[23:16] <= 0; 
                end

                POOLING: begin
                    buf_b0_data[39:0] <= buf_b0_data[47:8];
                    buf_b0_data[47:40] <= 0;
                    buf_b0_valid[4:0] <= buf_b0_valid[5:1];
                    buf_b0_valid[5] <= 0;

                    buf_b1_data[39:0] <= buf_b1_data[47:8];
                    buf_b1_data[47:40] <= 0;
                    buf_b1_valid[4:0] <= buf_b1_valid[5:1];
                    buf_b1_valid[5] <= 0;

                    buf_b2_data[39:0] <= buf_b2_data[47:8];
                    buf_b2_data[47:40] <= 0;
                    buf_b2_valid[4:0] <= buf_b2_valid[5:1];
                    buf_b2_valid[5] <= 0;
                end
                endcase
        end
    end 
    
    always @(*) begin
        ibuf_do_0 = 0;
        ibuf_do_1 = 0;
        ibuf_do_2 = 0;
        ibuf_valid = 0;
        ibuf_nxt_valid  = 0;
        case (cfg_layer_type)
            CONV: begin 
                if (ibuf_conv_se_load || ibuf_conv_fi_load) begin
                    if (ibuf_do_reverse) begin
                        ibuf_do_0 = buf_b2_data[23:16];
                        ibuf_do_1 = buf_b2_data[15:8];
                        ibuf_do_2 = buf_b2_data[7:0];
                        ibuf_valid = {buf_b2_valid[0], buf_b2_valid[1], buf_b2_valid[2]};
                    end
                    else begin
                        ibuf_do_0 = buf_b2_data[7:0];
                        ibuf_do_1 = buf_b2_data[15:8];
                        ibuf_do_2 = buf_b2_data[23:16];
                        ibuf_valid = buf_b2_valid[2:0];   
                    end
                end 
                else begin
                    ibuf_do_0 = buf_b0_data[7:0];
                    ibuf_do_1 = buf_b1_data[7:0];
                    ibuf_do_2 = buf_b2_data[7:0];
                    ibuf_valid = {buf_b2_valid[0], buf_b1_valid[0], buf_b0_valid[0]};
                    ibuf_nxt_valid = {buf_b2_valid[1], buf_b1_valid[1], buf_b0_valid[1]};
                end
            end 

            DENSE: begin
                ibuf_do_0 = buf_b0_data[7:0];
                ibuf_do_1 = buf_b1_data[7:0];
                ibuf_do_2 = buf_b2_data[7:0];
            end

            POOLING: begin
                ibuf_do_0 = buf_b0_data[7:0];
                ibuf_do_1 = buf_b1_data[7:0];
                ibuf_do_2 = buf_b2_data[7:0];
                ibuf_valid = {buf_b2_valid[0], buf_b1_valid[0], buf_b0_valid[0]};
                ibuf_nxt_valid = {buf_b2_valid[1], buf_b1_valid[1], buf_b0_valid[1]};
            end
        endcase        
    end
endmodule
