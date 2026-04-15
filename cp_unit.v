`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2026 09:44:16 PM
// Design Name: 
// Module Name: cp_unit
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


module cp_unit(
    input   clk,
    input   resetn,
    input   enb,

    //ctrl sigs
    input cp_clr,
    input cp2h_enb,
    input cp2w_enb,

    input [3:0] elew_act_func_type,

    //data sigs
    input [7:0] cp_di_0,
    input [7:0] cp_di_1,
    input [7:0] cp_di_2,

    //output
    output        [7:0] cp_do

);
    reg [7:0] cp_data_2, cp_data_1, cp_data_0;

    wire cp_is_unsigned = (elew_act_func_type == 0 || elew_act_func_type == 1);

    wire [7:0] cp_di_01_max;
    assign cp_di_01_max  = cp_is_unsigned ? ((cp_di_0 > cp_di_1) ? cp_di_0 : cp_di_1) :
                                            (($signed(cp_di_0) > $signed(cp_di_1)) ? cp_di_0 : cp_di_1);

    wire [7:0] cp_di_012_max;
    assign cp_di_012_max = cp_is_unsigned ? ((cp_di_01_max > cp_di_2) ? cp_di_01_max : cp_di_2) :
                                            (($signed(cp_di_01_max) > $signed(cp_di_2)) ? cp_di_01_max : cp_di_2);

    wire [7:0] cp_do_01_max;
    assign cp_do_01_max  = cp_is_unsigned ? ((cp_data_0 > cp_data_1) ? cp_data_0 : cp_data_1) :
                                            (($signed(cp_data_0) > $signed(cp_data_1)) ? cp_data_0 : cp_data_1);

    wire [7:0] cp_do_012_max;
    assign cp_do_012_max = cp_is_unsigned ? ((cp_do_01_max > cp_data_2) ? cp_do_01_max : cp_data_2) :
                                            (($signed(cp_do_01_max) > $signed(cp_data_2)) ? cp_do_01_max : cp_data_2);

    always @(posedge clk) begin
        if (!resetn) begin
            cp_data_0 <= 0;
            cp_data_1 <= 0;
            cp_data_2 <= 0;
        end 
        else if (enb) begin
            if (!cp_clr) begin
                cp_data_0 <= (cp2h_enb) ? cp_di_01_max : cp_di_012_max;
                cp_data_1 <= cp_data_0;
                cp_data_2 <= cp_data_1;
            end
        end
    end 

    assign cp_do = (cp2w_enb) ? cp_do_01_max: cp_do_012_max;
endmodule    
