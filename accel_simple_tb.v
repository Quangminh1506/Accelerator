`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2026 08:37:20 PM
// Design Name: 
// Module Name: accel_simple_tb
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


module accel_simple_tb;
    reg         clk;
    reg         reset;

    // Config Interface 
    reg  [31:0] cfgreg_di;
    reg  [ 4:0] cfgreg_sel;
    reg         cfgreg_wenb;

    // Read Data Interface 
    wire [31:0] rdata;
    wire [31:0] raddr;
    wire        renb;
    reg         mem_read_ready;
    reg         mem_write_ready;

    // Write Data Interface 
    wire [31:0] wdata;
    wire [31:0] waddr;
    wire        wenb;
    wire [ 3:0] wstrb;

    // System Interface [cite: 217]
    reg         flow_enb;
    reg         flow_reset;
    wire        cal_fin;

    // Khởi tạo Module al_accel (Device Under Test)
    main_accel uut (
        .accel_cfgreg_di         (cfgreg_di),
        .accel_cfg_reg_sel        (cfgreg_sel),
        .accel_cfgreg_write_enb       (cfgreg_wenb),
        .accel_read_data             (rdata),
        .accel_read_addr             (raddr),
        .accel_read_enb              (renb),
        .accel_mem_read_ready    (mem_read_ready),
        .accel_mem_write_ready   (mem_write_ready),
        .accel_write_data             (wdata),
        .accel_write_addr             (waddr),
        .accel_write_enb             (wenb),
        .accel_wstrb             (wstrb),
        .accel_ctrl_enb          (flow_enb),
        .accel_ctrl_resetn       (flow_reset),
        .accel_done           (cal_fin),
        .clk                        (clk),
        .resetn                      (reset)
    );

    // ==========================================
    // 2. MÔ PHỎNG BỘ NHỚ RAM (DUMMY RAM)
    // ==========================================
    // Khai báo một mảng nhớ 32-bit (dung lượng 64K words)
    reg [31:0] dummy_ram [0:65535];
    integer i;
    // Nạp dữ liệu từ Python vào RAM ngay từ chu kỳ đầu tiên
    initial begin
        for (i = 0; i < 65536; i = i + 1) dummy_ram[i] = 32'd0;
        // Đường dẫn file phải khớp với thư mục mô phỏng (Simulation Folder)
        $readmemh("J:/Vivado_project/test_cnn/bias.hex", dummy_ram, 7500); 
        $readmemh("J:/Vivado_project/test_cnn/weight.hex", dummy_ram, 2500);  // Nạp Weight từ địa chỉ 10000 (Ví dụ)
        $readmemh("J:/Vivado_project/test_cnn/input.hex", dummy_ram, 0);       // Nạp Input từ địa chỉ 0
    end

    reg [31:0] rdata_reg; // Thanh ghi lưu trữ dữ liệu đầu ra

    always @(posedge clk) begin
        if (renb) begin
            rdata_reg <= dummy_ram[raddr >> 2];
        end
    end

    assign rdata = rdata_reg;

    // Mạch GHI RAM: Kết hợp Write Mask (wstrb) để không ghi đè rác
    always @(posedge clk) begin
        if (wenb) begin
        $display("[%0t] RAM WRITE: waddr=%0d, wstrb=%b, wdata=%h", $time, waddr, wstrb, wdata);
            if (wstrb[0]) dummy_ram[waddr >> 2][ 7: 0] <= wdata[ 7: 0];
            if (wstrb[1]) dummy_ram[waddr >> 2][15: 8] <= wdata[15: 8];
            if (wstrb[2]) dummy_ram[waddr >> 2][23:16] <= wdata[23:16];
            if (wstrb[3]) dummy_ram[waddr >> 2][31:24] <= wdata[31:24];
        end
    end

    // ==========================================
    // 3. TASK BƠM CẤU HÌNH (Giao tiếp với config_regs)
    // ==========================================
    task write_config(input [4:0] sel, input [31:0] data);
    begin
        @(posedge clk);
        cfgreg_wenb = 1;
        cfgreg_sel  = sel;
        cfgreg_di   = data;
        @(posedge clk);
        cfgreg_wenb = 0;
    end
    endtask

    // ==========================================
    // 4. KỊCH BẢN CHẠY MÔ PHỎNG (MAIN THREAD)
    // ==========================================
    initial begin
        // Khởi tạo trạng thái an toàn
        clk = 0;
        reset = 0;
        flow_reset = 0;
        flow_enb = 0;
        cfgreg_wenb = 0;
        mem_read_ready = 1;  // Giả lập RAM phản hồi ngay lập tức
        mem_write_ready = 1; // Giả lập RAM ghi ngay lập tức
        
        #10;
        reset = 1;
        flow_reset = 1;

        write_config(5'd0, 32'd0);      // i_base_addr = 0 
        write_config(5'd1, 32'd10000);  // kw_base_addr = 10000 
        write_config(5'd2, 32'd20000);  // o_base_addr = 20000 
        write_config(5'd3, 32'd30000);  // b_base_addr = 30000 
        write_config(5'd4, 32'd40000);  // ps_base_addr = 40000 

        // --- Layer Topo ---
        // 5'd5: {stride_height[3:0], stride_width[3:0], cfg_act_func_type[3:0], cfg_layer_type[3:0]}
        // S_H=1, S_W=1, Act=0, Layer=0(CONV) -> 16'h1100
        write_config(5'd5, 32'h00001140);

        // 5'd6: {weight_H[15:0], weight_W[15:0]} -> 3x3
        write_config(5'd6, {16'd3, 16'd3}); 

        // 5'd7: {Out_Channels[15:0], In_Channels[15:0]} -> Out=2, In=3
        write_config(5'd7, {16'd2, 16'd6}); 

        // 5'd8: {ifm_height[15:0], ifm_width[15:0]} -> 5x5
        write_config(5'd8, {16'd6, 16'd6}); 

        // 5'd9: {ofm_height[15:0], ofm_width[15:0]} -> 3x3
        write_config(5'd9, {16'd4, 16'd4}); 

        // 5'd10: {output2D_size[15:0], input2D_size[15:0]} -> Out=9, In=25
        write_config(5'd10, {16'd16, 16'd36}); 

        // 5'd11: kernel3D_size -> 3x3x3 = 27
        write_config(5'd11, 32'd54); 

        write_config(5'd12, 32'd0); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd1); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd2); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd3); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd4); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd5); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd6); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd7); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd8); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd9); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd10); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd11); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd12); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd13); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd14); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        write_config(5'd12, 32'd15); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
//        write_config(5'd12, 32'd16); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
//        write_config(5'd12, 32'd17); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
//        write_config(5'd12, 32'd18); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
//        write_config(5'd12, 32'd19); write_config(5'd13, 32'h7FFF_FFFF); write_config(5'd14, 32'd0);
        // --- Quantization ---
        // Channel 0 (OC=0): multiplier = 0x40000000
//        write_config(5'd12, 32'd0); 
//        write_config(5'd13, 32'h4000_0000); 
//        write_config(5'd14, 32'd0);
        
//        // Channel 1 (OC=1): multiplier = 0x20000000
//        write_config(5'd12, 32'd0); // output_quant_buf_insel
//        write_config(5'd13, 32'h7FFF_FFFF); // multiplier
//        write_config(5'd14, 32'd0); // shift
//        // Nơ-ron 1
//        write_config(5'd12, 32'd1); // output_quant_buf_insel
//        write_config(5'd13, 32'h7FFF_FFFF); // multiplier
//        write_config(5'd14, 32'd0); // shift
//        // Nơ-ron 2
//        write_config(5'd12, 32'd2); // output_quant_buf_insel
//        write_config(5'd13, 32'h7FFF_FFFF); // multiplier
//        write_config(5'd14, 32'd0); // shift

        
        write_config(5'd15, 32'd0); // input_offset = 0 
        write_config(5'd16, 32'd0); // output_offset = 0 

        // PHÁT LỆNH KHỞI CHẠY KHỐI GIA TỐC
        $display("--- ACCELERATOR STARTED ---");
        flow_enb = 1;

        // Bẫy chờ: Đứng đợi cho đến khi chân cal_fin bật lên 1
        wait (cal_fin == 1'b1);
        $display("--- ACCELERATOR FINISHED ---");
        
        // Tắt chip
        flow_enb = 0;
        
        // XUẤT KẾT QUẢ RA FILE HEX
        // Xuất vùng nhớ RAM giả lập (nơi chip vừa ghi kết quả vào) ra file.
        // Giả sử o_base_addr của bạn là 20000, xuất 100 word.
        $writememh("J:/Vivado_project/CNN_projekt.srcs/hardware_output.hex", dummy_ram, 5000, 5180); 
        //$writememh("J:/Vivado_project/CNN_projekt.srcs/hardware_ps_scratchpad.hex", dummy_ram, 10000, 10020);
        
        $display("Simulation Done! Check hardware_output.hex");
        $finish;
    end

    // Tạo xung Clock (Chu kỳ 10ns -> 100MHz)
    always #5 clk = ~clk;

endmodule
