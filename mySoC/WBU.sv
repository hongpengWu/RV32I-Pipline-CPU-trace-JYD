/* verilator lint_off UNUSEDSIGNAL */
// signal not use
`include "para.sv"
module WBU (
    input clock,
    input reset,

    input [31:0] MEM_Rdata_in,
    input [31:0] Ex_result_in,
    input [31:0] rd_value_in,
    input [ 4:0] rd_in,
    input [ 3:0] csr_wen_in,
    input        R_wen_in,
    input        mem_ren_in,
    input        jump_flag_in,
    input [31:0] pc_in,

    input  valid_in,
    output logic ready,

    output logic  valid_next,
    output logic  R_wen_next,
    output [ 3:0] csr_wen_next,
    output [31:0] csrd,

    output logic [31:0] pc_out,
    output       [31:0] rd_value_next,
    output       [ 4:0] rd_next
);

  logic [31:0] MEM_Rdata_reg;
  logic [31:0] Ex_result_reg;
  logic [31:0] rd_value_reg;
  logic [ 4:0] rd_reg;
  logic [ 3:0] csr_wen_reg;
  logic        R_wen_reg;
  logic        mem_ren_reg;
  logic        jump_flag_reg;
  logic [31:0] pc_reg;
  logic        valid_reg;

  always_ff @(posedge clock) begin
    if (reset) begin
        MEM_Rdata_reg <= 0;
        Ex_result_reg <= 0;
        rd_value_reg  <= 0;
        rd_reg        <= 0;
        csr_wen_reg   <= 0;
        R_wen_reg     <= 0;
        mem_ren_reg   <= 0;
        jump_flag_reg <= 0;
        pc_reg        <= 0;
        valid_reg     <= 0;
    end
    else begin
        MEM_Rdata_reg <= MEM_Rdata_in;
        Ex_result_reg <= Ex_result_in;
        rd_value_reg  <= rd_value_in;
        rd_reg        <= rd_in;
        csr_wen_reg   <= csr_wen_in;
        R_wen_reg     <= R_wen_in;
        mem_ren_reg   <= mem_ren_in;
        jump_flag_reg <= jump_flag_in;
        pc_reg        <= pc_in;
        valid_reg     <= valid_in;
    end
  end

  assign pc_out        = pc_reg;
  assign valid_next    = valid_reg;
  wire wb_sel_jmp_csr = jump_flag_reg | (|csr_wen_reg);
  assign rd_value_next = wb_sel_jmp_csr ? rd_value_reg : (mem_ren_reg ? MEM_Rdata_reg : Ex_result_reg);
  assign csrd          = Ex_result_reg;
  assign csr_wen_next  = csr_wen_reg;
  assign R_wen_next    = R_wen_reg & valid_reg;
  assign rd_next       = rd_reg;
  assign ready         = 1'b1;

endmodule  //WBU
