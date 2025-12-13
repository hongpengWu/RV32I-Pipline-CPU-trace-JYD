/* Deal with the Data hazard */

module Data_hazard(
    input              [   4: 0] IDU_rs1                    ,
    input              [   4: 0] IDU_rs2                    ,

    input              [   4: 0] EXU_rd                     ,
    input              [   4: 0] MEM_rd                     ,
    input              [   4: 0] WB_rd                      ,

    input                        IDU_valid                  ,
    input                        EXU_valid                  ,
    input                        MEM_valid                  ,
    input                        WB_valid                   ,

    input                        MEM_mem_ren                ,
    input                        EXU_R_Wen                  ,
    input                        MEM_R_Wen                  ,
    input                        WB_R_Wen                   ,

    output             [   2: 0] IDU_rs1_choice             ,
    output             [   2: 0] IDU_rs2_choice              
);

assign IDU_rs1_choice = (EXU_R_Wen && (EXU_rd == IDU_rs1 && EXU_rd != 0 ))? 3'b001:
                        (MEM_R_Wen && (MEM_rd == IDU_rs1 ) && (MEM_rd!=0))? (MEM_mem_ren? 3'b011:3'b010):
                        (WB_R_Wen  && (WB_rd  == IDU_rs1 ) && (WB_rd !=0))? 3'b100:
                        3'b000;

assign IDU_rs2_choice = (EXU_R_Wen && (EXU_rd == IDU_rs2 && EXU_rd != 0 ))? 3'b001:
                        (MEM_R_Wen && (MEM_rd == IDU_rs2 ) && (MEM_rd!=0))? (MEM_mem_ren? 3'b011:3'b010):
                        (WB_R_Wen  && (WB_rd  == IDU_rs2 ) && (WB_rd !=0))? 3'b100:
                        3'b000;

endmodule                                                           //Aribter



