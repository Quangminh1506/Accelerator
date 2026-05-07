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

    reg [2:0] state;
//    localparam IDLE = 2'd0,
//               MAC0 = 2'd1,
//               MAC1 = 2'd2,
//               MAC2 = 2'd3;
    localparam IDLE  = 3'd0,
               PIPE1 = 3'd1, 
               PIPE2 = 3'd2, 
               MAC0  = 3'd3, 
               MAC1  = 3'd4, 
               MAC2  = 3'd5; 
    reg [7:0] ridi_0, ridi_1, ridi_2;

    always @(posedge clk) begin
        if (!rstn) begin
            ridi_0 <= 0;
            ridi_1 <= 0;
            ridi_2 <= 0;
        end
        else if (enb) begin
            if (mac_load) begin
                ridi_0 <= idi_0;
                ridi_1 <= idi_1;
                ridi_2 <= idi_2;
            end
        end
    end

//    always @(*) begin
//        case(state)
//            IDLE: begin
//                mux_idi = 0;
//                mux_wdi = 0;
//                mac_load = 1;
//                ready = 0;
//            end
        
//            MAC0: begin 
//                mux_idi = ridi_0; 
//                mux_wdi = wdi_0;
//                mac_load = 0; 
//                ready = 0;
//            end 
//            MAC1: begin
//                mux_idi = ridi_1; 
//                mux_wdi = wdi_1; 
//                mac_load = 0; 
//                ready = 0;
//            end 
//            MAC2: begin 
//                mux_idi = ridi_2; 
//                mux_wdi = wdi_2; 
//                mac_load = 0; 
//                ready = 1;
//            end 
//            default: begin 
//                mux_idi = 0; 
//                mux_wdi = 0; 
//                mac_load = 0; 
//                ready = 0;
//            end
//        endcase
//    end
    always @(*) begin
        // Giá trị mặc định
        mux_idi = 0;
        mux_wdi = 0;
        mac_load = 0;
        ready = 0;
        
        case(state)
            IDLE: begin
                mac_load = 1;
            end
            PIPE1: begin 
                mux_idi = ridi_0; 
                mux_wdi = wdi_0;
            end 
            PIPE2: begin
                mux_idi = ridi_1; 
                mux_wdi = wdi_1; 
            end 
            MAC0: begin 
                mux_idi = ridi_2; 
                mux_wdi = wdi_2; 
            end 
            MAC1: begin
                // Đứng chờ, MUX tự bằng 0
            end
            MAC2: begin 
                ready = 1; // Báo cờ hoàn thành
            end 
            default: ;
        endcase
    end
    wire signed [9:0] idi_add_off = $signed(mux_idi) + $signed(input_offset[8:0]);

    wire idi_sign = idi_add_off[9];
    wire wdi_sign = mux_wdi[7];

    wire [8:0] us_idi_9b = idi_sign ? -$signed(idi_add_off) : idi_add_off;
    wire [7:0] us_idi    = us_idi_9b[7:0]; // Chỉ lấy 8 bit đưa vào bộ nhân
    wire [7:0] us_wdi    = wdi_sign ? (~mux_wdi + 1'b1) : mux_wdi;
    
    wire [15:0] prod;
    reg [7:0]  us_idi_pipe, us_wdi_pipe;
    reg        prod_sign_pipe1, prod_sign_pipe2;
    reg [15:0] prod_pipe;
    
    always @(posedge clk) begin
        if (!rstn) begin
            us_idi_pipe <= 0;
            us_wdi_pipe <= 0;
            prod_sign_pipe1 <= 0;
            prod_sign_pipe2 <= 0;
            prod_pipe <= 0;
        end else if (enb) begin
            us_idi_pipe <= us_idi; 
            us_wdi_pipe <= us_wdi;
            prod_sign_pipe1 <= idi_sign ^ wdi_sign;
            
            prod_pipe <= prod;
            prod_sign_pipe2 <= prod_sign_pipe1; 
        end
    end
    M8_CP13_6 mult (
        .A(us_idi_pipe),
        .B(us_wdi_pipe),
        .P(prod)
    );

    //wire prod_sign = idi_sign ^ wdi_sign;
    //wire signed [31:0] final_prod = prod_sign ? -$signed({16'd0, prod}) : $signed({16'd0, prod});
    wire signed [31:0] final_prod = prod_sign_pipe2 ? -$signed({16'd0, prod_pipe}) : $signed({16'd0, prod_pipe});

    reg [31:0] acc;
    
//    always @(posedge clk) begin
//        if (!rstn) begin
//            state <= IDLE;
//            acc <= 32'd0;
//            mac_odo <= 32'd0;
//        end else if (enb) begin
//            case (state)
//                IDLE: begin
//                    state <= MAC0;
//                    mac_odo <= 0;
//                end
                
//                MAC0: begin
//                    acc <= final_prod;
//                    state <= MAC1;
//                end
                
//                MAC1: begin
//                    acc <= acc + final_prod;
//                    state <= MAC2;
//                end
                
//                MAC2: begin
//                    mac_odo <= acc + final_prod;
//                    state <= IDLE;
//                end
//            endcase
//        end
//    end
// Chuyển trạng thái FSM và Cộng tích lũy
    always @(posedge clk) begin
        if (!rstn) begin
            state <= IDLE;
            acc <= 32'd0;
            mac_odo <= 32'd0;
        end else if (enb) begin
            case (state)
                IDLE: begin
                    state <= PIPE1;
                    mac_odo <= 0;
                end
                PIPE1: begin
                    state <= PIPE2;
                end
                PIPE2: begin
                    state <= MAC0;
                end
                MAC0: begin
                    acc <= final_prod; // Lưu tích của cặp 0
                    state <= MAC1;
                end
                MAC1: begin
                    acc <= acc + final_prod; // Cộng tích của cặp 1
                    state <= MAC2;
                end
                MAC2: begin
                    mac_odo <= acc + final_prod; // Cộng tích của cặp 2 và chốt ODO
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule