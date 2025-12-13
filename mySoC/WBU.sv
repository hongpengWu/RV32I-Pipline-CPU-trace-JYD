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
  assign rd_value_next = (jump_flag_reg | (|csr_wen_reg)) ? rd_value_reg : (mem_ren_reg) ? MEM_Rdata_reg : Ex_result_reg;
  assign csrd          = Ex_result_reg;
  assign csr_wen_next  = csr_wen_reg;
  assign R_wen_next    = R_wen_reg & valid_reg;
  assign rd_next       = rd_reg;
  assign ready         = 1'b1;

endmodule  //WBU
