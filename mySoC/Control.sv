module Control (
    input clock,
    input reset,
    input [31:0] mtvec_out,
    input [31:0] mepc_out,
    input [31:0] branch_pc,
    input [31:0] Ex_result,
    input [31:0] MEM_Ex_result,
    input [31:0] MEM_Rdata,
    input [31:0] IDU_rs1_value,
    input [31:0] IDU_rs2_value,
    input branch_flag,
    input jump_flag,
    input mret_flag,
    input ecall_flag,
    input MEM_mem_ren,
    input fence_i_flag,
    input [4:0] IDU_rs1,
    input [4:0] IDU_rs2,
    input IDU_valid,
    input EXU_valid,
    input MEM_valid,
    input [4:0] EXU_rd,
    input [4:0] MEM_rd,
    input EXU_mem_ren,
    input EXU_R_Wen,
    input MEM_R_Wen,
    input [31:0] WB_rd_value,
    input [4:0] WB_rd,
    input WB_R_Wen,
    input WB_valid,
    output IFU_stall,
    output [31:0] EXU_rs1_in,
    output [31:0] EXU_rs2_in,
    output icache_clr,
    output EXU_inst_clear,
    output [31:0] dnpc,
    output dnpc_flag
);


    logic [2:0] IDU_rs1_choice;
    logic [2:0] IDU_rs2_choice;



    logic branch_taken;
    assign branch_taken = branch_flag & Ex_result[0];
    assign dnpc_flag     = branch_taken ? 1'b1 : ((jump_flag | fence_i_flag) | (mret_flag | ecall_flag));
    assign EXU_inst_clear = branch_taken ? 1'b1 : (jump_flag | fence_i_flag | IFU_stall);
    assign IFU_stall     = EXU_mem_ren && (((EXU_rd == IDU_rs1) || (EXU_rd == IDU_rs2)) && (EXU_rd != 0));


    assign icache_clr = fence_i_flag & EXU_valid;


    assign dnpc = (jump_flag ? Ex_result : branch_flag ? branch_pc : mret_flag ? mepc_out : mtvec_out);



    assign EXU_rs1_in = (IDU_rs1_choice == 3'b001) ? Ex_result :
                        (IDU_rs1_choice == 3'b011) ? MEM_Rdata :
                        (IDU_rs1_choice == 3'b010) ? MEM_Ex_result :
                        (IDU_rs1_choice == 3'b100) ? WB_rd_value :
                        IDU_rs1_value;

    assign EXU_rs2_in = (IDU_rs2_choice == 3'b001) ? Ex_result :
                        (IDU_rs2_choice == 3'b011) ? MEM_Rdata :
                        (IDU_rs2_choice == 3'b010) ? MEM_Ex_result :
                        (IDU_rs2_choice == 3'b100) ? WB_rd_value :
                        IDU_rs2_value;


Data_hazard Data_hazard_inst (
    .IDU_rs1        (IDU_rs1),
    .IDU_rs2        (IDU_rs2),
    .EXU_rd         (EXU_rd),
    .MEM_rd         (MEM_rd),
    .WB_rd          (WB_rd),
    .MEM_valid      (MEM_valid),
    .EXU_valid      (EXU_valid),
    .IDU_valid      (IDU_valid),
    .WB_valid       (WB_valid),
    .MEM_mem_ren    (MEM_mem_ren),
    .EXU_R_Wen      (EXU_R_Wen),
    .MEM_R_Wen      (MEM_R_Wen),
    .WB_R_Wen       (WB_R_Wen),
    .IDU_rs1_choice (IDU_rs1_choice),
    .IDU_rs2_choice (IDU_rs2_choice)
);

endmodule        //PC_Control
