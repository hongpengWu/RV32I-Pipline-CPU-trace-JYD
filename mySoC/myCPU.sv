`include "para.sv"


module myCPU (
    input cpu_clk,
    input cpu_rst,

    output [31:0] irom_addr,
    input  [31:0] irom_data,

    output [31:0] perip_addr,
    output        perip_wen,
    output [ 1:0] perip_mask,
    output [31:0] perip_wdata,
    input  [31:0] perip_rdata,

    output  logic debug_wb_have_inst,
    output  logic [31:0] debug_wb_pc,
    output  logic debug_wb_ena,
    output  logic [4:0] debug_wb_reg,
    output  logic [31:0] debug_wb_value

);

  wire [31:0] IFU_inst;
  wire        IFU_valid;
  wire [31:0] IFU_pc;
  wire [31:0] IFU_snpc;

  /************************* IDU ********************/
  wire [31:0] IDU_pc;
  wire [ 4:0] IDU_rd;
  wire [ 2:0] IDU_funct3;
  wire        IDU_mret_flag;
  wire        IDU_ecall_flag;
  wire [31:0] IDU_rs2_value;
  wire [31:0] IDU_rs1_value;
  wire [ 3:0] IDU_csr_wen;
  wire        IDU_R_wen;
  wire [31:0] IDU_rd_value;
  wire        IDU_mem_wen;
  wire        IDU_mem_ren;

  wire        IDU_inv_flag;
  wire        IDU_branch_flag;
  wire        IDU_jump_flag;
  wire [31:0] IDU_add1_value;
  wire [31:0] IDU_add2_value;
  wire [ 3:0] IDU_alu_opcode;
  wire [ 4:0] IDU_rs1;
  wire [ 4:0] IDU_rs2;
  wire [31:0] IDU_a0_value;
  wire [31:0] IDU_mepc_out;
  wire [31:0] IDU_mtvec_out;

  wire [31:0] IDU_branch_pc;
  wire        IDU_valid;
  wire        IDU_ready;
  wire        IDU_fence_i_flag;
  /************************* EXU ********************/
  wire [31:0] EXU_branch_pc;
  wire        EXU_jump_flag;
  wire [ 2:0] EXU_funct3;
  wire [31:0] EXU_rs2_value;
  wire [ 4:0] EXU_rd;
  wire [31:0] EXU_rd_value;
  wire [ 3:0] EXU_csr_wen;
  wire        EXU_R_wen;
  wire        EXU_mem_wen;
  wire        EXU_mem_ren;
  wire [31:0] EXU_pc;
  wire [31:0] EXU_Ex_result;
  wire        EXU_branch_flag;
  wire [31:0] EXU_rs1_in;
  wire [31:0] EXU_rs2_in;
  wire        EXU_fence_i_flag;

  wire        EXU_valid;
  wire        EXU_ready;
  /************************* LSU ********************/
  wire        LSU_jump_flag;
  wire        LSU_R_wen;
  wire [31:0] LSU_Rdata;
  wire [ 3:0] LSU_csr_wen;
  wire [31:0] LSU_Ex_result;
  wire [31:0] LSU_rd_value;
  wire [31:0] LSU_pc;

  wire [ 4:0] LSU_rd;
  wire        LSU_mem_ren;
  wire        LSU_ready;
  wire        LSU_vaild;

  /************************* WBU ********************/
  wire [31:0] WBU_pc;
  wire [31:0] WBU_inst;
  wire [31:0] WBU_rd_value;
  wire [31:0] WBU_csrd;
  wire [ 4:0] WBU_rd;
  wire        WBU_R_wen;
  wire [ 3:0] WBU_csr_wen;
  wire        WBU_ready;
  wire        WBU_valid;
  wire        LSU_valid;

  /*            PERSONAL              */

  wire        dnpc_flag;
  wire        EXU_inst_clear;
  wire [31:0] dnpc;
  wire IFU_stall;
  wire icache_clr;

  assign irom_addr = IFU_pc;

assign debug_wb_have_inst = WBU_valid;
assign debug_wb_pc = WBU_pc;
assign debug_wb_ena = WBU_R_wen;
assign debug_wb_reg = WBU_rd;
assign debug_wb_value = WBU_rd_value;


  IFU IFU_Inst0 (
      .clock    (cpu_clk),
      .reset    (cpu_rst),
      .dnpc     (dnpc),
      .dnpc_flag(dnpc_flag),
      .stall     (IFU_stall),
      .pc       (IFU_pc),
      .snpc     (IFU_snpc),
      .inst     (IFU_inst),
      .irom_data(irom_data),

      .ready(IDU_ready),
      .valid(IFU_valid)
  );


  Control Control_inst0 (

      .clock    (cpu_clk),
      .reset    (cpu_rst),
      .mtvec_out(IDU_mtvec_out),
      .mepc_out (IDU_mepc_out),

      .branch_pc    (EXU_branch_pc),
      .Ex_result    (EXU_Ex_result),
      .MEM_Ex_result(WBU_rd_value),
      .IDU_rs1_value(IDU_rs1_value),
      .IDU_rs2_value(IDU_rs2_value),
      .MEM_Rdata    (LSU_Rdata),

      .branch_flag (EXU_branch_flag),
      .jump_flag   (EXU_jump_flag),
      .mret_flag   (IDU_mret_flag),
      .ecall_flag  (IDU_ecall_flag),
      .fence_i_flag(EXU_fence_i_flag),

      .MEM_mem_ren(LSU_mem_ren),

      .IDU_rs1(IDU_rs1),
      .IDU_rs2(IDU_rs2),

      .IDU_valid(IDU_valid),
      .EXU_valid(EXU_valid),
      .MEM_valid(LSU_valid),

      .EXU_rd(EXU_rd),
      .MEM_rd(LSU_rd),
      .EXU_mem_ren(EXU_mem_ren),
      .EXU_R_Wen(EXU_R_wen),
      .MEM_R_Wen(LSU_R_wen),

      .IFU_stall      (IFU_stall),
      .EXU_rs1_in    (EXU_rs1_in),
      .EXU_rs2_in    (EXU_rs2_in),
      .dnpc          (dnpc),
      .icache_clr    (icache_clr),
      .EXU_inst_clear(EXU_inst_clear),
      .dnpc_flag     (dnpc_flag)
  );




  IDU IDU_Inst0 (
      .clock(cpu_clk),
      .reset(cpu_rst),

      .snpc    (IFU_snpc),
      .inst    (IFU_inst),
      .pc      (IFU_pc),
      .rd_value(WBU_rd_value),
      .csrd    (WBU_csrd),
      .rd      (WBU_rd),
      .R_wen   (WBU_R_wen),
      .csr_wen (WBU_csr_wen),

      .EXU_rs1_in  (EXU_rs1_in),
      .EXU_rs2_in  (EXU_rs2_in),
      .branch_pc   (IDU_branch_pc),
      .rd_next     (IDU_rd),
      .funct3      (IDU_funct3),
      .mret_flag   (IDU_mret_flag),
      .ecall_flag  (IDU_ecall_flag),
      .fence_i_flag(IDU_fence_i_flag),

      .add2_value   (IDU_add2_value),
      .add1_value   (IDU_add1_value),
      .rs1_value    (IDU_rs1_value),
      .rs2_value    (IDU_rs2_value),
      .csr_wen_next (IDU_csr_wen),
      .R_wen_next   (IDU_R_wen),
      .rd_value_next(IDU_rd_value),

      .mem_wen    (IDU_mem_wen),
      .mem_ren    (IDU_mem_ren),
      .inv_flag   (IDU_inv_flag),
      .branch_flag(IDU_branch_flag),
      .jump_flag  (IDU_jump_flag),
      .alu_opcode (IDU_alu_opcode),

      .pc_out   (IDU_pc),
      .rs1      (IDU_rs1),
      .rs2      (IDU_rs2),
      .a0_value (IDU_a0_value),
      .mepc_out (IDU_mepc_out),
      .mtvec_out(IDU_mtvec_out),


      .valid_last(IFU_valid),
      .ready_last(IDU_ready),

      .ready_next(EXU_ready),
      .valid_next(IDU_valid)

  );

  EXU EXU_Inst0 (
      .clock       (cpu_clk),
      .reset       (cpu_rst),
      .EXU_inst_clr(EXU_inst_clear),

      .funct3   (IDU_funct3),
      .csr_wen  (IDU_csr_wen),
      .R_wen    (IDU_R_wen),
      .mem_wen  (IDU_mem_wen),
      .mem_ren  (IDU_mem_ren),
      .rd       (IDU_rd),
      .branch_pc(IDU_branch_pc),
      .pc       (IDU_pc),

      .alu_opcode  (IDU_alu_opcode),
      .inv_flag    (IDU_inv_flag),
      .jump_flag   (IDU_jump_flag),
      .branch_flag (IDU_branch_flag),
      .fetch_i_flag(IDU_fence_i_flag),

      .add2     (IDU_add2_value),
      .add1     (IDU_add1_value),
      .rs2_value(EXU_rs2_in),
      .rd_value (IDU_rd_value),

      .branch_pc_next   (EXU_branch_pc),
      .branch_flag_next (EXU_branch_flag),
      .jump_flag_next   (EXU_jump_flag),
      .funct3_next      (EXU_funct3),
      .rs2_value_next   (EXU_rs2_value),
      .rd_next          (EXU_rd),
      .rd_value_next    (EXU_rd_value),
      .csr_wen_next     (EXU_csr_wen),
      .R_wen_next       (EXU_R_wen),
      .mem_wen_next     (EXU_mem_wen),
      .mem_ren_next     (EXU_mem_ren),
      .EX_result        (EXU_Ex_result),
      .fetch_i_flag_next(EXU_fence_i_flag),
      .pc_out   (EXU_pc),

      .valid_last(IDU_valid),
      .ready_last(EXU_ready),

      .ready_next(LSU_ready),
      .valid_next(EXU_valid)


  );

  LSU LSU_Inst0 (
      .clock(cpu_clk),
      .reset(cpu_rst),

      .mem_ren  (EXU_mem_ren),
      .mem_wen  (EXU_mem_wen),
      .R_wen    (EXU_R_wen),
      .csr_wen  (EXU_csr_wen),
      .Ex_result(EXU_Ex_result),
      .rd_value (EXU_rd_value),
      .rd       (EXU_rd),
      .funct3   (EXU_funct3),
      .rs2_value(EXU_rs2_value),
      .jump_flag(EXU_jump_flag),
      .pc       (EXU_pc),

      .R_wen_next    (LSU_R_wen),
      .LSU_Rdata     (LSU_Rdata),
      .csr_wen_next  (LSU_csr_wen),
      .Ex_result_next(LSU_Ex_result),
      .rd_value_next (LSU_rd_value),
      .rd_next       (LSU_rd),
      .mem_ren_next  (LSU_mem_ren),
      .jump_flag_next(LSU_jump_flag),

      .pc_out(LSU_pc),
      .addr (perip_addr),
      .wen  (perip_wen),
      .wdata(perip_wdata),
      .mask (perip_mask),
      .rdata(perip_rdata),

      .valid_last(EXU_valid),
      .ready_last(LSU_ready),

      .ready_next(WBU_ready),
      .valid_next(LSU_valid)

  );

  WBU WBU_inst0 (
      .clock(cpu_clk),
      .reset(cpu_rst),

      .MEM_Rdata(LSU_Rdata),
      .Ex_result(LSU_Ex_result),
      .rd_value (LSU_rd_value),
      .rd       (LSU_rd),
      .csr_wen  (LSU_csr_wen),
      .R_wen    (LSU_R_wen),
      .mem_ren  (LSU_mem_ren),
      .jump_flag(LSU_jump_flag),
      .pc (LSU_pc),

      .R_wen_next   (WBU_R_wen),
      .csr_wen_next (WBU_csr_wen),
      .csrd         (WBU_csrd),
      .rd_value_next(WBU_rd_value),
      .pc_out(WBU_pc),

      .valid(LSU_valid),
      .ready(WBU_ready),

      .rd_next   (WBU_rd),
      .valid_next(WBU_valid)
  );

endmodule

