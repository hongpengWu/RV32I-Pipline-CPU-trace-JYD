/* verilator lint_off UNUSEDSIGNAL */
// signal not use
`include "para.sv"
module WBU (
    input clock,
    input reset,

    input [31:0] MEM_Rdata,
    input [31:0] Ex_result,
    input [31:0] rd_value,
    input [ 4:0] rd,
    input [ 3:0] csr_wen,
    input        R_wen,
    input        mem_ren,
    input        jump_flag,
    input [31:0] pc,

    input  valid,
    output ready,

    output        valid_next,
    output        R_wen_next,
    output [ 3:0] csr_wen_next,
    output [31:0] csrd,

    output logic [31:0] pc_out,
    output       [31:0] rd_value_next,
    output       [ 4:0] rd_next
);

  reg [31:0] MEM_Rdata_reg;
  reg [31:0] Ex_result_reg;
  reg [31:0] rd_value_reg;
  reg [ 4:0] rd_reg;
  reg [ 3:0] csr_wen_reg;
  reg        R_wen_reg;
  reg        mem_ren_reg;
  reg        jump_flag_reg;
  reg [31:0] pc_reg;
  reg        valid_reg;

  always @(posedge clock) begin
    if (reset) begin
      MEM_Rdata_reg <= 32'b0;
      Ex_result_reg <= 32'b0;
      rd_value_reg  <= 32'b0;
      rd_reg        <= 5'b0;
      csr_wen_reg   <= 4'b0;
      R_wen_reg     <= 1'b0;
      mem_ren_reg   <= 1'b0;
      jump_flag_reg <= 1'b0;
      pc_reg        <= 32'b0;
      valid_reg     <= 1'b0;
    end else begin
      MEM_Rdata_reg <= MEM_Rdata;
      Ex_result_reg <= Ex_result;
      rd_value_reg  <= rd_value;
      rd_reg        <= rd;
      csr_wen_reg   <= csr_wen;
      R_wen_reg     <= R_wen;
      mem_ren_reg   <= mem_ren;
      jump_flag_reg <= jump_flag;
      pc_reg        <= pc;
      valid_reg     <= valid;
    end
  end

  assign pc_out        = pc_reg;
  assign valid_next    = valid_reg;
  assign rd_value_next = (jump_flag_reg | (|csr_wen_reg)) ? rd_value_reg : (mem_ren_reg ? MEM_Rdata_reg : Ex_result_reg);
  assign csrd          = Ex_result_reg;
  assign csr_wen_next  = csr_wen_reg;
  assign R_wen_next    = R_wen_reg & valid_reg;
  assign rd_next       = rd_reg;
  assign ready         = 1'b1;

endmodule  //WBU
