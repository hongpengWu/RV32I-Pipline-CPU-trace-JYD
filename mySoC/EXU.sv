`include "para.sv"

module EXU (
    input clock,
    input reset,

    input EXU_inst_clr,
    input [3:0] csr_wen,
    input R_wen,
    input mem_wen,
    input mem_ren,
    input [4:0] rd,
    input [2:0] funct3,
    input [31:0] pc,

    input [3:0] alu_opcode,
    input inv_flag,
    input jump_flag,
    input branch_flag,
    input fetch_i_flag,

    input [31:0] branch_pc,
    input [31:0] rs2_value,
    input [31:0] add1,
    input [31:0] add2,
    input [31:0] rd_value,

    output [31:0] branch_pc_next,
    output [31:0] rd_value_next,
    output fetch_i_flag_next,
    output branch_flag_next,
    output jump_flag_next,
    output [2:0] funct3_next,
    output [31:0] rs2_value_next,
    output [4:0] rd_next,
    output [3:0] csr_wen_next,
    output R_wen_next,
    output mem_wen_next,
    output mem_ren_next,
    output [31:0] EX_result,
    output logic [31:0] pc_out,

    input valid_last,
    output ready_last,


    input ready_next,
    output logic valid_next
);



    logic [31: 0] branch_pc_reg;
    logic [3: 0] csr_wen_reg;
    logic R_wen_reg;
    logic mem_wen_reg;
    logic mem_ren_reg;
    logic [4: 0] rd_reg;
    logic [2: 0] funct3_reg;


    logic [3: 0] alu_opcode_reg;
    logic inv_flag_reg;
    logic jump_flag_reg;
    logic branch_flag_reg;

    logic [31: 0] rs2_value_reg;

    logic [31: 0] add1_reg;
    logic [31: 0] add2_reg;

    logic [31: 0] rd_value_reg;
    logic fetch_i_reg;


    always_ff @(posedge clock) begin
        if(reset)
            valid_next <= 1'b0;
        else if(ready_last & valid_last & EXU_inst_clr )
            valid_next <= 1'b0;
        else if(ready_last & valid_last)
            valid_next <= 1'b1;
        else
            valid_next <= 1'b0;
    end

    always_ff @(posedge clock) begin
        if(reset)begin
            funct3_reg      <= 0;
            rd_reg          <= 0;
            alu_opcode_reg  <= 0;
            inv_flag_reg    <= 0;
            rs2_value_reg   <= 0;
            add1_reg        <= 0;
            add2_reg        <= 0;
            rd_value_reg    <= 0;
            branch_pc_reg   <= 0;
            pc_out <= 0;
        end
        else if(valid_last & ready_next)
        begin
            funct3_reg      <= funct3       ;
            rd_reg          <= rd;
            alu_opcode_reg  <= alu_opcode   ;
            inv_flag_reg    <= inv_flag     ;
            rs2_value_reg   <= rs2_value;
            add1_reg        <= add1     ;
            add2_reg        <= add2     ;
            rd_value_reg    <= rd_value     ;
            branch_pc_reg   <= branch_pc;
            pc_out <= pc;
        end
    end

always_ff @(posedge clock) begin
    if(reset)begin
        mem_ren_reg     <= 0;
        csr_wen_reg     <= 0;
        R_wen_reg       <= 0;
        mem_wen_reg     <= 0;
        jump_flag_reg   <= 0;
        branch_flag_reg <= 0;
        fetch_i_reg <= 0;
    end
    else if(valid_last & ready_next& EXU_inst_clr)begin
        mem_ren_reg     <= 0;
        csr_wen_reg     <= 0;
        R_wen_reg       <= 0;
        mem_wen_reg     <= 0;
        jump_flag_reg   <= 0;
        branch_flag_reg <= 0;
        fetch_i_reg <= 0;
    end
    else if(valid_last & ready_next) begin
        mem_ren_reg     <= mem_ren;
        csr_wen_reg     <= csr_wen;
        R_wen_reg       <= R_wen;
        mem_wen_reg     <= mem_wen;
        jump_flag_reg   <= jump_flag;
        branch_flag_reg <= branch_flag;
        fetch_i_reg     <= fetch_i_flag;
    end
end


    logic [31:0] alu_res;
    

    assign jump_flag_next              = jump_flag_reg;
    assign funct3_next                 = funct3_reg;
    assign rd_next                     = rd_reg;
    assign rd_value_next               = rd_value_reg;
    assign csr_wen_next                = csr_wen_reg;
    assign R_wen_next                  = R_wen_reg;
    assign mem_wen_next                = mem_wen_reg;
    assign mem_ren_next                = mem_ren_reg;
    assign EX_result                   = {alu_res[31:1], alu_res[0] ^ inv_flag_reg};
    assign rs2_value_next              = rs2_value_reg;
    assign branch_flag_next            = branch_flag_reg;
    assign ready_last                  = ready_next;
    assign fetch_i_flag_next           = fetch_i_reg;
    assign branch_pc_next              = branch_pc_reg;


/* verilator lint_off PINMISSING */
ALU #(
    .BW(32) 
) ALU_i0 (
    .d1(add1_reg),
    .d2(add2_reg),
    .choice(alu_opcode_reg),
    .res(alu_res) 
);

endmodule
