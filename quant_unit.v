`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2026 09:01:23 PM
// Design Name: 
// Module Name: quant_unit
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


module quant_unit(
        input clk,
        input resetn,
        input enb,
        
        // data sigs
        input   [31:0]  quant_di,
        input   [ 7:0]  quant_rshift,

        // LUT
        input [63:0] quant_val_0,
        input [63:0] quant_val_1,
        input [63:0] quant_val_2,
        input [63:0] quant_val_3,
        input [63:0] quant_val_4,
        input [63:0] quant_val_5,
        input [63:0] quant_val_6,
        input [63:0] quant_val_7,
        input [63:0] quant_val_8,
        input [63:0] quant_val_9,
        input [63:0] quant_val_10,
        input [63:0] quant_val_11,
        input [63:0] quant_val_12,
        input [63:0] quant_val_13,
        input [63:0] quant_val_14,
        input [63:0] quant_val_15,
        
        output valid,
        output [31:0]  quant_do
    );
    
    wire quant_sdi;
    wire [63:0] quant_udi;
    reg [31:0] quant_di_reg;
    
    reg [63:0] quant_mul_result;
    reg [63:0] quant_mul_acc;
    reg [3:0] quant_sel;
    reg quant_load;

    reg  [3:0] state;

    wire [31:0] quant_shift_result;

    // Convert Signed to Unsigned
    assign  quant_sdi = quant_di_reg[31];
    assign  quant_udi = (quant_sdi) ? ~quant_di_reg + 1 : quant_di_reg;
    
    always @(posedge clk) begin
        if (!resetn) begin
            quant_di_reg <= 0;
        end 
        else if (enb) begin
            if (quant_load) begin
                quant_di_reg <= quant_di;
            end
        end
    end
    localparam LOAD   = 4'd0,
               STAGE1 = 4'd1,
               STAGE2 = 4'd2,
               STAGE3 = 4'd3,
               STAGE4 = 4'd4,
               STAGE5 = 4'd5,
               STAGE6 = 4'd6,
               STAGE7 = 4'd7,
               STAGE8 = 4'd8;

    always @(posedge clk) begin
        if (!resetn) 
            state <= LOAD;
        else if (enb) begin
            case(state) 
                LOAD   : state <= STAGE1;
                STAGE1 : state <= STAGE2;
                STAGE2 : state <= STAGE3;
                STAGE3 : state <= STAGE4;
                STAGE4 : state <= STAGE5;
                STAGE5 : state <= STAGE6;
                STAGE6 : state <= STAGE7;
                STAGE7 : state <= STAGE8;
                STAGE8 : state <= LOAD;
                default : state <= LOAD;
            endcase
        end
    end

    //Sel sig
    always @(*) begin
        case(quant_sel) 
            4'd0: quant_mul_acc = quant_val_0;
            4'd1: quant_mul_acc = quant_val_1;
            4'd2: quant_mul_acc = quant_val_2;
            4'd3: quant_mul_acc = quant_val_3;
            4'd4: quant_mul_acc = quant_val_4;
            4'd5: quant_mul_acc = quant_val_5;
            4'd6: quant_mul_acc = quant_val_6;
            4'd7: quant_mul_acc = quant_val_7;
            4'd8: quant_mul_acc = quant_val_8;
            4'd9: quant_mul_acc = quant_val_9;
            4'd10: quant_mul_acc = quant_val_10;
            4'd11: quant_mul_acc = quant_val_11;
            4'd12: quant_mul_acc = quant_val_12;
            4'd13: quant_mul_acc = quant_val_13;
            4'd14: quant_mul_acc = quant_val_14;
            4'd15: quant_mul_acc = quant_val_15;
        endcase
    end

    // FSM Behavior
    always @(*) begin
        quant_load = 1'd0;
        quant_sel = 4'd0;
        case (state)
            LOAD: quant_load = 1'd1;

            STAGE1: quant_sel = quant_udi[31:28]; 
                
            STAGE2: quant_sel = quant_udi[27:24]; 
                
            STAGE3: quant_sel = quant_udi[23:20]; 
            
            STAGE4: quant_sel = quant_udi[19:16]; 

            STAGE5: quant_sel = quant_udi[15:12]; 

            STAGE6: quant_sel = quant_udi[11:8]; 

            STAGE7: quant_sel = quant_udi[7:4]; 

            STAGE8: quant_sel = quant_udi[3:0];  
        endcase
    end

    // Store Data
    always @(posedge clk) begin
        if (!resetn) begin
            quant_mul_result <= 0;
        end 
        else if (enb) begin
            case(state) 
                LOAD   : quant_mul_result <= 64'h 000000000000000; 
                STAGE1 : quant_mul_result <= (quant_mul_acc + quant_mul_result) << 4;
                STAGE2 : quant_mul_result <= (quant_mul_acc + quant_mul_result) << 4;
                STAGE3 : quant_mul_result <= (quant_mul_acc + quant_mul_result) << 4;
                STAGE4 : quant_mul_result <= (quant_mul_acc + quant_mul_result) << 4;
                STAGE5 : quant_mul_result <= (quant_mul_acc + quant_mul_result) << 4;
                STAGE6 : quant_mul_result <= (quant_mul_acc + quant_mul_result) << 4;
                STAGE7 : quant_mul_result <= (quant_mul_acc + quant_mul_result) << 4;
                STAGE8 : quant_mul_result <= (quant_mul_acc + quant_mul_result);
            endcase
        end
    end

    // SaturatingRoundingDoublingHighMul 
    wire [63:0] quant_mul_result_saturating;
    assign quant_mul_result_saturating = quant_mul_result + 64'h000000040000000;

    wire [31:0] quant_himul_result;
    assign quant_himul_result = quant_mul_result_saturating[62:31];
    
    // RoundingDivideByPOT     
    wire [31:0] mask, remainder, threshold;

    assign mask = (1 << quant_rshift) - 1;
    assign remainder = quant_himul_result & mask;
    assign threshold = (mask >> 1);

    assign quant_shift_result = (remainder > threshold) ? ((quant_himul_result >> quant_rshift) + 1) : (quant_himul_result >> quant_rshift);

    // Output value
    assign quant_do = (quant_sdi) ? ~quant_shift_result + 1 : quant_shift_result;
    assign valid = (state == STAGE8);
endmodule
