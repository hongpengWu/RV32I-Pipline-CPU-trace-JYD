
module miniRV_SoC (
    input  wire         fpga_rst,   // High active
    input  wire         fpga_clk,

    output wire         debug_wb_have_inst, // 当前时钟周期是否有指令写回 (对单周期CPU，可在复位后恒置1)
    output wire [31:0]  debug_wb_pc,        // 当前写回的指令的PC (若wb_have_inst=0，此项可为任意值)
    output               debug_wb_ena,       // 指令写回时，寄存器堆的写使能 (若wb_have_inst=0，此项可为任意值)
    output wire [ 4:0]  debug_wb_reg,       // 指令写回时，写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
    output wire [31:0]  debug_wb_value      // 指令写回时，写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)

);


    // IROM
    logic [31:0] pc;
    logic [11:0] inst_addr;
    logic [31:0] instruction;

    // perip
    logic [31:0] perip_addr, perip_wdata, perip_rdata;
    logic perip_wen;
    logic [1:0] perip_mask;

    // 16KB = 2^12 * 32bit
    assign inst_addr = pc[13:2];

    myCPU Core_cpu (
        .cpu_rst            (fpga_rst),
        .cpu_clk            (fpga_clk),

        // Interface to IROM
        .irom_addr          (pc),             
        .irom_data          (instruction),   

        .debug_wb_have_inst(debug_wb_have_inst),
        .debug_wb_pc(debug_wb_pc),
        .debug_wb_ena(debug_wb_ena),
        .debug_wb_reg(debug_wb_reg),
        .debug_wb_value(debug_wb_value),


        // Interface to DRAM & periphera
        .perip_addr         (perip_addr),     
        .perip_wen          (perip_wen),     
        .perip_mask         (perip_mask),   
        .perip_wdata        (perip_wdata),    
        .perip_rdata        (perip_rdata)     
    );

    IROM Mem_IROM (
        .a          (inst_addr),
        .spo        (instruction)
    );

    // dram rw
    dram_driver dram_driver_inst (
        .clk				(fpga_clk),
        .perip_addr			(perip_addr[17:0]),
        .perip_wdata		(perip_wdata),
        .perip_mask			(perip_mask),
        .dram_wen 			(perip_wen),
        .perip_rdata		(perip_rdata)
    );


endmodule// Add your code here, or replace this file.