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
    input rst,
    input enb,
    input [31:0] input_offset, 
    
    input [7:0] idi_0, idi_1, idi_2,
    input [7:0] wdi_0, wdi_1, wdi_2,

    output reg valid,
    output ready,
    output reg [31:0] mac_odo    
);

    reg [7:0] mux_idi;
    reg [7:0] mux_wdi;

    reg [1:0] state;
    localparam IDLE = 2'd0,
               MAC0 = 2'd1,
               MAC1 = 2'd2,
               MAC2 = 2'd3;
    
    assign ready = (state == IDLE);
    
    always @(*) begin
        case(state)
            MAC0: begin 
                mux_idi = idi_0; 
                mux_wdi = wdi_0; 
            end 
            MAC1: begin
                mux_idi = idi_1; 
                mux_wdi = wdi_1; 
            end 
            MAC2: begin 
                mux_idi = idi_2; 
                mux_wdi = wdi_2; 
            end 
            default: begin 
                mux_idi = idi_0; 
                mux_wdi = wdi_0; 
            end
        endcase
    end

    wire [7:0] idi_off = mux_idi + input_offset[7:0];
    wire [15:0] prod;
    
    M8_CP13_2 mult (
        .A(idi_off), 
        .B(mux_wdi), 
        .P(prod)
    );

    reg [31:0] acc;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            acc <= 32'd0;
            mac_odo <= 32'd0;
            valid <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    valid <= 1'b0;
                    if (enb) begin 
                        state <= MAC0;
                    end
                end
                
                MAC0: begin
                    acc <= prod; 
                    state <= MAC1;
                end
                
                MAC1: begin
                    acc <= acc + prod; 
                    state <= MAC2;
                end
                
                MAC2: begin
                    mac_odo <= acc + prod; 
                    valid <= 1'b1;         
                    state <= IDLE;         
                end
            endcase
        end
    end

endmodule
