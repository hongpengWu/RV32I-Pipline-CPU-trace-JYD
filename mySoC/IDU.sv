`include "para.sv"

module IDU(
    input                               clock                      ,
    input                               reset                      ,

    input              [  31: 0]        inst_in                    ,
    input              [  31: 0]        snpc_in                    ,
    input              [  31: 0]        pc_in                      ,

    input                               flush                      ,
    input                               stall                      ,

    input              [  31: 0]        rd_value                   ,
    input              [  31: 0]        csrd                       ,
    input              [   4: 0]        rd                         ,
    input                               R_wen                      ,
    input              [   3: 0]        csr_wen                    ,

    input              [  31: 0]        EXU_rs1_in                 ,
    input              [  31: 0]        EXU_rs2_in                 ,

    output             [   4: 0]        rd_next                    ,
    output             [   2: 0]        funct3                     ,
    output                              mret_flag                  ,
    output                              ecall_flag                 ,
    output                              fence_i_flag               ,

    output             [  31: 0]        branch_pc                  ,
    output             [  31: 0]        rs1_value                  ,
    output             [  31: 0]        rs2_value                  ,
    
    output             [  31: 0]        add1_value                 ,
    output             [  31: 0]        add2_value                 ,
    output             [   3: 0]        csr_wen_next               ,
    output                              R_wen_next                 ,
    output             [  31: 0]        rd_value_next              ,

    output                              mem_wen                    ,
    output                              mem_ren                    ,
    output                              inv_flag                   ,
    output                              branch_flag                ,
    output                              jump_flag                  ,

    output             [   3: 0]        alu_opcode                 ,

    output             [   4: 0]        rs1                        ,
    output             [   4: 0]        rs2                        ,
    output             [  31: 0]        a0_value                   ,
    output             [  31: 0]        mepc_out                   ,
    output             [  31: 0]        mtvec_out                  ,
    output             [31:0]   pc_out,


    input                               valid_last                 ,
    output                              ready_last                 ,

    input                               ready_next                 ,
    output                              valid_next                  
);

    reg                [  31: 0]        inst                        ;
    reg                [  31: 0]        snpc                        ;
    reg                [  31: 0]        pc                          ;
    reg                                 valid                       ;

    assign                              ready_last                  = ready_next && !stall;
    assign                              valid_next                  = valid;

    always @(posedge clock) begin
        if(reset || flush) begin
            inst <= 32'h00000013;
            snpc <= 0;
            pc <= 0;
            valid <= 0;
        end
        else if(ready_next && !stall) begin
            inst <= inst_in;
            snpc <= snpc_in;
            pc <= pc_in;
            valid <= valid_last;
        end
    end

    wire               [  31: 0]        csr_addr                    ;
    wire               [   6: 0]        oprand                      ;
    wire               [   6: 0]        opcode                      ;

    wire               [  31: 0]        imm_I                       ;
    wire               [  31: 0]        imm_U                       ;
    wire               [  31: 0]        imm_R                       ;
    wire               [  31: 0]        imm_S                       ;
    wire               [  31: 0]        imm_B                       ;
    wire               [  31: 0]        imm_J                       ;
    wire               [  31: 0]        csrs                        ;
    wire               [  31: 0]        imm                         ;

    assign                              oprand                      = inst[31:25];
    assign                              opcode                      = inst[6:0];
    assign                              rs1                         = inst[19:15];
    assign                              rs2                         = inst[24:20];
    assign                              funct3                      = inst[14:12];
    assign                              rd_next                     = inst[11:7];

    assign                              ecall_flag                  = (inst == 32'b00000000000000000000000001110011);//ecall
    assign                              mret_flag                   = (inst == 32'b00110000001000000000000001110011);// mret
    assign                              fence_i_flag                = (inst == 32'b00000000000000000001000000001111);

    assign                              csr_wen_next[0]             = (opcode == `M_opcode && imm == 32'h341);
    assign                              csr_wen_next[1]             = (opcode == `M_opcode && imm == 32'h342);
    assign                              csr_wen_next[2]             = (opcode == `M_opcode && imm == 32'h300);
    assign                              csr_wen_next[3]             = (opcode == `M_opcode && imm == 32'h305);

    assign                              R_wen_next                  = (opcode == `S_opcode || opcode == `B_opcode || opcode == 0)? 1'b0:1'b1;
    assign                              mem_wen                     = (opcode == `S_opcode);
    assign                              mem_ren                     = (opcode == `I0_opcode);

    assign                              jump_flag                   = (opcode == `I2_opcode || opcode == `J_opcode)? 1'b1:1'b0;

    assign                              inv_flag                    = (opcode == `B_opcode && (funct3 == 3'b101 || funct3 == 3'b111 || funct3 == 3'b000 ))? 1'b1:1'b0;
    assign                              branch_flag                 = (opcode == `B_opcode)? 1'b1:1'b0;
 
    assign                              csr_addr                    = imm;

    assign                              rd_value_next               = jump_flag? snpc: 
                                                                    (|csr_wen_next)? csrs:
                                                                    0;
    assign                              branch_pc                   = pc + imm;
    assign pc_out  = pc;

    assign add1_value = (opcode == `U0_opcode)? 0 :
                        (opcode == `J_opcode || opcode == `U1_opcode )? pc :
                        EXU_rs1_in;

    assign add2_value = (opcode == `R_opcode || opcode == `B_opcode)?  EXU_rs2_in :
                        (opcode == `M_opcode && funct3 == 3'b010)? rd_value_next :
                        (opcode == `M_opcode && funct3 == 3'b001)? 0 : imm;
 

    assign alu_opcode = (opcode == `S_opcode ||  opcode == `I0_opcode 
                        || opcode == `U0_opcode || opcode == `U1_opcode
                        || opcode == `J_opcode || opcode == `I2_opcode
                        || (opcode ==`I1_opcode  &&  funct3 == 3'b000)  || (opcode == `R_opcode         &&
                        funct3 == 3'b000 && oprand[5] == 1'b0) || (opcode == `B_opcode                             &&
                        funct3[2:1] == 2'b01                 ))                                                                     ?
                        `alu_add :(opcode == `I1_opcode && funct3 == 3'b010)                            ||
                        (opcode == `R_opcode && funct3 == 3'b010)                                                     ||
                        (opcode == `B_opcode && (funct3 == 3'b101 || funct3 == 3'b100))                               ?
                        `alu_signed_comparator:
                        (opcode == `B_opcode && (funct3 == 3'b110 || funct3 == 3'b111))                               ||
                        (opcode == `I1_opcode && (funct3 == 3'b011))                                                  ||
                        (opcode == `R_opcode && (funct3 ==  3'b011))                                                  ?
                        `alu_unsigned_comparator:
                        (opcode == `I1_opcode && funct3 == 3'b100 )                                                   ||
                        (opcode == `R_opcode && funct3 == 3'b100 )                                                    ?
                        `alu_xor :(opcode == `I1_opcode && funct3 == 3'b110 )                           ||
                        (opcode == `R_opcode && funct3 == 3'b110 )                                                    ||
                        (opcode == `M_opcode && funct3 == 3'b010 )                                                    ?
                        `alu_or  : (opcode == `I1_opcode && funct3 == 3'b111 )                          ||
                        (opcode == `R_opcode && funct3 == 3'b111 )                                                    ?
                        `alu_and :(opcode == `I1_opcode && funct3 == 3'b001  )                          ||
                        (opcode == `R_opcode && funct3 == 3'b001 )                                                    ?
                        `alu_sll :(opcode == `I1_opcode && funct3 == 3'b101 && oprand[5] == 1'b0)    ||
                        (opcode == `R_opcode && funct3 == 3'b101 && oprand[5] == 1'b0)                             ?
                        `alu_srl :(opcode == `I1_opcode && funct3 == 3'b101 && oprand[5] == 1'b1)    ||
                        (opcode == `R_opcode && funct3 == 3'b101 && oprand[5] == 1'b1)                             ?
                        `alu_sra : (opcode == `R_opcode && funct3 == 3'b000 && oprand[5] == 1'b1)    ?
                        `alu_sub : (opcode == `B_opcode && funct3[2:1] == 2'b00)                        ?
                        `alu_equal:`alu_add;


    assign                              imm_I                       = {{20{inst[31]}},inst[31:20]};
    assign                              imm_U                       = {inst[31:12],12'd0};
    assign                              imm_R                       = {25'd0,inst[31:25]};
    assign                              imm_S                       = {{20{inst[31]}},inst[31:25],inst[11:7]};
    assign                              imm_B                       = {imm_S[31:11],imm_S[0],imm_S[10:1]}<<1;
    assign                              imm_J                       = {{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21]}<<1;
/* verilator lint_off IMPLICIT */

    assign imm = (opcode == `I0_opcode || opcode == `I1_opcode || opcode == `I2_opcode || opcode == `M_opcode)? imm_I:
                 (opcode == `U0_opcode || opcode == `U1_opcode)? imm_U:
                 (opcode == `J_opcode)? imm_J:
                 (opcode == `B_opcode)? imm_B:
                 (opcode == `S_opcode)? imm_S: 
                 (opcode == `S_opcode)? imm_R :
                  0;

Reg_Stack Reg_Stack_inst0(
    .reset                              (reset                     ),
    .clock                              (clock                     ),
    .pc                                 (pc                        ),
    .ecall_flag                         (ecall_flag                ),

    .rs1                                (rs1                       ),
    .rs2                                (rs2                       ),
    .rd                                 (rd                        ),
    .rd_value                           (rd_value                  ),

    .csr_addr                           (csr_addr                  ),
    .R_wen                              (R_wen                     ),
    .csr_wen                            (csr_wen                   ),
    .csrd                               (csrd                      ),

    .rs1_value                          (rs1_value                 ),
    .rs2_value                          (rs2_value                 ),
    .a0_value                           (a0_value                  ),
    .csrs                               (csrs                      ),
    .mepc_out                           (mepc_out                  ),
    .mtvec_out                          (mtvec_out                 ) 
);





endmodule

