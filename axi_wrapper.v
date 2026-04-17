`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2026 10:00:20 PM
// Design Name: 
// Module Name: axi_wrapper
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


module axi_wrapper #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_REGS = 32 //16
)(
    input wire ACLK,
    input wire ARESETN,

    // Write Address Channel
    input  wire [ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input  wire [2:0]            S_AXI_AWPROT,
    input  wire                  S_AXI_AWVALID,
    output reg                   S_AXI_AWREADY,

    // Write Data Channel
    input  wire [DATA_WIDTH-1:0] S_AXI_WDATA,
    input  wire [DATA_WIDTH/8-1:0] S_AXI_WSTRB,
    input  wire                  S_AXI_WVALID,
    output reg                   S_AXI_WREADY,

    // Write Response Channel
    output reg  [1:0]            S_AXI_BRESP,
    output reg                   S_AXI_BVALID,
    input  wire                  S_AXI_BREADY,

    // Read Address Channel
    input  wire [ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input  wire [2:0]            S_AXI_ARPROT,
    input  wire                  S_AXI_ARVALID,
    output reg                   S_AXI_ARREADY,

    // Read Data Channel
    output reg  [DATA_WIDTH-1:0] S_AXI_RDATA,
    output reg  [1:0]            S_AXI_RRESP,
    output reg                   S_AXI_RVALID,
    input  wire                  S_AXI_RREADY,
    
    //DDRAM Read/Write Signals
    // Read Address Channel
    output reg [ADDR_WIDTH-1:0]          M_AXI_ARADDR,
    output wire [7:0]                    M_AXI_ARLEN,   // Data per Burst Fix: 0 = 1 từ
    output wire [2:0]                    M_AXI_ARSIZE,  // 32-bit = 3'b010 = 2^2 = 4 Bytes
    output wire [1:0]                    M_AXI_ARBURST, // 2'b01 - INCR 
    output reg                           M_AXI_ARVALID,
    input  wire                          M_AXI_ARREADY,

    // Read Data Channel
    input  wire [DATA_WIDTH-1:0]         M_AXI_RDATA,
    input  wire [1:0]                    M_AXI_RRESP,
    input  wire                          M_AXI_RLAST,   
    input  wire                          M_AXI_RVALID,
    output reg                           M_AXI_RREADY,

    // Write Address Channel
    output wire [ADDR_WIDTH-1:0]          M_AXI_AWADDR,
    output wire [7:0]                    M_AXI_AWLEN,
    output wire [2:0]                    M_AXI_AWSIZE,
    output wire [1:0]                    M_AXI_AWBURST,
    output reg                           M_AXI_AWVALID,
    input  wire                          M_AXI_AWREADY,

    // Write Data Channel
    output wire [DATA_WIDTH-1:0]          M_AXI_WDATA,
    output wire [(DATA_WIDTH/8)-1:0]      M_AXI_WSTRB,
    output wire                          M_AXI_WLAST,   
    output reg                           M_AXI_WVALID,
    input  wire                          M_AXI_WREADY,

    // Write Response Channel
    input  wire [1:0]                    M_AXI_BRESP,
    input  wire                          M_AXI_BVALID,
    output reg                           M_AXI_BREADY
);

    // Response types
    localparam RESP_OKAY   = 2'b00;
    localparam RESP_SLVERR = 2'b10;

    //Internal Control Signal
    wire internal_done;
    wire internal_enb;
    wire internal_reset;
    reg [31:0] ctrl_reg;
    reg latched_done;
//==============================================================================
// AXI4-Lite Slave Module (BEGIN)
//==============================================================================
    // Internal address/data latches and flags
    reg [ADDR_WIDTH-1:0] aw_addr_latch;
    reg aw_valid_latched;    // true when AW handshake accepted and awaiting W
    reg w_valid_latched;     // true when W handshake accepted and awaiting AW
    reg [DATA_WIDTH-1:0]  wdata_latch;
    reg [DATA_WIDTH/8-1:0] wstrb_latch;

    // Read address latch
    reg [ADDR_WIDTH-1:0] ar_addr_latch;
    reg ar_valid_latched;    // true when AR handshake accepted and R not yet returned

    integer i;

    // reset init
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            S_AXI_AWREADY <= 1'b0;
            S_AXI_WREADY  <= 1'b0;
            S_AXI_BVALID  <= 1'b0;
            S_AXI_BRESP   <= RESP_OKAY;
            aw_addr_latch <= {ADDR_WIDTH{1'b0}};
            aw_valid_latched <= 1'b0;
            wdata_latch <= {DATA_WIDTH{1'b0}};
            wstrb_latch <= {(DATA_WIDTH/8){1'b0}};
            w_valid_latched <= 1'b0;
            S_AXI_ARREADY <= 1'b0;
            ar_addr_latch <= {ADDR_WIDTH{1'b0}};
            ar_valid_latched <= 1'b0;
            S_AXI_RVALID <= 1'b0;
            S_AXI_RDATA  <= {DATA_WIDTH{1'b0}};
            S_AXI_RRESP  <= RESP_OKAY;
        end else begin
            // -----------------------
            // WRITE ADDRESS HANDSHAKE
            // Accept AW when AWVALID asserted and previous AW not latched
            // -----------------------
            if (!aw_valid_latched) begin
                if (S_AXI_AWVALID) begin
                    S_AXI_AWREADY <= 1'b1;
                    if (S_AXI_AWREADY && S_AXI_AWVALID) begin
                        aw_addr_latch <= S_AXI_AWADDR;
                        aw_valid_latched <= 1'b1;
                        S_AXI_AWREADY <= 1'b0; // deassert after accept
                    end
                end else begin
                    S_AXI_AWREADY <= 1'b0;
                end
            end else begin
                // if already latched, keep AWREADY low
                S_AXI_AWREADY <= 1'b0;
            end

            // -----------------------
            // WRITE DATA HANDSHAKE
            // Accept W when WVALID asserted and previous W not latched
            // -----------------------
            if (!w_valid_latched) begin
                if (S_AXI_WVALID) begin
                    S_AXI_WREADY <= 1'b1;
                    if (S_AXI_WREADY && S_AXI_WVALID) begin
                        wdata_latch <= S_AXI_WDATA;
                        wstrb_latch <= S_AXI_WSTRB;
                        w_valid_latched <= 1'b1;
                        S_AXI_WREADY <= 1'b0; // deassert after accept
                    end
                end else begin
                    S_AXI_WREADY <= 1'b0;
                end
            end else begin
                S_AXI_WREADY <= 1'b0;
            end

            // -----------------------
            // PERFORM WRITE when both AW and W latched
            // then assert BVALID until master accepts with BREADY
            // -----------------------
            if (aw_valid_latched && w_valid_latched && !S_AXI_BVALID) begin
                // address -> index (word addressing, address[1:0] ignored)
                S_AXI_BRESP <= RESP_OKAY;
                // mark response valid and clear latched flags (response waits for BREADY)
                S_AXI_BVALID <= 1'b1;
                aw_valid_latched <= 1'b0;
                w_valid_latched <= 1'b0;
            end else if (S_AXI_BVALID && S_AXI_BREADY) begin
                S_AXI_BVALID <= 1'b0;
            end

            // READ ADDRESS HANDSHAKE
            if (!ar_valid_latched) begin
                if (S_AXI_ARVALID) begin
                    S_AXI_ARREADY <= 1'b1;
                    if (S_AXI_ARREADY && S_AXI_ARVALID) begin
                        ar_addr_latch <= S_AXI_ARADDR;
                        ar_valid_latched <= 1'b1;
                        S_AXI_ARREADY <= 1'b0;
                    end
                end else begin
                    S_AXI_ARREADY <= 1'b0;
                end
            end else begin
                S_AXI_ARREADY <= 1'b0;
            end

            // READ DATA CHANNEL
            // when AR latched and R not yet valid -> present data
            if (ar_valid_latched && !S_AXI_RVALID) begin
                if (ar_addr_latch[6:2] == 5'd31) begin
                    S_AXI_RDATA <= {29'd0, latched_done, ctrl_reg[1:0]};
                end else begin
                    S_AXI_RDATA <= {DATA_WIDTH{1'b0}}; 
                end
                S_AXI_RRESP <= RESP_OKAY;
                S_AXI_RVALID <= 1'b1;
                ar_valid_latched <= 1'b0; // R now being presented
            end else if (S_AXI_RVALID && S_AXI_RREADY) begin
                S_AXI_RVALID <= 1'b0;
            end
        end
    end
    
    always @(posedge ACLK) begin
        if (!ARESETN || !internal_reset) begin
            // Xóa cờ Done khi Reset hệ thống
            latched_done <= 1'b0;
        end else if (internal_done) begin
            // Bắt được tín hiệu Done từ main_accel thì GIỮ LUÔN Ở MỨC 1
            latched_done <= 1'b1;
        end
    end
    wire [4:0]  cfg_sel;
    wire [31:0] cfg_di;
    wire        cfg_wenb;
    
    assign cfg_wenb = (aw_valid_latched && w_valid_latched && !S_AXI_BVALID);
    
    // XỬ LÝ ĐỊA CHỈ:
    // AXI truyền địa chỉ theo byte (0x00, 0x04, 0x08...). Nhưng `accel_cfg_reg_sel` của bạn chỉ rộng 5-bit (từ 0 đến 31).
    // Do đó, ta phải chia địa chỉ AXI cho 4 bằng cách dịch phải 2 bit (lấy từ bit 6 xuống bit 2).
    assign cfg_sel  = aw_addr_latch[6:2]; 
    
    // Gán dữ liệu cấu hình
    assign cfg_di   = wdata_latch;
//==============================================================================
// AXI4-Lite Slave Module (END)
//==============================================================================
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            ctrl_reg <= 32'd0;
        end else if (cfg_wenb && cfg_sel == 5'd31) begin
            ctrl_reg <= cfg_di;
        end
    end

    assign internal_enb   = ctrl_reg[0]; 
    assign internal_reset = ctrl_reg[1]; 
//==============================================================================
// AXI4-FULL Master Module (BEGIN)
//==============================================================================
    wire [31:0] int_read_data;
    reg        int_mem_read_ready;
    reg        int_mem_write_ready;
    wire        int_read_enb;
    wire [31:0] int_read_addr;
    wire [31:0] int_write_data;
    wire [31:0] int_write_addr;
    wire [3:0]  int_wstrb;
    wire        int_write_enb;
    // READ CHANNEL
    assign M_AXI_ARLEN   = 8'd0;   // Chỉ đọc 1 word mỗi lần (0 có nghĩa là 1 beat)
    assign M_AXI_ARSIZE  = 3'b010; // 4 bytes (32-bit)
    assign M_AXI_ARBURST = 2'b01;  // INCR mode
    
    // WRITE CHANNEL
    assign M_AXI_AWLEN   = 8'd0;   // Chỉ ghi 1 word mỗi lần
    assign M_AXI_AWSIZE  = 3'b010; // 4 bytes (32-bit)
    assign M_AXI_AWBURST = 2'b01;  // INCR mode
    assign M_AXI_WLAST   = 1'b1;   // Vì chỉ ghi 1 word nên word đầu tiên cũng là LAST

    localparam R_IDLE = 2'b00;
    localparam R_SEND_ADDR = 2'b01;
    localparam R_WAIT_DATA = 2'b10;
    

    reg [2:0] c_r_state, n_r_state;
    reg [2:0] c_w_state, n_w_state;
//FSM for READ DDRAM DATA
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            c_r_state <= 2'b0;
        end else begin
            c_r_state <= n_r_state;
            if (M_AXI_RVALID && M_AXI_RREADY) begin
            end
        end
    end
    assign int_read_data = M_AXI_RDATA;
    always @(*) begin
        n_r_state = c_r_state;
        case(c_r_state)
            R_IDLE: begin
                if (int_read_enb) begin
                    n_r_state = R_SEND_ADDR;
                end
            end
            R_SEND_ADDR: begin
                if(M_AXI_ARVALID && M_AXI_ARREADY) begin
                    n_r_state = R_WAIT_DATA;
                end 
            end
            R_WAIT_DATA: begin
                if (M_AXI_RVALID && M_AXI_RREADY) begin
                    n_r_state = R_IDLE;
                end
            end
        endcase
    end
    always @(*) begin
        M_AXI_ARVALID      = 1'b0;
        M_AXI_RREADY       = 1'b0;
        int_mem_read_ready = 1'b0;
        M_AXI_ARADDR       = {int_read_addr[ADDR_WIDTH-1:2], 2'b00};
        case(c_r_state)
            R_IDLE: begin
            end
            R_SEND_ADDR: begin
                M_AXI_ARVALID = 1;               
            end
            R_WAIT_DATA: begin
                M_AXI_RREADY = 1;
                if (M_AXI_RVALID) begin
                    int_mem_read_ready = 1;
                end
            end 
        endcase
    end
    //FSM for WRITE DDRAM DATA
    localparam W_IDLE      = 3'd0;
    localparam W_SEND_BOTH = 3'd1;
    localparam W_SEND_AW   = 3'd2; // Chỉ còn gửi AW
    localparam W_SEND_W    = 3'd3; // Chỉ còn gửi W
    localparam W_WAIT_RESP = 3'd4;

    always @(posedge ACLK) begin
        if (!ARESETN) begin
            c_w_state <= W_IDLE;
        end else begin
            c_w_state <= n_w_state;
        end
    end

    always @(*) begin
        case(c_w_state)
            W_IDLE: begin
                if (int_write_enb) begin
                    n_w_state = W_SEND_BOTH;
                end else
                    n_w_state = W_IDLE;
            end
            
            W_SEND_BOTH: begin
                if (M_AXI_AWREADY && M_AXI_WREADY) begin
                    n_w_state = W_WAIT_RESP;
                end 
                else if (!M_AXI_AWREADY && M_AXI_WREADY) begin
                    n_w_state = W_SEND_AW;
                end
                else if (M_AXI_AWREADY && !M_AXI_WREADY) begin
                    n_w_state = W_SEND_W;
                end else
                    n_w_state = W_SEND_BOTH;
            end

            W_SEND_AW: begin
                if (M_AXI_AWREADY) begin
                    n_w_state = W_WAIT_RESP;
                end else
                    n_w_state = W_SEND_AW;
            end

            W_SEND_W: begin
                if (M_AXI_WREADY) begin
                    n_w_state = W_WAIT_RESP;
                end else
                    n_w_state = W_SEND_W;
            end
            
            W_WAIT_RESP: begin
                if (M_AXI_BVALID && M_AXI_BREADY) begin
                    n_w_state = W_IDLE;
                end else
                    n_w_state = W_WAIT_RESP;
            end
        endcase
    end


    always @(*) begin
        M_AXI_AWVALID       = 1'b0;
        M_AXI_WVALID        = 1'b0;
        M_AXI_BREADY        = 1'b0;
        int_mem_write_ready = 1'b0;

        case(c_w_state)
            W_IDLE: begin
            end
            
            W_SEND_BOTH: begin
                M_AXI_AWVALID = 1'b1;
                M_AXI_WVALID  = 1'b1;
            end

            W_SEND_AW: begin
                M_AXI_AWVALID = 1'b1;
            end

            W_SEND_W: begin
                M_AXI_WVALID  = 1'b1;
            end
            
            W_WAIT_RESP: begin
                M_AXI_BREADY = 1'b1; 
                if (M_AXI_BVALID) begin
                    int_mem_write_ready = 1'b1; 
                end
            end
        endcase
    end

    assign M_AXI_AWADDR = {int_write_addr[ADDR_WIDTH-1:2], 2'b00};
    assign M_AXI_WDATA  = int_write_data;
    assign M_AXI_WSTRB  = int_wstrb;
    
    main_accel main_accel(
        .clk(ACLK),
        .resetn(ARESETN),

        .accel_cfgreg_write_enb(cfg_wenb),
        .accel_cfgreg_di(cfg_di),
        .accel_cfg_reg_sel(cfg_sel),

        .accel_ctrl_enb         (internal_enb),
        .accel_ctrl_resetn       (internal_reset),
        .accel_done             (internal_done),

        .accel_read_data        (int_read_data),       
        .accel_mem_read_ready   (int_mem_read_ready),   
        .accel_mem_write_ready  (int_mem_write_ready), 
        .accel_read_enb         (int_read_enb),         
        .accel_read_addr        (int_read_addr),       
        .accel_write_data       (int_write_data),     
        .accel_write_addr       (int_write_addr),    
        .accel_wstrb            (int_wstrb),          
        .accel_write_enb        (int_write_enb)
    );
endmodule
