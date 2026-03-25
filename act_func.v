`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2026 09:44:01 PM
// Design Name: 
// Module Name: act_func
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


module act_func(
        input signed [31:0] act_func_di,
        input  [3:0] act_func_type,
        output signed [31:0] act_func_do
    );
    
    localparam RELU    = 4'd0,
               RELU6   = 4'd1;
 
    reg [7:0] act_func_data;
    always @(*) begin
        act_func_data = act_func_di;
        case (act_func_type)
            RELU : begin
                act_func_data = (act_func_di > 0) ? act_func_di : 0;
            end

            RELU6 : begin
                act_func_data = (act_func_di > 0) ? ((act_func_di < 6) ? act_func_di : 6) : 0;
            end

            default: act_func_data = act_func_di; 
        endcase
    end

    assign act_func_do = act_func_data;

    
endmodule
