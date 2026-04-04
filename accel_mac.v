`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2026 08:16:52 PM
// Design Name: 
// Module Name: accel_mac
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


module accel_mac(
    input clk,
    input rstn,
    input enb,
    input [31:0] input_offset, 
    
    input [7:0] idi_0, idi_1, idi_2,
    input [7:0] wdi_0, wdi_1, wdi_2,

    output reg ready,
    output reg mac_load,
    output reg [31:0] mac_odo
);

    reg [7:0] mux_idi;
    reg [7:0] mux_wdi;

    reg [1:0] state;
    localparam IDLE = 2'd0,
               MAC0 = 2'd1,
               MAC1 = 2'd2,
               MAC2 = 2'd3;
    
    always @(*) begin
        case(state)
            IDLE: begin
                mux_idi = 0;
                mux_wdi = 0;
                mac_load = 1;
                ready = 0;
            end
        
            MAC0: begin 
                mux_idi = idi_0; 
                mux_wdi = wdi_0;
                mac_load = 0; 
                ready = 0;
            end 
            MAC1: begin
                mux_idi = idi_1; 
                mux_wdi = wdi_1; 
                mac_load = 0; 
                ready = 0;
            end 
            MAC2: begin 
                mux_idi = idi_2; 
                mux_wdi = wdi_2; 
                mac_load = 0; 
                ready = 1;
            end 
            default: begin 
                mux_idi = 0; 
                mux_wdi = 0; 
                mac_load = 0; 
                ready = 0;
            end
        endcase
    end

    wire signed [9:0] idi_add_off = $signed(mux_idi) + $signed(input_offset[8:0]);

    wire idi_sign = idi_add_off[9];
    wire wdi_sign = mux_wdi[7];

    wire [8:0] us_idi_9b = idi_sign ? -$signed(idi_add_off) : idi_add_off;
    wire [7:0] us_idi    = us_idi_9b[7:0]; // Chỉ lấy 8 bit đưa vào bộ nhân
    wire [7:0] us_wdi    = wdi_sign ? (~mux_wdi + 1'b1) : mux_wdi;
    
    wire [15:0] prod;
    M8_CP13_2 mult (
        .A(us_idi),
        .B(us_wdi),
        .P(prod)
    );

    wire prod_sign = idi_sign ^ wdi_sign;
    wire signed [31:0] final_prod = prod_sign ? -$signed({16'd0, prod}) : $signed({16'd0, prod});

    reg [31:0] acc;
    
    always @(posedge clk) begin
        if (!rstn) begin
            state <= IDLE;
            acc <= 32'd0;
            mac_odo <= 32'd0;
        end else if (enb) begin
            case (state)
                IDLE: begin
                    state <= MAC0;
                    mac_odo <= 0;
                end
                
                MAC0: begin
                    acc <= final_prod;
                    state <= MAC1;
                end
                
                MAC1: begin
                    acc <= acc + final_prod;
                    state <= MAC2;
                end
                
                MAC2: begin
                    mac_odo <= acc + final_prod;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
